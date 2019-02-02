const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions

exports.observeFollowing = functions.database.ref('/following/{uid}/{followingId}')
  .onCreate((snapshot, context) => {
     var uid = context.params.uid
     var followingId = context.params.followingId

     console.log('User:' + uid + 'is following:' + followingId)

     return admin.database().ref('/users/' + followingId).once('value', snapshot => {
       var userToFollow = snapshot.val();

       return admin.database().ref('/users/' + uid).once('value', snapshot => {
         var user = snapshot.val();

         var payload = {
           notification: {
             title: "You have a new follower!",
             body: user.username + " is now following you."
           },
           data: {
             followerId: uid
           },
           token: userToFollow.fcmToken
         };

         admin.messaging().send(payload)
           .then((response) => {
             console.log('Successfully sent message:', response);
             console.log('Follower token:' + user.fcmToken + 'Followee token:' + userToFollow.fcmToken);
           })
           .catch((error) => {
             console.log('Error sending message:', error);
           });

       })

     })
  })

exports.sendPushNotifications = functions.https.onRequest((req, res) => {
  res.send("Attempting to send push notifications...")
  console.log("LOGGER --- Trying to send push message...")

  // This registration token comes from the client FCM SDKs.
  var uid = 'YDUzOdEoKtOkfC1fAReU0BDLvvF3'

  return admin.database().ref('/users/' + uid).once('value', snapshot => {
    var user = snapshot.val();

    console.log('User username:' + user.username + 'fcmToken:' + user.fcmToken)

    // See documentation on defining a message payload.
    var payload = {
      notification: {
        title: "You have a new follower!",
        body: newFollower.username + "is now following you."
      },
      token: user.fcmToken
    };

    // Send a message to the device corresponding to the provided registration token.
    admin.messaging().send(payload)
      .then((response) => {
        // Response is a message ID string.
        console.log('Successfully sent message:', response);
      })
      .catch((error) => {
        console.log('Error sending message:', error);
      });
  })
})
