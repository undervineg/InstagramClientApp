const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const async = require('async');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions

exports.observePostsCreatedCount = functions.database.ref('/posts/{uid}/{postId}').onCreate((snapshot, context) => {
  var uid = context.params.uid
  console.log('Post added by user:' + uid)

  return admin.database().ref('/counts/' + uid + '/post').once('value', snapshot => {
    var newCount = snapshot.val() + 1;
    return admin.database().ref('/counts/' + uid).update({ post: newCount });
  })
})

exports.observePostsDeletedCount = functions.database.ref('/posts/{uid}/{postId}').onDelete((snapshot, context) => {
  var uid = context.params.uid
  console.log('Post added by user:' + uid)

  return admin.database().ref('/counts/' + uid + '/post').once('value', snapshot => {
    var newCount = snapshot.val() - 1;
    return admin.database().ref('/counts/' + uid).update({ post: newCount });
  })
})

exports.observeFollowCount = functions.database.ref('/following/{followedId}/{followerId}').onCreate((snapshot, context) => {
  var followedId = context.params.followedId
  var followerId = context.params.followerId

  return admin.database().ref('/counts/' + followedId + '/follower').once('value', snapshot => {
    var newCount = snapshot.val() + 1;
    return admin.database().ref('/counts/' + followedId).update({ follower: newCount }, function(error) {
      if (error) {
        console.log('Error increasing following count:', error);
      }
      return admin.database().ref('/counts/' + followerId + '/following').once('value', snapshot => {
        var newCount = snapshot.val() + 1;
        return admin.database().ref('/counts/' + followerId).update({ following: newCount })
      })
    });
  })
})

exports.observeUnfollowCount = functions.database.ref('/following/{followedId}/{followerId}').onDelete((snapshot, context) => {
  var followedId = context.params.followedId
  var followerId = context.params.followerId

  return admin.database().ref('/counts/' + followedId + '/follower').once('value', snapshot => {
    var newCount = snapshot.val() - 1;
    return admin.database().ref('/counts/' + followedId).update({ follower: newCount }, function(error) {
      if (error) {
        console.log('Error decreasing following count:', error);
      }
      return admin.database().ref('/counts/' + followerId + '/following').once('value', snapshot => {
        var newCount = snapshot.val() - 1;
        return admin.database().ref('/counts/' + followerId).update({ following: newCount })
      })
    });
  })
})

