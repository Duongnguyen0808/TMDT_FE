// ignore_for_file: prefer_final_fields

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class PasswordController extends GetxController {
  RxBool _password = false.obs;

  bool get password => _password.value;
  set setPassword(bool newState) => _password.value = newState;
}
