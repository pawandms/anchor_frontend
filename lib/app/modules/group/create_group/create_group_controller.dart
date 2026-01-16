import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';

class CreateGroupController extends GetxController {
  final groupNameController = TextEditingController();
  final selectedContacts = <UserModel>[].obs;
  final availableContacts = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  @override
  void onClose() {
    groupNameController.dispose();
    super.onClose();
  }

  void loadContacts() {
    availableContacts.value = [
      UserModel(id: '1', name: 'Alice Johnson', email: 'alice@example.com'),
      UserModel(id: '2', name: 'Bob Smith', email: 'bob@example.com'),
      UserModel(id: '3', name: 'Charlie Brown', email: 'charlie@example.com'),
    ];
  }

  void toggleContact(UserModel contact) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
    } else {
      selectedContacts.add(contact);
    }
  }

  void createGroup() {
    if (groupNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter group name');
      return;
    }
    if (selectedContacts.length < 2) {
      Get.snackbar('Error', 'Please select at least 2 contacts');
      return;
    }
    Get.back();
    Get.snackbar('Success', 'Group created successfully');
  }
}
