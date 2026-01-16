import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_values.dart';
import 'create_group_controller.dart';

class CreateGroupView extends GetView<CreateGroupController> {
  const CreateGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          TextButton(
            onPressed: controller.createGroup,
            child: const Text('CREATE'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group Name Input
          Padding(
            padding: const EdgeInsets.all(AppValues.paddingM),
            child: TextField(
              controller: controller.groupNameController,
              decoration: const InputDecoration(
                hintText: 'Group Name',
                prefixIcon: Icon(Icons.group),
              ),
            ),
          ),
          const Divider(),
          // Selected Contacts
          Obx(() {
            if (controller.selectedContacts.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: AppValues.paddingM),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.selectedContacts.length,
                itemBuilder: (context, index) {
                  final contact = controller.selectedContacts[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: AppValues.paddingS),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                contact.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => controller.toggleContact(contact),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contact.name.split(' ').first,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
          const Divider(),
          // Available Contacts
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.availableContacts.length,
              itemBuilder: (context, index) {
                final contact = controller.availableContacts[index];
                final isSelected = controller.selectedContacts.contains(contact);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => controller.toggleContact(contact),
                  title: Text(contact.name),
                  subtitle: Text(contact.email),
                  secondary: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      contact.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  activeColor: AppColors.primary,
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
