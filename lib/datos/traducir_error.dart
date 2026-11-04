import 'package:dio/dio.dart';
import '../dominio/falla_red.dart';

FallaRed traducirError(DioException e) {
  switch (e.type) {

    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const TiempoAgotado();

    case DioExceptionType.badResponse:
      final codigo = e.response?.statusCode ?? 0;
      if (codigo >= 500) {
        return ErrorDelServidor(codigo);
      } else {
        return PeticionRechazada(codigo);
      }

    case DioExceptionType.unknown:
      if (e.error is FormatException) {
        return const RespuestaInvalida();
      }
      return const SinConexion();

    case DioExceptionType.cancel:
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return const SinConexion();
  }
}