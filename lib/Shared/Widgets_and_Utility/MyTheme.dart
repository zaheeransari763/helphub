import 'dart:async';

class ThemeClass {
  void dispose() {
    themeController.close();
  }

  StreamController themeController = StreamController<MyTheme>();
  void changeTheme(MyTheme theme) {
    themeController.sink.add(theme);
  }
}

enum MyTheme { Light, Dark, System }
