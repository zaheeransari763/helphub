library flutter_login;

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/login_theme.dart';
import 'src/widgets/null_widget.dart';
import 'theme.dart';
import 'src/dart_helper.dart';
import 'src/color_helper.dart';
import 'src/providers/auth.dart';
import 'src/providers/login_messages.dart';
import 'src/regex.dart';
import 'src/widgets/auth_card.dart';
import 'src/widgets/fade_in.dart';
import 'src/widgets/hero_text.dart';
export 'src/models/login_data.dart';
export 'src/providers/login_messages.dart';
export 'src/providers/login_theme.dart';
import 'src/constants.dart';


class _Header extends StatefulWidget {
  _Header({
    this.logoPath,
    this.logoTag,
    this.title,
    this.titleTag,
    this.height = 250.0,
    this.logoController,
    this.titleController,
    @required this.loginTheme,
  });

  final String logoPath;
  final String logoTag;
  final String title;
  final String titleTag;
  final double height;
  final LoginTheme loginTheme;
  final AnimationController logoController;
  final AnimationController titleController;

  @override
  __HeaderState createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
  double _titleHeight = 0.0;

  /// https://stackoverflow.com/a/56997641/9449426
  double getEstimatedTitleHeight() {
    if (DartHelper.isNullOrEmpty(widget.title)) {
      return 0.0;
    }

    final theme = Theme.of(context);
    final renderParagraph = RenderParagraph(
      TextSpan(
        text: widget.title,
        style: theme.textTheme.headline3.copyWith(
          fontSize: widget.loginTheme.beforeHeroFontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    renderParagraph.layout(BoxConstraints());

    return renderParagraph
        .getMinIntrinsicHeight(widget.loginTheme.beforeHeroFontSize)
        .ceilToDouble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _titleHeight = getEstimatedTitleHeight();
  }

  @override
  void didUpdateWidget(_Header oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.title != oldWidget.title) {
      _titleHeight = getEstimatedTitleHeight();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gap = 5.0;
    final logoHeight = min(widget.height - _titleHeight - gap, kMaxLogoHeight);
    final displayLogo = widget.logoPath != null && logoHeight >= kMinLogoHeight;

    Widget logo = displayLogo
        ? Image.asset(
            widget.logoPath,
            filterQuality: FilterQuality.high,
            height: logoHeight,
          )
        : NullWidget();

    if (widget.logoTag != null) {
      logo = Hero(
        tag: widget.logoTag,
        child: logo,
      );
    }

    Widget title;
    if (widget.titleTag != null && !DartHelper.isNullOrEmpty(widget.title)) {
      title = HeroText(
        widget.title,
        key: kTitleKey,
        tag: widget.titleTag,
        largeFontSize: widget.loginTheme.beforeHeroFontSize,
        smallFontSize: widget.loginTheme.afterHeroFontSize,
        style: theme.textTheme.headline3,
        viewState: ViewState.enlarged,
      );
    } else if (!DartHelper.isNullOrEmpty(widget.title)) {
      title = Text(
        widget.title,
        key: kTitleKey,
        style: theme.textTheme.headline3,
      );
    } else {
      title = null;
    }

    return SizedBox(
      height: widget.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (displayLogo)
            FadeIn(
              controller: widget.logoController,
              offset: .25,
              fadeDirection: FadeDirection.topToBottom,
              child: logo,
            ),
          SizedBox(height: gap),
          FadeIn(
            controller: widget.titleController,
            offset: .5,
            fadeDirection: FadeDirection.topToBottom,
            child: title,
          ),
        ],
      ),
    );
  }
}

class FlutterLoginCustom extends StatefulWidget {
  FlutterLoginCustom({
    Key key,
    @required this.onSignup,
    @required this.onLogin,
    @required this.onRecoverPassword,
    this.title,
    this.logo,
    this.messages,
    this.theme,
    this.onSubmitAnimationCompleted,
    this.logoTag,
    this.titleTag,
    this.showDebugButtons = false,
  }) : super(key: key);

