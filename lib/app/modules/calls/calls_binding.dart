import 'package:get/get.dart';
import 'calls_controller.dart';

class CallsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallsController>(() => CallsController());
  }
}
