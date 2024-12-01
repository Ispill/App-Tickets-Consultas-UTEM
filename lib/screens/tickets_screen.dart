import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import '../services/api_service.dart';
import 'ticket_detail_screen.dart';

class TicketsScreen extends StatefulWidget {
  final String categoryToken;
  final String type; // Tipo de ticket
  final String status; // Estado del ticket

  TicketsScreen({
    required this.categoryToken,
    required this.type,
    required this.status,
  });

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> ticketsFuture;

  @override
  void initState() {
    super.initState();
    ticketsFuture = fetchTickets(); // Cargar los tickets inicialmente
  }

  Future<List<dynamic>> fetchTickets() {
    return apiService.fetchTickets(
        widget.categoryToken, widget.type, widget.status);
  }

  void reloadTickets() {
    setState(() {
      ticketsFuture = fetchTickets(); // Recargar los tickets
    });
  }

  String formatDate(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    final formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    final formattedTime = DateFormat('HH:mm').format(parsedDate);
    return '$formattedDate a las $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tickets filtrados',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 112, 107),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No hay tickets disponibles.',
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData) {
            final tickets = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                var subject = ticket['subject'] ?? 'Sin Asunto';
                if (subject == "<string>") subject = "Sin asunto";
                final updated = ticket['updated'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketDetailScreen(ticketToken: ticket['token']),
                        ),
                      );
                      if (result == true) {
                        reloadTickets();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            updated.isNotEmpty
                                ? 'Última actualización: ${formatDate(updated)}'
                                : 'Sin fecha de actualización',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay tickets disponibles'));
          }
        },
      ),
    );
  }
}
