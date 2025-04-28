// ignore_for_file: unused_import

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'signin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  MyAccountPageState createState() => MyAccountPageState();
}

class MyAccountPageState extends State<MyAccountPage> {
  XFile? profileImage;
  Uint8List? profileImageBytes;
  String fullName = 'Loading...';
  String userEmail = 'Loading...';
  String profileImageUrl = '';
  bool isLoading = true;
  bool isUploadingImage = false;
  bool hasImageLoadError = false;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    fetchUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    try {
      setState(() {
        isLoading = true;
      });

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error: No user is currently logged in.')),
          );
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          userEmail = currentUser.email ?? 'No email found';
        });
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            fullName = userData['fullName'] ?? 'No name found';
            profileImageUrl = userData['profileImage'] ?? '';
            hasImageLoadError = false;
          });
        }
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'fullName': currentUser.displayName ?? 'New User',
          'email': currentUser.email,
          'profileImage': '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            fullName = currentUser.displayName ?? 'New User';
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            profileImage = pickedFile;
            profileImageBytes = imageBytes;
            hasImageLoadError = false;
          });
        }
        await uploadImageToImgBB(pickedFile);
      }
    } catch (e) {
      if (mounted) {
        print('Error picking image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> uploadImageToImgBB(XFile pickedFile) async {
    if (mounted) {
      setState(() {
        isUploadingImage = true;
      });
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user logged in'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      Uint8List imageBytes = await pickedFile.readAsBytes();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.imgbb.com/1/upload?key=f53f2b2d663578cc4c7ddba11a81a8dc'),
      );

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename:
            'profile_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = jsonDecode(responseString);

      if (jsonResponse['success'] == true) {
        String imageUrl = jsonResponse['data']['url'];

        print('ImgBB upload successful. URL: $imageUrl');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'profileImage': imageUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            profileImageUrl = imageUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception(
            'ImgBB upload failed: ${jsonResponse['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error uploading image to ImgBB: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });
      }
    }
  }

  Future<void> editProfile() async {
    nameController.text = fullName;
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      hintText: 'Leave empty to keep current password',
                    ),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    validator: (value) {
                      if (passwordController.text.isNotEmpty &&
                          value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  setState(() {
                    isLoading = true;
                  });

                  try {
                    User? currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      String newName = nameController.text.trim();

                      // Update name in Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .update({
                        'fullName': newName,
                        'lastUpdated': FieldValue.serverTimestamp(),
                      });

                      // Update password if provided
                      if (passwordController.text.isNotEmpty) {
                        await currentUser
                            .updatePassword(passwordController.text);
                      }

                      setState(() {
                        fullName = newName;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    String errorMessage = 'Error updating profile';
                    if (e.code == 'requires-recent-login') {
                      errorMessage =
                          'For security, please re-login before changing password';
                    } else {
                      errorMessage = 'Error: ${e.message}';
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating profile: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void retryLoadingProfileImage() {
    if (profileImageUrl.isNotEmpty) {
      setState(() {
        hasImageLoadError = false;
        profileImageUrl =
            '$profileImageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Account',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF794022),
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF794022)))
          : RefreshIndicator(
              onRefresh: fetchUserData,
              color: const Color(0xFF794022),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: isUploadingImage ? null : pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.transparent,
                              backgroundImage: profileImageBytes != null
                                  ? MemoryImage(profileImageBytes!)
                                  : (profileImageUrl.isNotEmpty &&
                                          !hasImageLoadError
                                      ? NetworkImage(profileImageUrl)
                                          as ImageProvider
                                      : null),
                              onBackgroundImageError:
                                  profileImageUrl.isNotEmpty &&
                                          !hasImageLoadError
                                      ? (_, __) {
                                          print(
                                              'Error loading image from URL: $profileImageUrl');
                                          if (mounted) {
                                            setState(() {
                                              hasImageLoadError = true;
                                            });
                                          }
                                        }
                                      : null,
                              child: (profileImageUrl.isEmpty &&
                                          profileImageBytes == null) ||
                                      hasImageLoadError
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Icon(Icons.person,
                                            size: 60, color: Colors.grey),
                                        if (hasImageLoadError)
                                          Positioned(
                                            bottom: 0,
                                            child: GestureDetector(
                                              onTap: retryLoadingProfileImage,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red[400],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.refresh,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF794022),
                                shape: BoxShape.circle,
                              ),
                              child: isUploadingImage
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF794022),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.person,
                                  color: Color(0xFF794022)),
                              title: const Text('Edit Profile'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: editProfile,
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.settings,
                                  color: Color(0xFF794022)),
                              title: const Text('Account Settings'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Account settings coming soon')),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.exit_to_app,
                                  color: Color(0xFF794022)),
                              title: const Text('Logout'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: logout,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
