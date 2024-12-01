import 'package:flutter/material.dart';
import 'tickets_screen.dart';

class FilterTicketsScreen extends StatefulWidget {
  FilterTicketsScreen({super.key});

  @override
  _FilterTicketsScreenState createState() => _FilterTicketsScreenState();
}

class _FilterTicketsScreenState extends State<FilterTicketsScreen> {
  String selectedCategory = '501d4fdf5484485abc01';
  String selectedType = 'CLAIM';
  String selectedStatus = 'RECEIVED';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filtrar Tickets',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 112, 107),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seleccione los filtros para buscar tickets:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: const [
                      DropdownMenuItem(
                          value: '501d4fdf5484485abc01',
                          child: Text('Atención al estudiante')),
                      DropdownMenuItem(
                          value: 'e4f4a97320714992b72c',
                          child: Text('Infraestructura')),
                      DropdownMenuItem(
                          value: '429e6510aa23493d89ef',
                          child: Text('Trámites y procedimientos')),
                      DropdownMenuItem(
                          value: '52784cc432b54f8a8591',
                          child: Text('Servicios tecnológicos')),
                      DropdownMenuItem(
                          value: 'c32ebe4a264f4c6b94e1',
                          child: Text('Docencia y programas académicos')),
                      DropdownMenuItem(
                          value: '6860f0b5ae83478289b6',
                          child: Text('Servicios estudiantiles')),
                      DropdownMenuItem(
                          value: '8980d678af66423b9351',
                          child: Text('Seguridad')),
                      DropdownMenuItem(
                          value: 'f2baf2668952483aafd3',
                          child: Text('Transparencia y ética')),
                      DropdownMenuItem(
                          value: '3462142cf99d4fe78085',
                          child: Text('Calidad del servicio')),
                      DropdownMenuItem(
                          value: 'ba4a81bba964489bb554',
                          child: Text('Medio ambiente y sostenibilidad')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Categoría del ticket',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    decoration: InputDecoration(
                      labelText: 'Tipo de Ticket',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: const [
                      DropdownMenuItem(
                          value: 'RECEIVED', child: Text('Recibido')),
                      DropdownMenuItem(
                          value: 'UNDER_REVIEW', child: Text('En Revisión')),
                      DropdownMenuItem(
                          value: 'IN_PROGRESS', child: Text('En Progreso')),
                      DropdownMenuItem(
                          value: 'PENDING_INFORMATION',
                          child: Text('Información solicitada')),
                      DropdownMenuItem(
                          value: 'RESOLVED', child: Text('Resuelto')),
                      DropdownMenuItem(value: 'CLOSED', child: Text('Cerrado')),
                      DropdownMenuItem(
                          value: 'REJECTED', child: Text('Rechazado')),
                      DropdownMenuItem(
                          value: 'CANCELLED', child: Text('Cancelado')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Estado del Ticket',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketsScreen(
                              categoryToken: selectedCategory,
                              type: selectedType,
                              status: selectedStatus,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar Tickets'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 12, 110, 105),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
