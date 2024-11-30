import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../services/api_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketToken;

  TicketDetailScreen({required this.ticketToken});

  @override
  _TicketDetailScreenState createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> ticketDetails;
  String selectedStatus = "null"; // Estado inicial por defecto.
  final TextEditingController responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ticketDetails = apiService.fetchTicketDetails(widget.ticketToken);
  }

  Future<void> downloadAttachment(
      String ticketToken, String attachmentToken, String fileName) async {
    try {
      final attachment =
          await apiService.fetchAttachment(ticketToken, attachmentToken);

      final data = base64Decode(attachment['data']); // Decodifica el archivo
      final downloadDir = Directory('/storage/emulated/0/Download');
      final filePath = '${downloadDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(data); // Guarda el archivo localmente

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo descargado: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el archivo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Ticket')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ticketDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final ticket = snapshot.data!;
            final attachedTokens = ticket['attachedTokens'] as List<dynamic>?;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID del Ticket: ${widget.ticketToken}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text('Estado actual: ${ticket['status']}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.black, thickness: 1),
                    const SizedBox(height: 10),
                    if (ticket['subject'] == "<string>")
                      const Text('Asunto: No hay información',
                          style: TextStyle(fontSize: 16))
                    else
                      Text(
                          'Asunto: ${ticket['subject'] ?? "No hay información"}',
                          style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    if (ticket['message'] == "<string>")
                      const Text('Mensaje: No hay información',
                          style: TextStyle(fontSize: 16))
                    else
                      Text(
                          'Mensaje: ${ticket['message'] ?? "No hay información"}',
                          style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    if (attachedTokens != null &&
                        attachedTokens.isNotEmpty) ...[
                      const Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Archivos Adjuntos:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: attachedTokens.length,
                            itemBuilder: (context, index) {
                              final attachmentToken = attachedTokens[index];
                              return FutureBuilder<Map<String, dynamic>>(
                                future: apiService.fetchAttachment(
                                    widget.ticketToken, attachmentToken),
                                builder: (context, attachmentSnapshot) {
                                  if (attachmentSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const ListTile(
                                      title: Text('Cargando archivo...'),
                                    );
                                  } else if (attachmentSnapshot.hasError) {
                                    return const ListTile(
                                      title: Text('Error al cargar archivo'),
                                    );
                                  } else if (attachmentSnapshot.hasData) {
                                    final attachment = attachmentSnapshot.data!;
                                    final fileName = attachment['name'];

                                    return ListTile(
                                      title: Text(fileName),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: () => downloadAttachment(
                                            widget.ticketToken,
                                            attachmentToken,
                                            fileName),
                                      ),
                                    );
                                  } else {
                                    return const ListTile(
                                      title: Text('Archivo no disponible'),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                    if (ticket['response'] != null) ...[
                      const Divider(color: Colors.black, thickness: 1),
                      const SizedBox(height: 10),
                      const Text(
                        'Respuesta anterior de un administrativo:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('Respuesta: ${ticket['response']}',
                          style: const TextStyle(fontSize: 16)),
                    ],
                    const SizedBox(height: 10),
                    const Divider(color: Colors.black, thickness: 1),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                            value: "null",
                            child: Text('Seleccionar un estado')),
                        DropdownMenuItem(
                            value: "UNDER_REVIEW", child: Text('En Revisión')),
                        DropdownMenuItem(
                            value: "IN_PROGRESS", child: Text('En Progreso')),
                        DropdownMenuItem(
                            value: "PENDING_INFORMATION",
                            child: Text('Información pendiente')),
                        DropdownMenuItem(
                            value: "RESOLVED", child: Text('Resuelto')),
                        DropdownMenuItem(
                            value: "REJECTED", child: Text('Rechazado')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                      decoration: const InputDecoration(
                          labelText: 'Cambiar el estado del Ticket'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: responseController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Escribe una respuesta',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedStatus == 'null') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Por favor seleccione un estado al cual cambiar.')),
                            );
                          }
                          if (responseController.text.isNotEmpty) {
                            try {
                              await apiService.respondToTicket(
                                widget.ticketToken,
                                selectedStatus,
                                responseController.text,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Respuesta enviada con éxito')),
                              );
                              Navigator.pop(
                                  context); // Regresar a la lista de tickets.
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'El mensaje de respuesta no puede estar vacío')),
                            );
                          }
                        },
                        child: const Text('Responder Ticket'),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return const Center(
                child: Text('No se encontraron detalles del ticket'));
          }
        },
      ),
    );
  }
}
