import 'package:get/get.dart';
import '../../data/models/call_model.dart';
import '../../data/models/user_model.dart';

class CallsController extends GetxController {
  final calls = <CallModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCalls();
  }

  Future<void> loadCalls() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      calls.value = _getDummyCalls();
    } finally {
      isLoading.value = false;
    }
  }

  void makeCall(UserModel user, CallType type) {
    Get.snackbar('Info', '${type == CallType.video ? "Video" : "Voice"} calling ${user.name}...');
  }

  List<CallModel> _getDummyCalls() {
    return [
      CallModel(
        id: '1',
        caller: UserModel(id: '1', name: 'John Doe', email: 'john@example.com'),
        participants: [],
        type: CallType.video,
        status: CallStatus.ended,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 2, minutes: -15)),
        duration: const Duration(minutes: 15),
        isIncoming: true,
      ),
      CallModel(
        id: '2',
        caller: UserModel(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
        participants: [],
        type: CallType.voice,
        status: CallStatus.missed,
        startTime: DateTime.now().subtract(const Duration(hours: 5)),
        isIncoming: true,
      ),
    ];
  }
}
