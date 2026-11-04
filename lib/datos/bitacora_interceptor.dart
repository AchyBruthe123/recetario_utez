import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class BitacoraInterceptor extends Interceptor {
  BitacoraInterceptor({void Function(String linea)? escribir})
      : _escribir = escribir ?? _escribirEnDeveloperLog;

  final void Function(String linea) _escribir;

  static const _llaveCronometro = 'bitacora_cronometro';

  static void _escribirEnDeveloperLog(String linea) =>
      developer.log(linea, name: 'recetario');

  static int _milisegundos(RequestOptions options) {
    final cronometro = options.extra[_llaveCronometro];
    return cronometro is Stopwatch ? cronometro.elapsedMilliseconds : 0;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_llaveCronometro] = Stopwatch()..start();
    _escribir('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final o = response.requestOptions;
    _escribir(
      '← ${response.statusCode} ${o.method} ${o.path} (${_milisegundos(o)} ms)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    final codigo = err.response?.statusCode;
    final partes = <String>[
      '✗',
      err.type.name,
      if (codigo != null) '$codigo',
      o.method,
      o.path,
      '(${_milisegundos(o)} ms)',
    ];
    _escribir(partes.join(' '));
    handler.next(err);
  }
}