import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class HttpManager {
  static HttpManager _instance;
  Dio _dio;
  Map<String, CancelToken> _map = Map();
  BaseOptions _options = getDefOptions();
  static final HttpManager _singleton = HttpManager._internal();

  static HttpManager getInstance() {
    return _singleton;
  }

  factory HttpManager() {
    return _singleton;
  }

  HttpManager._internal() {
    _dio = new Dio(_options);
    //发送请求拦截处理，例如：添加token使用
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      return options;
    }, onResponse: (Response response) {
      return response; // continue
    }, onError: (DioError e) {
      return e; //continue
    }));
  }

  Dio getDio() {
    return _dio;
  }

  request(String url,
      {data, method = "get", headers, onReceiveProgress, context}) async {
    try {
      if (context != null) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return Center(
                child: CircularProgressIndicator(),
              );
            });
      }

      CancelToken cancelToken = CancelToken();

      ///保存token
      _map[url] = cancelToken;

      Options options = Options(method: method, headers: headers);

      Response response = await _dio.request(url,
          data: data,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress);

      if (context != null) {
        Navigator.pop(context);
      }

      return response.data;
    } catch (e) {
      print("请求错误:$e");
      return null;
    }
  }

  post(String url, {data, method = "post", context}) async {
    try {
      if (context != null) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return Center(
                child: CircularProgressIndicator(),
              );
            });
      }
      CancelToken cancelToken = CancelToken();

      ///保存token
      _map[url] = cancelToken;

      Options options = Options(method: method);

      Response response = await _dio.post(url,
          data: data, options: options, cancelToken: cancelToken);

      if (context != null) {
        Navigator.pop(context);
      }

      return response.data;
    } catch (e) {
      print("请求错误:$e");
      return null;
    }
  }

  ///下载
  download(String url, {ProgressCallback progressCallback}) async {
    CancelToken cancelToken = CancelToken();

    ///保存token
    _map[url] = cancelToken;

    ///获取应用文件目录
    Directory directory = await getExternalStorageDirectory();

    var lastIndexOf = url.lastIndexOf('/');

    ///获取文件名称
    var dstname = url.substring(lastIndexOf + 1, url.length);

    ///获取cookie本地存储地址
    var path = Directory(join(directory.path, dstname)).path;

    Response response = await _dio.download(url, path,
        onReceiveProgress: progressCallback, cancelToken: cancelToken);

    if (response.statusCode == HttpStatus.ok) {
      return true;
    } else {
      return false;
    }
  }

  void setConfig(HttpConfig config) {
    _mergeOption(config.options);
    _dio.options = _options;
    if (config.interceptorsWrapper != null) {
      _dio.interceptors.clear();
      _dio.interceptors.add(config.interceptorsWrapper);
    }
  }

  static BaseOptions getDefOptions() {
    BaseOptions options = new BaseOptions();
    options.contentType = ContentType.parse("application/json");
    options.connectTimeout = 1000 * 10;
    options.receiveTimeout = 1000 * 20;
    return options;
  }

  void _mergeOption(BaseOptions opt) {
    _options.method = opt.method ?? _options.method;
    _options.headers = (new Map.from(_options.headers))..addAll(opt.headers);
    _options.baseUrl = opt.baseUrl ?? _options.baseUrl;
    _options.connectTimeout = opt.connectTimeout ?? _options.connectTimeout;
    _options.receiveTimeout = opt.receiveTimeout ?? _options.receiveTimeout;
    _options.responseType = opt.responseType ?? _options.responseType;
    _options.extra = (new Map.from(_options.extra))..addAll(opt.extra);
    _options.contentType = opt.contentType ?? _options.contentType;
    _options.validateStatus = opt.validateStatus ?? _options.validateStatus;
    _options.followRedirects = opt.followRedirects ?? _options.followRedirects;
  }

  void cancelRequest(String url) {
    _map[url]?.cancel(url);
  }
}

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
