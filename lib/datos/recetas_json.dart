import '../dominio/receta.dart';

Dificultad dificultadDesdeTexto(Object? valor) => switch (valor) {
  'Easy' => Dificultad.facil,
  'Medium' => Dificultad.media,
  'Hard' => Dificultad.dificil,
  _ => Dificultad.desconocida,
};

List<String> _listaDeTextosOpcional(Object? valor, String campo) {
  if (valor == null) return const [];
  if (valor is! List) {
    throw FormatException('"$campo" debe ser una lista');
  }
  final resultado = <String>[];
  for (final elemento in valor) {
    if (elemento is! String) {
      throw FormatException('"$campo" debe contener solo textos');
    }
    resultado.add(elemento);
  }
  return resultado;
}

Receta recetaDesdeJson(Map<String, dynamic> json) {
  return switch (json) {
    {
    'id': int id,
    'name': String nombre,
    'cuisine': String cocina,
    'prepTimeMinutes': int preparacion,
    'cookTimeMinutes': int coccion,
    'servings': int porciones,
    'rating': num calificacion,
    } =>
        Receta(
          id: id,
          nombre: nombre,
          cocina: cocina,
          dificultad: dificultadDesdeTexto(json['difficulty']),
          minutosPreparacion: preparacion,
          minutosCoccion: coccion,
          porciones: porciones,
          calificacion: calificacion.toDouble(),
          etiquetas: _listaDeTextosOpcional(json['tags'], 'tags'),
          ingredientes: _listaDeTextosOpcional(json['ingredients'], 'ingredients'),
        ),
    _ => throw const FormatException('Receta con campos faltantes o de otro tipo'),
  };
}

PaginaRecetas paginaDesdeJson(Map<String, dynamic> json) {
  return switch (json) {
    {'recipes': List<dynamic> lista, 'total': int total} => PaginaRecetas(
      recetas: _recetasDesdeLista(lista),
      total: total,
    ),
    _ => throw const FormatException('Página sin "recipes" (lista) o "total" (int)'),
  };
}

List<Receta> _recetasDesdeLista(List<dynamic> lista) {
  final recetas = <Receta>[];
  for (final elemento in lista) {
    if (elemento is! Map<String, dynamic>) {
      throw const FormatException('Cada elemento de "recipes" debe ser un objeto');
    }
    recetas.add(recetaDesdeJson(elemento));
  }
  return recetas;
}