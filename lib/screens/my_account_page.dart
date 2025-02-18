import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'dart:io'; // Import for file handling

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  MyAccountPageState createState() => MyAccountPageState();
}

class MyAccountPageState extends State<MyAccountPage> {
  File? profileImage; // This will hold the uploaded image

  // Function to pick an image from the gallery or camera
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path); // Set the picked image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickImage, // Open the image picker on tap
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImage == null
                    ? const NetworkImage(
                        'https://example.com/default_profile_picture.jpg')
                    : FileImage(profileImage!) as ImageProvider,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Namakula Allen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black color for the name
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'allenglain9@gmail.com.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black, // Black color for the email
              ),
            ),
            const SizedBox(height: 20),
            buildAccountOptions(),
          ],
        ),
      ),
    );
  }

  Widget buildAccountOptions() {
    return Column(
      children: [
        buildAccountOption(
          icon: Icons.person,
          title: 'Edit Profile',
          onTap: () {
            // TODO: Implement edit profile functionality
            print('Edit Profile tapped');
          },
        ),
        buildAccountOption(
          icon: Icons.settings,
          title: 'Account Settings',
          onTap: () {
            // TODO: Implement account settings functionality
            print('Account Settings tapped');
          },
        ),
        buildAccountOption(
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {
            // TODO: Implement help & support functionality
            print('Help & Support tapped');
          },
        ),
        buildAccountOption(
          icon: Icons.exit_to_app,
          title: 'Logout',
          onTap: () {
            // TODO: Implement logout functionality
            print('Logout tapped');
          },
        ),
      ],
    );
  }

  Widget buildAccountOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF794022), // Set the icon color to brown
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