  /// Called when the user hit the submit button when in sign up mode
  final AuthCallback onSignup;

  /// Called when the user hit the submit button when in login mode
  final AuthCallback onLogin;

  /// Called when the user hit the submit button when in recover password mode
  final RecoverCallback onRecoverPassword;

  /// The large text above the login [Card], usually the app or company name
  final String title;

  /// The path to the asset image that will be passed to the `Image.asset()`
  final String logo;

  /// Describes all of the labels, text hints, button texts and other auth
  /// descriptions
  final LoginMessages messages;

  /// FlutterLoginCustom's theme. If not specified, it will use the default theme as
  /// shown in the demo gifs and use the colorsheme in the closest `Theme`
  /// widget
  final LoginTheme theme;

  /// Email validating logic, Returns an error string to display if the input is
  /// invalid, or null otherwise

  /// Same as [emailValidator] but for password

  /// Called after the submit animation's completed. Put your route transition
  /// logic here. Recommend to use with [logoTag] and [titleTag]
  final Function onSubmitAnimationCompleted;

  /// Hero tag for logo image. If not specified, it will simply fade out when
  /// changing route
  final String logoTag;

  /// Hero tag for title text. Need to specify `LoginTheme.beforeHeroFontSize`
  /// and `LoginTheme.afterHeroFontSize` if you want different font size before
  /// and after hero animation
  final String titleTag;

  /// Display the debug buttons to quickly forward/reverse login animations. In
  /// release mode, this will be overrided to false regardless of the value
  /// passed in
  final bool showDebugButtons;

  static final FormFieldValidator<String> defaultEmailValidator = (value) {
    if (value.isEmpty || !Regex.email.hasMatch(value)) {
      return 'Invalid email!';
    }
    return null;
  };

  static final FormFieldValidator<String> defaultPasswordValidator = (value) {
    if (value.isEmpty || value.length <= 2) {
      return 'Password is too short!';
    }
    return null;
  };

