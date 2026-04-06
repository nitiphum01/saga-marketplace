const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
const serviceAccount = require(serviceAccountPath);

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

const PORT = process.env.PORT || 3000;

async function writeNotificationLog({
  roomId,
  senderId,
  text,
  receiverId,
  receiverDisplayName,
  notificationsEnabled,
  tokensCount,
  sentCount,
  failedCount,
  invalidTokens,
  status,
  errors,
}) {
  await db.collection('notification_logs').add({
    roomId,
    senderId,
    text,
    receiverId,
    receiverDisplayName,
    notificationsEnabled,
    tokensCount,
    sentCount,
    failedCount,
    invalidTokens,
    status,
    errors,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

app.get('/health', async (_req, res) => {
  try {
    await db.collection('_healthcheck').limit(1).get();
    return res.status(200).json({ ok: true, service: 'chat-fcm-backend' });
  } catch (error) {
    return res.status(500).json({ ok: false, error: error.message });
  }
});

app.post('/send-chat-notification', async (req, res) => {
  const { roomId, senderId, text } = req.body || {};

  if (!roomId || !senderId || !text) {
    return res.status(400).json({
      ok: false,
      error: 'Missing required fields: roomId, senderId, text',
    });
  }

  try {
    const conversationRef = db.collection('conversations').doc(String(roomId));
    const conversationSnap = await conversationRef.get();

    if (!conversationSnap.exists) {
      return res.status(404).json({
        ok: false,
        error: 'Conversation not found',
      });
    }

    const conversationData = conversationSnap.data() || {};
    const participants = Array.isArray(conversationData.participants)
      ? conversationData.participants.filter((id) => typeof id === 'string')
      : [];

    const receiverIds = participants.filter((id) => id !== String(senderId));

    if (receiverIds.length === 0) {
      await writeNotificationLog({
        roomId: String(roomId),
        senderId: String(senderId),
        text: String(text),
        receiverId: null,
        receiverDisplayName: null,
        notificationsEnabled: false,
        tokensCount: 0,
        sentCount: 0,
        failedCount: 0,
        invalidTokens: [],
        status: 'NO_RECEIVER',
        errors: ['No receiver found in conversation participants'],
      });

      return res.status(200).json({
        ok: true,
        message: 'No receiver found for this conversation',
      });
    }

    const senderSnap = await db.collection('users').doc(String(senderId)).get();
    const senderDisplayName =
      (senderSnap.data() && senderSnap.data().displayName) || 'New message';

    const summary = {
      totalReceivers: receiverIds.length,
      notifiedReceivers: 0,
      skippedReceivers: 0,
      totalSuccessCount: 0,
      totalFailureCount: 0,
      details: [],
    };

    for (const receiverId of receiverIds) {
      const userRef = db.collection('users').doc(receiverId);
      const userSnap = await userRef.get();

      if (!userSnap.exists) {
        const detail = {
          receiverId,
          status: 'USER_NOT_FOUND',
        };
        summary.details.push(detail);
        summary.skippedReceivers += 1;

        await writeNotificationLog({
          roomId: String(roomId),
          senderId: String(senderId),
          text: String(text),
          receiverId,
          receiverDisplayName: null,
          notificationsEnabled: false,
          tokensCount: 0,
          sentCount: 0,
          failedCount: 0,
          invalidTokens: [],
          status: detail.status,
          errors: ['Receiver user document not found'],
        });
        continue;
      }

      const userData = userSnap.data() || {};
      const notificationsEnabled = userData.notificationsEnabled === true;
      const receiverDisplayName = userData.displayName || null;
      const fcmTokens = Array.isArray(userData.fcmTokens)
        ? userData.fcmTokens.filter(
            (token) => typeof token === 'string' && token.trim().length > 0
          )
        : [];

      if (!notificationsEnabled) {
        const detail = {
          receiverId,
          status: 'NOTIFICATIONS_DISABLED',
        };
        summary.details.push(detail);
        summary.skippedReceivers += 1;

        await writeNotificationLog({
          roomId: String(roomId),
          senderId: String(senderId),
          text: String(text),
          receiverId,
          receiverDisplayName,
          notificationsEnabled: false,
          tokensCount: fcmTokens.length,
          sentCount: 0,
          failedCount: 0,
          invalidTokens: [],
          status: detail.status,
          errors: [],
        });
        continue;
      }

      if (fcmTokens.length === 0) {
        const detail = {
          receiverId,
          status: 'NO_TOKENS',
        };
        summary.details.push(detail);
        summary.skippedReceivers += 1;

        await writeNotificationLog({
          roomId: String(roomId),
          senderId: String(senderId),
          text: String(text),
          receiverId,
          receiverDisplayName,
          notificationsEnabled: true,
          tokensCount: 0,
          sentCount: 0,
          failedCount: 0,
          invalidTokens: [],
          status: detail.status,
          errors: ['fcmTokens is empty'],
        });
        continue;
      }

      const response = await admin.messaging().sendEachForMulticast({
        tokens: fcmTokens,
        notification: {
          title: String(senderDisplayName),
          body: String(text),
        },
        data: {
          type: 'chat',
          roomId: String(roomId),
          senderId: String(senderId),
          text: String(text),
        },
        android: {
          priority: 'high',
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      });

      const invalidTokens = [];
      const errors = [];

      response.responses.forEach((result, index) => {
        if (result.success) {
          return;
        }

        const errorCode = result.error && result.error.code ? result.error.code : 'unknown-error';
        const errorMessage = result.error && result.error.message ? result.error.message : 'Unknown error';

        errors.push({
          token: fcmTokens[index],
          code: errorCode,
          message: errorMessage,
        });

        if (
          errorCode === 'messaging/registration-token-not-registered' ||
          errorCode === 'messaging/invalid-registration-token'
        ) {
          invalidTokens.push(fcmTokens[index]);
        }
      });

      if (invalidTokens.length > 0) {
        await userRef.set(
          {
            fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      }

      summary.notifiedReceivers += 1;
      summary.totalSuccessCount += response.successCount;
      summary.totalFailureCount += response.failureCount;

      const status = response.failureCount === 0 ? 'SENT' : 'PARTIAL_FAILURE';

      summary.details.push({
        receiverId,
        status,
        successCount: response.successCount,
        failureCount: response.failureCount,
      });

      await writeNotificationLog({
        roomId: String(roomId),
        senderId: String(senderId),
        text: String(text),
        receiverId,
        receiverDisplayName,
        notificationsEnabled: true,
        tokensCount: fcmTokens.length,
        sentCount: response.successCount,
        failedCount: response.failureCount,
        invalidTokens,
        status,
        errors,
      });
    }

    return res.status(200).json({
      ok: true,
      message: 'Notification process completed',
      summary,
    });
  } catch (error) {
    await writeNotificationLog({
      roomId: String(roomId),
      senderId: String(senderId),
      text: String(text),
      receiverId: null,
      receiverDisplayName: null,
      notificationsEnabled: false,
      tokensCount: 0,
      sentCount: 0,
      failedCount: 0,
      invalidTokens: [],
      status: 'SERVER_ERROR',
      errors: [error.message || String(error)],
    });

    return res.status(500).json({
      ok: false,
      error: error.message || 'Internal server error',
    });
  }
});

app.listen(PORT, () => {
  console.log(`chat-backend is running on port ${PORT}`);
});
