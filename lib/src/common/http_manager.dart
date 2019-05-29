import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_core/src/common/object_util.dart';

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

  Future<BaseResp<T>> request<T>(String url,
      {data,
      queryParameters,
      method = "get",
      headers,
      onReceiveProgress}) async {
    try {
      CancelToken cancelToken = CancelToken();

      //移除
      List queryParametersList = new List();
      if(ObjectUtil.isNotEmpty(queryParameters)){
        queryParameters.forEach((k,v){
          if(ObjectUtil.isEmpty(queryParameters[k])){
            queryParametersList.add(k);
          }
        });
      }

      for(var k in queryParametersList){
        queryParameters.remove(k);
      }

      ///保存token
      _map[url] = cancelToken;

      Options options = Options(method: method, headers: headers);

      Response response = await _dio.request(url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress);

      _printHttpLog(response);
      bool _status = false;
      String _code;
      String _msg;
      T _data;
      if (response.statusCode == HttpStatus.ok) {
        _status = response.data["IsSuccess"];
        _code = response.data["ErrorCode"];
        _msg = response.data["Message"];
        _data = response.data["Data"];

        if (_status) {
          return new BaseResp(_status, _code, _msg, _data);
        }
      }

      //异常抛出
      return new Future.error(new DioError(
        response: response,
        message: _msg,
        type: DioErrorType.RESPONSE,
      ));
    } catch (e) {
      //异常抛出
      return new Future.error(new DioError(
        message: "data parsing exception...",
        type: DioErrorType.RESPONSE,
      ));
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

  void _printHttpLog(Response response) {
    print(response);
  }

  /// print Data Str.
  void _printDataStr(String tag, Object value) {
    String da = value.toString();
    while (da.isNotEmpty) {
      if (da.length > 512) {
        print("[$tag  ]:   " + da.substring(0, 512));
        da = da.substring(512, da.length);
      } else {
        print("[$tag  ]:   " + da);
        da = "";
      }
    }
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

/// <BaseResp<T> 返回 status code msg data.
class BaseResp<T> {
  bool status;
  String code;
  String msg;
  T data;

  BaseResp(this.status, this.code, this.msg, this.data);

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('{');
    sb.write("\"status\":\"$status\"");
    sb.write(",\"code\":$code");
    sb.write(",\"msg\":\"$msg\"");
    sb.write(",\"data\":\"$data\"");
    sb.write('}');
    return sb.toString();
  }
}
