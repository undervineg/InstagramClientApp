const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions

exports.observePostsCreated = functions.database.ref('/posts/{uid}/contents/{postId}').onCreate((snapshot, context) => {
  var uid = context.params.uid
  console.log('Post added by user:' + uid)

  return admin.database().ref('/posts/' + uid + '/count').once('value', snapshot => {
    var newCount = snapshot.val() + 1;
    return admin.database().ref('/posts/' + uid).update({ count: newCount });
  })
})

exports.observePostsDeleted = functions.database.ref('/posts/{uid}/contents/{postId}').onDelete((snapshot, context) => {
  var uid = context.params.uid
  console.log('Post added by user:' + uid)

  return admin.database().ref('/posts/' + uid + '/count').once('value', snapshot => {
    var newCount = snapshot.val() - 1;
    return admin.database().ref('/posts/' + uid).update({ count: newCount });
  })
})

exports.observeFollow = functions.database.ref('/following/{uid}/{followingId}').onCreate((snapshot, context) => {
  var uid = context.params.uid
  return admin.database().ref('/following/' + uid + '/count').once('value', snapshot => {
    var newCount = snapshot.val() + 1;
    return admin.database().ref('/following/' + uid).update({ count: newCount });
  })
})

exports.observeUnfollow = functions.database.ref('/following/{uid}/{followingId}').onDelete((snapshot, context) => {
  var uid = context.params.uid
  return admin.database().ref('/following/' + uid + '/count').once('value', snapshot => {
    var newCount = snapshot.val() - 1;
    return admin.database().ref('/following/' + uid).update({ count: newCount });
  })
})

exports.observeFollowing = functions.database.ref('/following/{uid}/{followingId}').onCreate((snapshot, context) => {
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
