import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class CategoryController extends GetxController {
  RxString _category = ''.obs;
  String get categoryValue => _category.value;

  set updateCategory(String value) {
    _category.value = value;
  }

  RxString _title = ''.obs;
  String get titleValue => _title.value;
  set updateTitle(String value) {
    _title.value = value;
  }
}