exports.observeLikeNotification = functions.database.ref('/likes/{uidWhoPostedId}/{postId}/{uidWhoLikesId}').onCreate((snapshot, context) => {
  var userWhoPostedId = context.params.uidWhoPostedId
  var userWhoLikesId = context.params.uidWhoLikesId
  var postId = context.params.postId

  var topic = 'followers';
  var notiType = 1

  console.log('Notification Topic: ' + topic);

  return admin.database().ref('/users/' + userWhoPostedId).once('value', snapshot => {
    var userWhoPosted = snapshot.val();
    return admin.database().ref('/users/' + userWhoLikesId).once('value', snapshot => {
        var userWhoLikes = snapshot.val();
        return admin.database().ref('/posts/' + userWhoPostedId + '/' + postId).once('value', snapshot => {
          var post = snapshot.val();

          console.log("Liked Post: " + post);

          var body = userWhoLikes.username + "님이 " + userWhoPosted.username + "님의 게시물을 좋아합니다."
          var createdAt = Date.now() / 1000;
          var startIndex_userLikes = 0
          var length_userLikes = userWhoLikes.username.length
          var endIndex_userLikes = startIndex_userLikes + length_userLikes - 1
          var startIndex_userPosted = endIndex_userLikes + 3
          var length_userPosted = userWhoPosted.username.length
          var endIndex_userPosted = startIndex_userPosted + length_userPosted - 1
          var emphasizeIndices = [startIndex_userLikes, length_userLikes, startIndex_userPosted, length_userPosted];

          console.log('Send message: ' + body + ' created at ' + createdAt);

          var q = async.queue(function(task, callback) {
            var followerId = Object.keys(task).map(k => task[k]);
            console.log('Task values(followerId): ' + followerId + ' UserWhoLikesId: ' + userWhoLikesId);
            // skip current user who liked the post
            if (followerId == userWhoLikesId) {
              console.log('skip: ' + followerId);
              return
            }
            // send notification
            return admin.database().ref('/counts/' + followerId + '/unreadNotification').once('value', snapshot => {
              var unreadCount = snapshot.val() + 1;
              return admin.database().ref('/counts/' + followerId).update({ unreadNotification: unreadCount }, function(error){
                if (error) {
                  console.log('Error saving message:', error);
                  return
                }

                return admin.database().ref('/users/' + followerId).once('value', snapshot => {
                  var follower = snapshot.val();

                  var payload = {
                    notification: {
                      body: body
                    },
                    data: {
                      type: notiType.toString(),
                      postId: postId
                    },
                    token: follower.fcmToken
                  };

                  return admin.database().ref('/notifications/' + followerId).push().update({
                    type: notiType,
                    body: body,
                    creationDate: createdAt,
                    emphasizeIndices: emphasizeIndices,
                    profileImageUrl: userWhoLikes.profileImageUrl,
                    profileLink: userWhoLikesId,
                    detailImageUrls: [post.imageUrl],
                    detailLinks: [postId]
                  }, function(error){
                    if (error) {
                      console.log('Error saving message:', error);
                      return
                    }

                    admin.messaging().send(payload)
                      .then((response) => {
                        console.log('Successfully sent message:', response);
                        callback();
                      })
                      .catch((error) => {
                        console.log('Error sending message:', error);
                        return
                      });

                  });
                })

              })
            })

          }, 5);

          return admin.database().ref('/following/' + userWhoPostedId).once('value', snapshot => {
            // send to posted user
            q.push({name: userWhoPostedId}, function(err) {
              if (err) {
                console.log('Error pushing task: ' + userWhoPostedId);
              }
              console.log('Finished processing ' + userWhoPostedId);
            });
            // send to followers of posted user
            snapshot.forEach(function(childSnapshot) {
              var followerId = childSnapshot.key;
              q.push({name: followerId}, function(err) {
                if (err) {
                  console.log('Error pushing task: ' + followerId);
                }
                console.log('Finished processing ' + followerId);
              });
            })
          })

        })
    })
  })
})

exports.observeFollowNotification = functions.database.ref('/following/{followingId}/{followerId}').onCreate((snapshot, context) => {
     var followingId = context.params.followingId
     var followerId = context.params.followerId

     var notiType = 0

     console.log('User:' + followerId + 'is now following:' + followingId)

     return admin.database().ref('/users/' + followingId).once('value', snapshot => {
       var followee = snapshot.val();

       return admin.database().ref('/users/' + followerId).once('value', snapshot => {
         var follower = snapshot.val();

         var title = "새 팔로워가 있습니다!"
         var body = follower.username+"님이 회원님을 팔로우하기 시작했습니다."
         var createdAt = Date.now() / 1000;
         var emphasizeIndices = [0, follower.username.length];
         var buttonType = 0

         return admin.database().ref('/counts/' + followingId + '/unreadNotification').once('value', snapshot => {
           console.log('Save message to followingId:', followingId);
           var unreadCount = snapshot.val() + 1;
           return admin.database().ref('/counts/' + followingId).update({ unreadNotification: unreadCount }, function(error){
             if (error) {
               console.log('Error saving count:', error);
             }

             var payload = {
               notification: {
                 title: title,
                 body: body
               },
               apns: {
                 payload: {
                   aps: {
                     sound: "default",
                     badge: unreadCount
                   }
                 }
               },
               data: {
                 type: notiType.toString(),
                 followerId: followerId
               },
               token: followee.fcmToken
             };

             console.log('Unread count:', unreadCount);

             return admin.database().ref('/notifications/' + followingId).push().update({
               type: notiType,
               title: title,
               body: body,
               creationDate: createdAt,
               emphasizeIndices: emphasizeIndices,
               profileImageUrl: follower.profileImageUrl,
               profileLink: followerId,
               detailButtonType: buttonType
             }, function(error){
               if (error) {
                 console.log('Error saving message:', error);
               }
               admin.messaging().send(payload)
                 .then((response) => {
                   console.log('Successfully sent message:', response);
                   console.log('Follower token:' + follower.fcmToken + 'Followee token:' + followee.fcmToken);
                 })
                 .catch((error) => {
                   console.log('Error sending message:', error);
                 });
             });

           });
         })
     })

   })
})
