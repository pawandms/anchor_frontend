import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../data/models/call_model.dart';
import 'calls_controller.dart';

class CallsView extends GetView<CallsController> {
  const CallsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.calls),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.calls.isEmpty) {
          return const Center(
            child: Text('No call history'),
          );
        }

        return ListView.builder(
          itemCount: controller.calls.length,
          itemBuilder: (context, index) {
            final call = controller.calls[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  call.caller.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(call.caller.name),
              subtitle: Row(
                children: [
                  Icon(
                    call.isIncoming
                        ? (call.status == CallStatus.missed
                            ? Icons.call_missed
                            : Icons.call_received)
                        : Icons.call_made,
                    size: 16,
                    color: call.status == CallStatus.missed
                        ? AppColors.error
                        : AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, HH:mm').format(call.startTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (call.duration != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      call.durationString,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  call.type == CallType.video
                      ? Icons.videocam
                      : Icons.call,
                  color: AppColors.primary,
                ),
                onPressed: () => controller.makeCall(call.caller, call.type),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar('Info', 'New call feature coming soon');
        },
        child: const Icon(Icons.add_call),
      ),
    );
  }
}
