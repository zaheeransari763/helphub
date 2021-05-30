import 'package:helphub/imports.dart';
import 'package:helphub/core/enums/ViewState.dart';
import 'package:helphub/core/helpers/shared_preferences_helper.dart';

class BaseModel extends ChangeNotifier {
  final sharedPreferencesHelper = locator<SharedPreferencesHelper>();
  ViewState _state = ViewState.Idle;
  ViewState _state2 = ViewState.Idle;
  ViewState _state3 = ViewState.Idle;

  ViewState get state => _state;
  ViewState get state2 => _state2;
  ViewState get state3 => _state3;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void setState2(ViewState viewState) {
    _state2 = viewState;
    notifyListeners();
  }

  void setState3(ViewState viewState) {
    _state3 = viewState;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_state == ViewState.Idle && _state2 == ViewState.Idle) super.dispose();
  }
}
