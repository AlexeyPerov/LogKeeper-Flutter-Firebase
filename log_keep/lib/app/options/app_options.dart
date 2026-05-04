import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:log_keep/app/theme/theme_constants.dart';

class AppOptions {
  const AppOptions({
    this.themeMode = ThemeMode.system,
    double textScaleFactor = systemTextScaleFactorOption,
    this.timeDilation = 1.0,
    this.platform = TargetPlatform.android,
    this.isTestMode = false,
  }) : _textScaleFactor = textScaleFactor;

  final ThemeMode themeMode;
  final double _textScaleFactor;
  final double timeDilation;
  final TargetPlatform platform;
  final bool isTestMode;

  double textScaleFactor(BuildContext context, {bool useSentinel = false}) {
    if (_textScaleFactor == systemTextScaleFactorOption) {
      return useSentinel
          ? systemTextScaleFactorOption
          : MediaQuery.textScalerOf(context).scale(1.0);
    } else {
      return _textScaleFactor;
    }
  }

  SystemUiOverlayStyle resolvedSystemUiOverlayStyle() {
    final Brightness brightness;
    switch (themeMode) {
      case ThemeMode.light:
        brightness = Brightness.light;
        break;
      case ThemeMode.dark:
        brightness = Brightness.dark;
        break;
      default:
        brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }

    final overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return overlayStyle;
  }

  AppOptions copyWith({
    ThemeMode? themeMode,
    double? textScaleFactor,
    Locale? locale,
    double? timeDilation,
    TargetPlatform? platform,
    bool? isTestMode,
  }) {
    return AppOptions(
      themeMode: themeMode ?? this.themeMode,
      textScaleFactor: textScaleFactor ?? _textScaleFactor,
      timeDilation: timeDilation ?? this.timeDilation,
      platform: platform ?? this.platform,
      isTestMode: isTestMode ?? this.isTestMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppOptions &&
      themeMode == other.themeMode &&
      _textScaleFactor == other._textScaleFactor &&
      timeDilation == other.timeDilation &&
      platform == other.platform &&
      isTestMode == other.isTestMode;

  @override
  int get hashCode => Object.hash(
        themeMode,
        _textScaleFactor,
        timeDilation,
        platform,
        isTestMode,
      );

  static AppOptions of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();
    assert(scope != null, 'ModelBinding ancestor required');
    return scope!.modelBindingState.currentModel;
  }

  static void update(BuildContext context, AppOptions newModel) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();
    assert(scope != null, 'ModelBinding ancestor required');
    scope!.modelBindingState.updateModel(newModel);
  }
}

class ApplyTextOptions extends StatelessWidget {
  const ApplyTextOptions({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final options = AppOptions.of(context);
    final textScaleFactor = options.textScaleFactor(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: child,
    );
  }
}

class _ModelBindingScope extends InheritedWidget {
  const _ModelBindingScope({
    required this.modelBindingState,
    required super.child,
  });

  final _ModelBindingState modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope oldWidget) => true;
}

class ModelBinding extends StatefulWidget {
  const ModelBinding({
    super.key,
    this.initialModel = const AppOptions(),
    required this.child,
  });

  final AppOptions initialModel;
  final Widget child;

  @override
  _ModelBindingState createState() => _ModelBindingState();
}

class _ModelBindingState extends State<ModelBinding> {
  late AppOptions currentModel;
  Timer? _timeDilationTimer;

  @override
  void initState() {
    super.initState();
    currentModel = widget.initialModel;
  }

  @override
  void dispose() {
    _timeDilationTimer?.cancel();
    super.dispose();
  }

  void handleTimeDilation(AppOptions newModel) {
    if (currentModel.timeDilation != newModel.timeDilation) {
      _timeDilationTimer?.cancel();
      _timeDilationTimer = null;
      if (newModel.timeDilation > 1) {
        _timeDilationTimer = Timer(const Duration(milliseconds: 150), () {
          timeDilation = newModel.timeDilation;
        });
      } else {
        timeDilation = newModel.timeDilation;
      }
    }
  }

  void updateModel(AppOptions newModel) {
    if (newModel != currentModel) {
      handleTimeDilation(newModel);
      setState(() {
        currentModel = newModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope(
      modelBindingState: this,
      child: widget.child,
    );
  }
}
