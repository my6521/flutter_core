import 'package:dio/dio.dart';

class HttpConfig {
  HttpConfig({
    this.options,
    this.interceptorsWrapper,
    this.pem,
    this.pKCSPath,
    this.pKCSPwd,
  });

  /// Options.
  BaseOptions options;

  /// 拦截
  InterceptorsWrapper interceptorsWrapper;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PEM证书内容.
  String pem;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PKCS12 证书路径.
  String pKCSPath;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PKCS12 证书密码.
  String pKCSPwd;
}