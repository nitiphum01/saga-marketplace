import {setGlobalOptions} from "firebase-functions";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

admin.initializeApp();

setGlobalOptions({maxInstances: 10});

export const notifyNewChatMessage = onDocumentCreated(
  {
    document: "conversations/{roomId}/messages/{messageId}",
    region: "asia-southeast1",
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("Missing snapshot data in trigger event.");
      return;
    }

    const messageData = snapshot.data();
    const roomId = event.params.roomId;

    const senderId = (messageData.senderId as string | undefined)?.trim() ?? "";
    const text = (messageData.text as string | undefined)?.trim() ?? "New message";

    if (!roomId || !senderId) {
      logger.warn("Missing roomId or senderId.", {roomId, senderId});
      return;
    }

    const conversationSnap = await admin
      .firestore()
      .collection("conversations")
      .doc(roomId)
      .get();

    if (!conversationSnap.exists) {
      logger.warn("Conversation document not found.", {roomId});
      return;
    }

    const conversation = conversationSnap.data() ?? {};
    const participantsRaw = conversation.participants;

    const participants = Array.isArray(participantsRaw) ?
      participantsRaw.filter((id): id is string => typeof id === "string") :
      [];

    const receiverIds = participants.filter((id) => id !== senderId);

    if (receiverIds.length === 0) {
      logger.info("No receiver found for chat message.", {roomId, senderId});
      return;
    }

    const senderSnap = await admin.firestore().collection("users").doc(senderId).get();
    const senderDisplayName =
      (senderSnap.data()?.displayName as string | undefined)?.trim() || "New message";

    for (const receiverId of receiverIds) {
      const userSnap = await admin.firestore().collection("users").doc(receiverId).get();
      if (!userSnap.exists) {
        logger.warn("Receiver user doc not found.", {receiverId});
        continue;
      }

      const userData = userSnap.data() ?? {};
      const notificationsEnabled = userData.notificationsEnabled === true;

      if (!notificationsEnabled) {
        logger.info("Receiver notifications disabled.", {receiverId});
        continue;
      }

      const fcmTokensRaw = userData.fcmTokens;
      const fcmTokens = Array.isArray(fcmTokensRaw) ?
        fcmTokensRaw.filter((token): token is string => typeof token === "string" && token.trim().length > 0) :
        [];

      if (fcmTokens.length === 0) {
        logger.info("Receiver has no FCM tokens.", {receiverId});
        continue;
      }

      const response = await admin.messaging().sendEachForMulticast({
        tokens: fcmTokens,
        notification: {
          title: senderDisplayName,
          body: text,
        },
        data: {
          type: "chat",
          roomId,
          senderId,
        },
        android: {
          priority: "high",
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      });

      logger.info("FCM send result", {
        roomId,
        receiverId,
        successCount: response.successCount,
        failureCount: response.failureCount,
      });

      const invalidTokens: string[] = [];
      response.responses.forEach((result, index) => {
        if (result.success) {
          return;
        }

        const errorCode = result.error?.code ?? "";
        if (
          errorCode === "messaging/registration-token-not-registered" ||
          errorCode === "messaging/invalid-registration-token"
        ) {
          invalidTokens.push(fcmTokens[index]);
        }
      });

      if (invalidTokens.length > 0) {
        await admin.firestore().collection("users").doc(receiverId).set(
          {
            fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true}
        );
      }
    }
  }
);
