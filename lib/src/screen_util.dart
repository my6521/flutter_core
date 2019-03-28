import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show window;

class ScreenUtil {

  ///默认设计稿尺寸（单位 dp or pt）
  static double _designW = 360.0;
  static double _designH = 640.0;
  static double _designD = 3.0;

  /**
   * 配置设计稿尺寸（单位 dp or pt）
   * w 宽
   * h 高
   * density 像素密度
   */
  /// 配置设计稿尺寸 屏幕 宽，高，密度。
  /// Configuration design draft size  screen width, height, density.
  static void setDesignWHD(double w, double h, {double density: 3.0}) {
    _designW = w;
    _designH = h;
    _designD = density;
  }

  static double get width {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.size.width;
  }

  static double get height {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.size.height;
  }

  static double get scale {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.devicePixelRatio;
  }

  static double get textScaleFactor {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.textScaleFactor;
  }

  static double get navigationBarHeight {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.top + kToolbarHeight;
  }

  static double get topSafeHeight {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.top;
  }

  static double get bottomSafeHeight {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.bottom;
  }

  static updateStatusBarStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  static double get scaleWidth => width / _designW;

  static double get scaleHeight => height / _designH;

  static double setWidth(double width){
    return width * scaleWidth;
  }

  static double setHeight(double height){
    return height * scaleHeight;
  }
}
