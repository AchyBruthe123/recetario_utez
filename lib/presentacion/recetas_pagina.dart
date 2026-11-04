import 'package:flutter/material.dart';

import 'recetas_view_model.dart';
import 'tarjeta_receta.dart';

class RecetasPagina extends StatefulWidget {
  const RecetasPagina({super.key, required this.vm});

  final RecetasViewModel vm;

  @override
  State<RecetasPagina> createState() => _RecetasPaginaState();
}

class _RecetasPaginaState extends State<RecetasPagina> {
  final _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _buscar() => widget.vm.buscar(_controlador.text);

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return Scaffold(
      appBar: AppBar(title: const Text('Recetario UTEZ')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                key: const Key('busqueda'),
                controller: _controlador,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _buscar(),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: vm,
              builder: (context, _) => FilledButton(
                key: const Key('buscar'),
                onPressed: vm.cargando ? null : _buscar,
                child: const Text('Buscar recetas'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListenableBuilder(
                listenable: vm,
                builder: (context, _) => _contenido(vm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(RecetasViewModel vm) {
    return switch (vm.estado) {
      RecetasInicial() => const _Mensaje(
        'Escribe una receta o déjalo vacío y toca Buscar recetas.',
      ),
      RecetasCargando() => const Center(child: CircularProgressIndicator()),
      RecetasVacias(:final busqueda) => _Mensaje(
        busqueda.isEmpty
            ? 'No hay recetas disponibles.'
            : 'No encontramos recetas para "$busqueda".',
      ),
      RecetasFallidas(:final mensaje) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Mensaje(mensaje),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: vm.reintentar,
            child: const Text('Reintentar'),
          ),
        ],
      ),
      RecetasListas(:final recetas, :final total) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Mostrando ${recetas.length} de $total recetas · '
                  'Rápidas: ${vm.rapidas}',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recetas.length,
              itemBuilder: (context, i) => TarjetaReceta(receta: recetas[i]),
            ),
          ),
        ],
      ),
    };
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(texto, textAlign: TextAlign.center),
    ),
  );
}