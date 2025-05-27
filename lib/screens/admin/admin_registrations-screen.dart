import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRegistrationsScreen extends StatelessWidget {
  const AdminRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrations")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('registrations')
            .orderBy('registrationDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final registrations = snapshot.data!.docs;
          if (registrations.isEmpty) {
            return const Center(child: Text("No registrations found"));
          }

          return ListView.builder(
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final reg = registrations[index].data() as Map<String, dynamic>;
              final name = "${reg['firstName']} ${reg['lastName']}";
              final email = reg['email'];
              final phone = reg['phone'];
              final nationalId = reg['nationalId'];
              final payment = reg['paymentMethod'];
              final timestamp = reg['registrationDate'] as Timestamp?;
              final formattedDate = _formatTimestamp(timestamp);

              return ListTile(
                leading: const Icon(Icons.person, color: Colors.orange),
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: $email'),
                    Text('Phone: $phone'),
                    Text('NIN: $nationalId'),
                    Text('Payment: $payment'),
                    Text('Registered: $formattedDate'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
