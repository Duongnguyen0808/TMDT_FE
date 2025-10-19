import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AdditiveObs extends GetxController {
  int id;
  String title;
  String price;
  RxBool isChecked = false.obs;

  AdditiveObs({
    required this.id,
    required this.title,
    required this.price,
    bool isChecked = false,
  }) {
    this.isChecked.value = isChecked;
  }

  void toggleChecked() {
    isChecked.value = !isChecked.value;
  }
}
