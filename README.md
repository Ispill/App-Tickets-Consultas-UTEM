# Documentación Técnica

---

## Configuración

### Requisitos Previos
- **Flutter SDK**: Versión 3.0 o superior.
- **Dart**: Versión 2.17 o superior.
- **Editor de Código**: Visual Studio Code, Android Studio o cualquier otro editor compatible con Flutter.
- **Dispositivo `(Recomendado)` o Emulador** Android.
- **Acceso a Internet** para interactuar con los servicios API necesarios.

### Instalación de Dependencias

1. Clone el repositorio:
   ```bash
   git clone https://github.com/Ispill/Administrativo-UTEM.git
   cd Administrativo-UTEM
   ```

2. Instale las dependencias del proyecto:
   ```bash
   flutter pub get
   ```

3. Verifique que todo esté configurado correctamente:
   ```bash
   flutter doctor
   ```
   Asegúrese de que no haya errores críticos.

### Configuración de Permisos

1. Agregue permisos de escritura y lectura en el archivo `AndroidManifest.xml` en la carpeta raíz de la aplicación (`android/app/src/profile/`):
   ```xml
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   ```

2. Configure el acceso al directorio de descargas en el archivo `AndroidManifest.xml` en la carpeta raíz de la aplicación (`android/app/src/main/`):
   ```xml
   <application android:requestLegacyExternalStorage="true">
   ```

3. Asegúrese de que el directorio `assets` y el archivo `var.env` estén correctamente configurados en el archivo `pubspec.yaml`.

---

## Despliegue

### Ejecución en un Entorno Local

1. Conecte un dispositivo físico o inicie un emulador de Android.
2. Ejecute el proyecto:
   ```bash
   flutter run
   ```

### Creación del Build (no recomendado)

1. Genere un APK en modo release:
   ```bash
   flutter build apk --release
   ```
2. Encuentre el APK generado en el directorio `build/app/outputs/flutter-apk/`.

---

## Uso de la Pantalla

### Funcionalidades Principales

#### Visualización de Detalles del Ticket
- **ID del Ticket**: Copiable al portapapeles.
- **Asunto y Mensaje**: Mostrados en un formato limpio y accesible.

#### Gestión de Archivos Adjuntos
- Descargue archivos adjuntos directamente al directorio de descargas del dispositivo.

#### Cambiar Estado del Ticket
- Actualice el estado del ticket seleccionando opciones predefinidas del menú desplegable.

#### Responder Ticket
- Permite enviar una respuesta escrita junto con el cambio de estado.

#### Eliminar Ticket
- Incluye una confirmación previa antes de eliminar el ticket permanentemente.

### Comportamiento en Casos Especiales
- Si faltan datos o archivos adjuntos, la pantalla muestra mensajes informativos.
- Manejo de errores en caso de fallas en las operaciones API.

---

## Integración con la API

### Servicios API Utilizados
- **Obtener Detalles del Ticket**:
  ```dart
  apiService.fetchTicketDetails(ticketToken);
  ```
- **Descargar Archivos Adjuntos**:
  ```dart
  apiService.fetchAttachment(ticketToken, attachmentToken);
  ```
- **Eliminar Ticket**:
  ```dart
  apiService.deleteTicket(ticketToken);
  ```
- **Enviar Respuesta**:
  ```dart
  apiService.respondToTicket(ticketToken, selectedStatus, responseMessage);
  ```
... entre otros.

---

## Solución de Problemas

### Problemas Comunes
1. **Permisos Negados**:
   - Asegúrese de otorgar los permisos de almacenamiento en el dispositivo.

2. **Errores de Conexión a la API**:
   - Verifique la configuración de red y que el backend esté en funcionamiento.

3. **Archivos no Descargados**:
   - Confirme que la ruta al directorio de descargas sea accesible en el dispositivo.

### Depuración
Utilice el modo de depuración de Flutter para inspeccionar problemas:
```bash
flutter run --debug
```

---

## Notas Adicionales
- Probar todas las funcionalidades en dispositivos reales para garantizar compatibilidad y correcto funcionamiento es lo ideal.
- Obtenga el token JWT de la página https://api.sebastian.cl/ ingresando con una cuenta de Google con dominio "@utem.cl" y agreguelo como variable de entorno en el archivo *var.env*.
