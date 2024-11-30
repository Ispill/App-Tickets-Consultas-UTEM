import 'package:flutter/material.dart';
import 'tickets_screen.dart';

class FilterTicketsScreen extends StatefulWidget {
  final String categoryToken;
  final String categoryName;

  FilterTicketsScreen(
      {required this.categoryToken, required this.categoryName});

  @override
  _FilterTicketsScreenState createState() => _FilterTicketsScreenState();
}

class _FilterTicketsScreenState extends State<FilterTicketsScreen> {
  String selectedType = 'CLAIM';
  String selectedStatus = 'RECEIVED';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filtrar Tickets de ${widget.categoryName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              items: const [
                DropdownMenuItem(value: 'CLAIM', child: Text('Reclamo')),
                DropdownMenuItem(
                    value: 'SUGGESTION', child: Text('Sugerencia')),
                DropdownMenuItem(
                    value: 'INFORMATION', child: Text('Información')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Tipo de Ticket'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: const [
                DropdownMenuItem(value: 'RECEIVED', child: Text('Recibido')),
                DropdownMenuItem(
                    value: 'UNDER_REVIEW', child: Text('En Revisión')),
                DropdownMenuItem(
                    value: 'IN_PROGRESS', child: Text('En Progreso')),
                DropdownMenuItem(
                    value: 'PENDING_INFORMATION',
                    child: Text('Información solicitada')),
                DropdownMenuItem(value: 'RESOLVED', child: Text('Resuelto')),
                DropdownMenuItem(value: 'CLOSED', child: Text('Cerrado')),
                DropdownMenuItem(value: 'REJECTED', child: Text('Rechazado')),
                DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelado')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Estado del Ticket'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketsScreen(
                      categoryToken: widget.categoryToken,
                      categoryName: widget.categoryName,
                      type: selectedType,
                      status: selectedStatus,
                    ),
                  ),
                );
              },
              child: const Text('Buscar Tickets'),
            ),
          ],
        ),
      ),
    );
  }
}
