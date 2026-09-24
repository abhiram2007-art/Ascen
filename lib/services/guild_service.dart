import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/guild_model.dart';
import '../models/user_model.dart';

class GuildService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'guilds';

  Future<String> createGuild(String name, String description, String leaderId) async {
    final docRef = _firestore.collection(_collection).doc();
    final guild = GuildModel(
      id: docRef.id,
      name: name,
      description: description,
      leaderId: leaderId,
      memberIds: [leaderId],
      createdAt: DateTime.now(),
    );

    // Batch write to create guild and update user
    final batch = _firestore.batch();
    batch.set(docRef, guild.toMap());
    
    final userRef = _firestore.collection('users').doc(leaderId);
    batch.update(userRef, {'guildId': docRef.id});

    await batch.commit();
    return docRef.id;
  }

  Future<void> joinGuild(String guildId, String userId) async {
    final batch = _firestore.batch();
    
    final guildRef = _firestore.collection(_collection).doc(guildId);
    batch.update(guildRef, {
      'memberIds': FieldValue.arrayUnion([userId])
    });

    final userRef = _firestore.collection('users').doc(userId);
    batch.update(userRef, {'guildId': guildId});

    await batch.commit();
  }

  Future<void> leaveGuild(String guildId, String userId, bool isLeader) async {
    // Handling leader leaving is complex. We'll simplify for now: they just leave.
    // If last member leaves, we should ideally delete the guild.
    final batch = _firestore.batch();
    
    final guildRef = _firestore.collection(_collection).doc(guildId);
    batch.update(guildRef, {
      'memberIds': FieldValue.arrayRemove([userId])
    });

    final userRef = _firestore.collection('users').doc(userId);
    batch.update(userRef, {'guildId': FieldValue.delete()});

    await batch.commit();
  }

  Stream<GuildModel?> getGuild(String guildId) {
    return _firestore.collection(_collection).doc(guildId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return GuildModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Stream<List<GuildModel>> getTopGuilds({int limit = 50}) {
    return _firestore.collection(_collection)
      .orderBy('totalXP', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => GuildModel.fromMap(doc.data(), doc.id)).toList();
      });
  }

  Future<void> addGuildXP(String guildId, int amount) async {
    await _firestore.collection(_collection).doc(guildId).update({
      'totalXP': FieldValue.increment(amount),
    });
    // Level calculation could be handled here via a cloud function,
    // but we can do a client side check or just rely on totalXP.
  }
}
