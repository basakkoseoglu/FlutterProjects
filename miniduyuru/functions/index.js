const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationOnCreate = onDocumentCreated(
  "notifications/{id}",
  async (event) => {
    const data = event.data.data();

    const message = {
      notification: {
        title: data.title,
        body: data.body,
      },
      topic: "allUsers",
    };

    await admin.messaging().send(message);
    console.log("Bildirim gönderildi");
  }
);
