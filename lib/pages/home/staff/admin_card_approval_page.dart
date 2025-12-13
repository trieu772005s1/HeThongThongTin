import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminCardApprovalPage extends StatelessWidget {
  const AdminCardApprovalPage({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _pendingCards() {
    return FirebaseFirestore.instance
        .collection('card_applications')
        .where('status', isEqualTo: 'PENDING')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _approve(String uid, int limit) async {
    final adminId = FirebaseAuth.instance.currentUser!.uid;
    final now = FieldValue.serverTimestamp();
    final batch = FirebaseFirestore.instance.batch();

    // update application
    batch.update(
      FirebaseFirestore.instance.collection('card_applications').doc(uid),
      {'status': 'APPROVED', 'approvedAt': now, 'approvedBy': adminId},
    );

    // update user
    batch.update(FirebaseFirestore.instance.collection('users').doc(uid), {
      'creditCard.status': 'APPROVED',
      'creditCard.limit': limit,
      'creditCard.approvedAt': now,
      'creditCard.approvedBy': adminId,
    });

    await batch.commit();
  }

  Future<void> _reject(String uid) async {
    final adminId = FirebaseAuth.instance.currentUser!.uid;
    final now = FieldValue.serverTimestamp();
    final batch = FirebaseFirestore.instance.batch();

    batch.update(
      FirebaseFirestore.instance.collection('card_applications').doc(uid),
      {'status': 'REJECTED', 'rejectedAt': now, 'rejectedBy': adminId},
    );

    batch.update(FirebaseFirestore.instance.collection('users').doc(uid), {
      'creditCard.status': 'REJECTED',
    });

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duyệt thẻ tín dụng')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _pendingCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có hồ sơ chờ duyệt'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(
                    data['email'] ?? 'Không có email',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hạn mức yêu cầu: ${data['limit']} VND'),
                      Text(
                        'Địa chỉ: ${data['province']} - ${data['district']}',
                      ),
                      Text('Chứng minh: ${data['financialMethod']}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approve(doc.id, data['limit']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _reject(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