  @override
  _FlutterLoginState createState() => _FlutterLoginState();
}

class _FlutterLoginState extends State<FlutterLoginCustom>
    with TickerProviderStateMixin {
  final GlobalKey<AuthCardState> authCardKey = GlobalKey();
  static const loadingDuration = const Duration(milliseconds: 400);
  AnimationController _loadingController;
  AnimationController _logoController;
  AnimationController _titleController;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _logoController.forward();
          _titleController.forward();
        }
        if (status == AnimationStatus.reverse) {
          _logoController.reverse();
          _titleController.reverse();
        }
      });
    _logoController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    );
    _titleController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    );

    Future.delayed(const Duration(seconds: 1), () {
      _loadingController.forward();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _loadingController.dispose();
    _logoController.dispose();
    _titleController.dispose();
  }

  void _reverseHeaderAnimation() {
    if (widget.logoTag == null) {
      _logoController.reverse();
    }
    if (widget.titleTag == null) {
      _titleController.reverse();
    }
  }

  ThemeData _mergeTheme({ThemeData theme, LoginTheme loginTheme}) {
    final originalPrimaryColor = loginTheme.primaryColor ?? theme.primaryColor;
    final primaryDarkShades = getDarkShades(originalPrimaryColor);
    final primaryColor = primaryDarkShades.length == 1
        ? lighten(primaryDarkShades.first)
        : primaryDarkShades.first;
    final primaryColorDark = primaryDarkShades.length >= 3
        ? primaryDarkShades[2]
        : primaryDarkShades.last;
    final accentColor = loginTheme.accentColor ?? theme.accentColor;
    final errorColor = loginTheme.errorColor ?? theme.errorColor;
    // the background is a dark gradient, force to use white text if detect default black text color
    final isDefaultBlackText = theme.textTheme.headline3.color ==
        Typography.blackMountainView.headline3.color;
    final titleStyle = theme.textTheme.headline3
        .copyWith(
          color: loginTheme.accentColor ??
              (isDefaultBlackText
                  ? Colors.white
                  : theme.textTheme.headline3.color),
          fontSize: loginTheme.beforeHeroFontSize,
          fontWeight: FontWeight.w300,
        )
        .merge(loginTheme.titleStyle);
    final textStyle = theme.textTheme.bodyText2
        .copyWith(color: Colors.black54)
        .merge(loginTheme.bodyStyle);
    final textFieldStyle = theme.textTheme.subtitle1
        .copyWith(color: Colors.black.withOpacity(.65), fontSize: 14)
        .merge(loginTheme.textFieldStyle);
    final buttonStyle = theme.textTheme.button
        .copyWith(color: Colors.white)
        .merge(loginTheme.buttonStyle);
    final cardTheme = loginTheme.cardTheme;
    final inputTheme = loginTheme.inputTheme;
    final buttonTheme = loginTheme.buttonTheme;
    final roundBorderRadius = BorderRadius.circular(100);

    LoginThemeHelper.loginTextStyle = titleStyle;

    return theme.copyWith(
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      accentColor: accentColor,
      errorColor: errorColor,
      cardTheme: theme.cardTheme.copyWith(
        clipBehavior: cardTheme.clipBehavior,
        color: cardTheme.color ?? theme.cardColor,
        elevation: cardTheme.elevation ?? 12.0,
        margin: cardTheme.margin ?? const EdgeInsets.all(4.0),
        shape: cardTheme.shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: inputTheme.filled,
        fillColor: inputTheme.fillColor ??
            Color.alphaBlend(
              primaryColor.withOpacity(.07),
              Colors.grey.withOpacity(.04),
            ),
        contentPadding: inputTheme.contentPadding ??
            const EdgeInsets.symmetric(vertical: 4.0),
        errorStyle: inputTheme.errorStyle ?? TextStyle(color: errorColor),
        labelStyle: inputTheme.labelStyle,
        enabledBorder: inputTheme.enabledBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: roundBorderRadius,
            ),
        focusedBorder: inputTheme.focusedBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        errorBorder: inputTheme.errorBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor),
              borderRadius: roundBorderRadius,
            ),
        focusedErrorBorder: inputTheme.focusedErrorBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        disabledBorder: inputTheme.disabledBorder ?? inputTheme.border,
      ),
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        backgroundColor: buttonTheme?.backgroundColor ?? primaryColor,
        splashColor: buttonTheme.splashColor ?? theme.accentColor,
        elevation: buttonTheme.elevation ?? 4.0,
        highlightElevation: buttonTheme.highlightElevation ?? 2.0,
        shape: buttonTheme.shape ?? StadiumBorder(),
      ),
      // put it here because floatingActionButtonTheme doesnt have highlightColor property
      highlightColor:
          loginTheme.buttonTheme.highlightColor ?? theme.highlightColor,
      textTheme: theme.textTheme.copyWith(
        headline3: titleStyle,
        bodyText2: textStyle,
        subtitle1: textFieldStyle,
        button: buttonStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginTheme = widget.theme ?? LoginTheme();
    final theme = _mergeTheme(theme: Theme.of(context), loginTheme: loginTheme);
    final deviceSize = MediaQuery.of(context).size;
    const cardInitialHeight = 300;
    final cardTopPosition = deviceSize.height / 2 - cardInitialHeight / 2;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: widget.messages ?? LoginMessages(),
        ),
        ChangeNotifierProvider(
          create: (context) => Auth(
            onLogin: widget.onLogin,
            onSignup: widget.onSignup,
            onRecoverPassword: widget.onRecoverPassword,
          ),
        ),
      ],
      child:  Theme(
        data: theme,
        child: AuthCard(
          theme: widget.theme,
          key: authCardKey,
          padding: EdgeInsets.only(top: cardTopPosition),
          loadingController: _loadingController,
          onSubmit: _reverseHeaderAnimation,
          onSubmitCompleted: widget.onSubmitAnimationCompleted,
        ),
      ),
      
    );
  }
}
