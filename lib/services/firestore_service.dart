import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:yspc/services/openai_client.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final OpenAIClient _openAI = OpenAIClient();

  // ---------- USER PROFILE ----------
  Future<void> createUserProfile({
    required String uid,
    required String email,
    String? name,
  }) async {
    final userRef = _db.collection('users').doc(uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'uid': uid,
        'email': email,
        'name': name ?? '',
        'is_onboarded': false,
        'moodStreak': 0,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateOnboardingStatus(String uid, bool status) async {
    await _db.collection('users').doc(uid).update({
      'is_onboarded': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserField(String uid, String field, dynamic value) async {
    await _db.collection('users').doc(uid).update({
      field: value,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Future<void> saveSelectedCoach(String uid, String coachId) async {
  //   await _db.collection('users').doc(uid).update({
  //     'selectedCoachId': coachId,
  //     'updated_at': FieldValue.serverTimestamp(),
  //   });
  // }
  //
  // // NEW: Get selected coach
  // Future<String?> getSelectedCoach(String uid) async {
  //   final doc = await _db.collection('users').doc(uid).get();
  //   return doc.data()?['selectedCoachId'] as String?;
  // }

  Future<void> deleteUserData(String uid) async {
    // Delete main user document
    await _db.collection('users').doc(uid).delete();

    // Delete subcollections (chat_history, moods, journals, affirmations, billing_history)
    await _deleteSubcollection(uid, 'chat_history');
    await _deleteSubcollection(uid, 'moods');
    await _deleteSubcollection(uid, 'journals');
    await _deleteSubcollection(uid, 'affirmations');
    await _deleteSubcollection(uid, 'billing_history');
  }

  Future<void> _deleteSubcollection(String uid, String collectionName) async {
    final collectionRef = _db.collection('users').doc(uid).collection(collectionName);
    final snapshot = await collectionRef.get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }



  Future<void> saveSelectedCoach(String uid, String coachId) async {
    await _db.collection('users').doc(uid).set({
      'selectedCoachId': coachId,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));  // ← MERGE = never overwrites other data
  }

  Future<String?> getSelectedCoach(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return doc.get('selectedCoachId') as String?;
    } catch (e) {
      debugPrint('❌ Error getting selected coach: $e');
      return null;
    }
  }























  // ---------- CHAT HISTORY ----------
  Future<void> saveChatMessage({
    required String uid,
    required String role,
    required String message,
  }) async {
    final messagesRef = _db.collection('users').doc(uid).collection('chat_history');

    await messagesRef.add({
      'role': role,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToChatHistory(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('chat_history')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getChatHistory(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('chat_history')
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> clearChatHistory(String uid) async {
    final batch = _db.batch();
    final collection = await _db.collection('users').doc(uid).collection('chat_history').get();

    for (final doc in collection.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ---------- MOOD LOGGING ----------
  Future<void> logMood(String uid, Map<String, dynamic> mood) async {
    try {
      await _db.collection('users').doc(uid).collection('moods').add({
        'value': mood['value'],
        'emoji': mood['emoji'],
        'note': mood['note'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
      // NEW: Increment usage
      await incrementUsage(uid, 'moodCheckinsCount');
    } catch (e) {
      print('Error logging mood: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyMoods(String uid) async {
    final sevenDaysAgo = Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7)));
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('moods')
        .where('timestamp', isGreaterThan: sevenDaysAgo)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>?> getTodayMood(String uid) async {
    final todayStart = DateTime.now();
    final startTimestamp = Timestamp.fromDate(DateTime(todayStart.year, todayStart.month, todayStart.day));
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('moods')
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getRecentMoods(String uid, int days) async {
    final daysAgo = Timestamp.fromDate(DateTime.now().subtract(Duration(days: days)));
    return await _db
        .collection('users')
        .doc(uid)
        .collection('moods')
        .where('timestamp', isGreaterThanOrEqualTo: daysAgo)
        .orderBy('timestamp', descending: true)
        .get();
  }

  Future<int> calculateMoodStreak(String uid) async {
    final moodsSnap = await getRecentMoods(uid, 30);
    final moods = moodsSnap.docs;

    int streak = 0;
    DateTime currentDay = DateTime.now();

    for (int i = 0; i < moods.length; i++) {
      final moodDate = (moods[i]['timestamp'] as Timestamp).toDate();
      if (moodDate.year == currentDay.year && moodDate.month == currentDay.month && moodDate.day == currentDay.day) {
        streak++;
        currentDay = currentDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // ---------- JOURNAL LOGGING ----------
  Future<void> logJournal(String uid, String text) async {
    await _db.collection('users').doc(uid).collection('journals').add({
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    // NEW: Increment usage
    await incrementUsage(uid, 'journalEntriesCount');
  }

  Future<Map<String, dynamic>?> getLastJournal(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('journals')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  // ---------- AFFIRMATION LOGGING ----------
  Future<Map<String, String>?> getDailyAffirmation(String userId, String date) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('affirmations')
        .doc(date)
        .get();
    if (doc.exists) {
      return {
        'text': doc['text'] as String,
        'category': doc['category'] as String,
      };
    }
    return null;
  }

  Future<void> saveDailyAffirmation(String userId, String date, String text, String category) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('affirmations')
        .doc(date)
        .set({
      'text': text,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, String>> generateAffirmationFromOpenAI({String category = 'General', String? userName}) async {
    try {
      final prompt = '''
Generate a positive, concise affirmation (1-2 sentences, max 100 characters) for personal growth or mental wellness in the category of "$category".
Example: "I am confident and capable in all that you do."
Return only the affirmation text.
''';
      final completion = await _openAI.createChatCompletion(
        messages: [Message(role: 'user', content: prompt)],
        model: 'gpt-4o-mini',
        coachInstruction: 'You are an empathetic affirmation generator.',
      );
      return {'text': completion.text, 'category': category};
    } catch (e) {
      return {
        'text': 'I am strong and capable of overcoming any challenge.',
        'category': category,
      };
    }
  }
  Future<List<Map<String, dynamic>>> getAffirmationHistory(String uid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('affirmations')
        .orderBy('timestamp', descending: true)
        .limit(30) // Limit to last 30 affirmations for performance
        .get();
    return querySnapshot.docs.map((doc) => {
      'date': doc.id,
      'text': doc['text'] as String,
      'category': doc['category'] as String,
      'timestamp': (doc['timestamp'] as Timestamp).toDate(),
    }).toList();
  }

  // NEW: ---------- SUBSCRIPTION MANAGEMENT ----------
  Future<void> startFreeTrial(String uid) async {
    final now = Timestamp.now();
    final endDate = Timestamp.fromDate(now.toDate().add(const Duration(days: 7)));
    await _db.collection('users').doc(uid).update({
      'subscriptionType': 'free_trial',
      'subscriptionStatus': 'active',
      'trialStartDate': now,
      'trialEndDate': endDate,
      'paymentMethod': 'none',
    });
  }

  Future<bool> isSubscribed(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    final type = data['subscriptionType'] as String? ?? 'expired';
    if (type == 'free_trial') {
      final endDate = data['trialEndDate'] as Timestamp?;
      if (endDate == null || DateTime.now().isAfter(endDate.toDate())) {
        await _db.collection('users').doc(uid).update({
          'subscriptionType': 'expired',
          'subscriptionStatus': 'expired',
        });
        return false;
      }
      return true;
    }
    return (data['subscriptionStatus'] as String? ?? 'expired') == 'active' &&
        ['basic', 'premium'].contains(type);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserSubscriptionStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<List<Map<String, dynamic>>> getBillingHistory(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('billing_history')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> updateSubscriptionAfterPayment({
    required String uid,
    required String planType,
    required String amount,
    required String receiptId,
  }) async {
    final now = Timestamp.now();
    final nextBilling = Timestamp.fromDate(now.toDate().add(const Duration(days: 30))); // Monthly billing
    await _db.collection('users').doc(uid).update({
      'subscriptionType': planType,
      'subscriptionStatus': 'active',
      'nextBillingDate': nextBilling,
      'paymentMethod': 'PayPal',
    });
    await _db.collection('users').doc(uid).collection('billing_history').add({
      'plan': planType,
      'amount': amount,
      'date': now,
      'status': 'completed',
      'receiptId': receiptId,
      'paymentMethod': 'PayPal',
    });
  }

  // NEW: ---------- USAGE METRICS ----------
  Future<void> incrementUsage(String uid, String metric) async {
    final ref = _db.collection('users').doc(uid);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final current = snapshot.data()?[metric] ?? 0;
      transaction.update(ref, {metric: current + 1});
    });
  }
}