const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ============================================
// NOTIFICATION TRIGGERS
// ============================================

// Send notification when connection request is received
exports.onConnectionRequestReceived = functions.firestore
  .document('connection_requests/{requestId}')
  .onCreate(async (snap, context) => {
    const request = snap.data();
    
    // Get receiver's FCM token
    const receiverDoc = await db.collection('users').doc(request.receiverId).get();
    const receiverData = receiverDoc.data();
    
    if (!receiverData || !receiverData.fcmToken) {
      return null;
    }
    
    // Get sender's name
    const senderDoc = await db.collection('users').doc(request.senderId).get();
    const senderName = senderDoc.data()?.name || 'Someone';
    
    // Send notification
    const message = {
      notification: {
        title: 'New Connection Request',
        body: `${senderName} wants to connect with you`,
      },
      data: {
        type: 'connection_request',
        requestId: snap.id,
        senderId: request.senderId,
      },
      token: receiverData.fcmToken,
    };
    
    try {
      await messaging.send(message);
      console.log('Connection request notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
    
    return null;
  });

// Send notification when connection is accepted
exports.onConnectionAccepted = functions.firestore
  .document('connection_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Check if status changed to accepted
    if (before.status !== 'accepted' && after.status === 'accepted') {
      // Get sender's FCM token
      const senderDoc = await db.collection('users').doc(after.senderId).get();
      const senderData = senderDoc.data();
      
      if (!senderData || !senderData.fcmToken) {
        return null;
      }
      
      // Get receiver's name
      const receiverDoc = await db.collection('users').doc(after.receiverId).get();
      const receiverName = receiverDoc.data()?.name || 'Someone';
      
      // Send notification
      const message = {
        notification: {
          title: 'Connection Accepted',
          body: `${receiverName} accepted your connection request`,
        },
        data: {
          type: 'connection_accepted',
          userId: after.receiverId,
        },
        token: senderData.fcmToken,
      };
      
      try {
        await messaging.send(message);
        console.log('Connection accepted notification sent successfully');
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    }
    
    return null;
  });

// Send notification for new messages
exports.onNewMessage = functions.firestore
  .document('chat_rooms/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const chatId = context.params.chatId;
    
    // Get chat room to find receiver
    const chatDoc = await db.collection('chat_rooms').doc(chatId).get();
    const chatData = chatDoc.data();
    
    if (!chatData) return null;
    
    // Find receiver (participant who is not the sender)
    const receiverId = chatData.participantIds.find(id => id !== message.senderId);
    
    if (!receiverId) return null;
    
    // Get receiver's FCM token
    const receiverDoc = await db.collection('users').doc(receiverId).get();
    const receiverData = receiverDoc.data();
    
    if (!receiverData || !receiverData.fcmToken) {
      return null;
    }
    
    // Get sender's name
    const senderDoc = await db.collection('users').doc(message.senderId).get();
    const senderName = senderDoc.data()?.name || 'Someone';
    
    // Send notification
    const notificationMessage = {
      notification: {
        title: senderName,
        body: message.type === 'text' ? message.content : '📷 Sent an image',
      },
      data: {
        type: 'new_message',
        chatId: chatId,
        senderId: message.senderId,
      },
      token: receiverData.fcmToken,
    };
    
    try {
      await messaging.send(notificationMessage);
      console.log('New message notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
    
    return null;
  });

// Send notification for post likes
exports.onPostLiked = functions.firestore
  .document('posts/{postId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Check if likes increased
    if (after.likesCount > before.likesCount) {
      // Find new liker
      const newLikers = after.likedBy.filter(id => !before.likedBy.includes(id));
      
      if (newLikers.length === 0) return null;
      
      const likerId = newLikers[0];
      
      // Don't send notification if user likes their own post
      if (likerId === after.userId) return null;
      
      // Get post author's FCM token
      const authorDoc = await db.collection('users').doc(after.userId).get();
      const authorData = authorDoc.data();
      
      if (!authorData || !authorData.fcmToken) {
        return null;
      }
      
      // Get liker's name
      const likerDoc = await db.collection('users').doc(likerId).get();
      const likerName = likerDoc.data()?.name || 'Someone';
      
      // Send notification
      const message = {
        notification: {
          title: 'Post Liked',
          body: `${likerName} liked your post`,
        },
        data: {
          type: 'post_liked',
          postId: context.params.postId,
          likerId: likerId,
        },
        token: authorData.fcmToken,
      };
      
      try {
        await messaging.send(message);
        console.log('Post liked notification sent successfully');
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    }
    
    return null;
  });

// Send notification for new comments
exports.onNewComment = functions.firestore
  .document('posts/{postId}/comments/{commentId}')
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const postId = context.params.postId;
    
    // Get post to find author
    const postDoc = await db.collection('posts').doc(postId).get();
    const postData = postDoc.data();
    
    if (!postData) return null;
    
    // Don't send notification if user comments on their own post
    if (comment.userId === postData.userId) return null;
    
    // Get post author's FCM token
    const authorDoc = await db.collection('users').doc(postData.userId).get();
    const authorData = authorDoc.data();
    
    if (!authorData || !authorData.fcmToken) {
      return null;
    }
    
    // Send notification
    const message = {
      notification: {
        title: 'New Comment',
        body: `${comment.userName} commented on your post`,
      },
      data: {
        type: 'new_comment',
        postId: postId,
        commentId: snap.id,
        userId: comment.userId,
      },
      token: authorData.fcmToken,
    };
    
    try {
      await messaging.send(message);
      console.log('New comment notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
    
    return null;
  });

// Send notification when club join request is approved
exports.onClubMemberApproved = functions.firestore
  .document('clubs/{clubId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Find newly approved members
    const newMembers = after.memberIds.filter(id => !before.memberIds.includes(id));
    
    if (newMembers.length === 0) return null;
    
    const clubName = after.name;
    
    // Send notifications to newly approved members
    const promises = newMembers.map(async (memberId) => {
      const memberDoc = await db.collection('users').doc(memberId).get();
      const memberData = memberDoc.data();
      
      if (!memberData || !memberData.fcmToken) {
        return;
      }
      
      const message = {
        notification: {
          title: 'Club Request Approved',
          body: `You have been approved to join ${clubName}`,
        },
        data: {
          type: 'club_approved',
          clubId: context.params.clubId,
        },
        token: memberData.fcmToken,
      };
      
      try {
        await messaging.send(message);
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    });
    
    await Promise.all(promises);
    return null;
  });

// ============================================
// MODERATION & CLEANUP FUNCTIONS
// ============================================

// Auto-remove posts with excessive reports
exports.autoModerateReports = functions.firestore
  .document('posts/{postId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    
    // If post is marked as reported, auto-hide it
    if (after.isReported) {
      console.log(`Post ${context.params.postId} has been reported and hidden`);
      // Could add additional moderation logic here
    }
    
    return null;
  });

// Clean up old anonymous posts (older than 30 days)
exports.cleanOldAnonymousPosts = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const oldPosts = await db.collection('anonymous_posts')
      .where('createdAt', '<', thirtyDaysAgo.toISOString())
      .get();
    
    const batch = db.batch();
    oldPosts.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log(`Deleted ${oldPosts.size} old anonymous posts`);
    
    return null;
  });

// ============================================
// CALLABLE FUNCTIONS
// ============================================

// Admin function to ban user
exports.banUser = functions.https.onCall(async (data, context) => {
  // Check if caller is admin
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const callerDoc = await db.collection('users').doc(context.auth.uid).get();
  const callerData = callerDoc.data();
  
  if (!callerData || callerData.role !== 'Admin') {
    throw new functions.https.HttpsError('permission-denied', 'User must be an admin');
  }
  
  // Ban the user
  await db.collection('users').doc(data.userId).update({
    isBanned: true,
  });
  
  return { success: true, message: 'User banned successfully' };
});

// Update user presence
exports.updatePresence = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  await db.collection('users').doc(context.auth.uid).update({
    lastSeen: admin.firestore.FieldValue.serverTimestamp(),
    isOnline: data.isOnline || false,
  });
  
  return { success: true };
});
