import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../services/session_manager.dart';
import '../services/screenshot_protection.dart';
import '../models/sensitive_data.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> with WidgetsBindingObserver {
  final StorageService _storageService = StorageService();
  final FirebaseService _firebaseService = FirebaseService();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _creditCardController = TextEditingController();
  final TextEditingController _ssnController = TextEditingController();
  
  String? _fcmToken;
  String? _userId;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SessionManager().resumeSession();
    ScreenshotProtection.enableProtection();
    _firebaseService.onDataDeleted = _onDataDeletedRemotely;
    _loadData();
  }

  void _onDataDeletedRemotely() {
    if (mounted) {
      _loadData();
      _showSnackBar('🔴 Datos eliminados remotamente', isError: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    _creditCardController.dispose();
    _ssnController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _storageService.getSensitiveData();
      final token = await _firebaseService.getToken();
      final userId = await _storageService.getUserId();
      
      setState(() {
        _emailController.text = data.userEmail;
        _passwordController.text = data.password;
        _creditCardController.text = data.creditCard;
        _ssnController.text = data.ssn;
        _fcmToken = token;
        _userId = userId;
        _isLoading = false;
      });

      print('----------------------');
      print('FCM Token: $token');
      print('User ID: $userId');
      print('----------------------');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error al cargar datos: $e', isError: true);
    }
  }

  Future<void> _saveData() async {
    try {
      final data = SensitiveData(
        userEmail: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        creditCard: _creditCardController.text.trim(),
        ssn: _ssnController.text.trim(),
      );
      
      await _storageService.saveSensitiveData(data);
      _showSnackBar('✅ Datos guardados');
    } catch (e) {
      _showSnackBar('Error al guardar: $e', isError: true);
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar'),
        content: const Text('¿Eliminar todos los datos sensibles?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteAllSensitiveData();
        await _loadData();
        _showSnackBar('🔴 Datos sensibles eliminados');
      } catch (e) {
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  Future<void> _generateSampleData() async {
    try {
      await _storageService.saveSensitiveData(SensitiveData.sample());
      await _loadData();
      _showSnackBar('✅ Datos de ejemplo generados');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📱 Información del Dispositivo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User ID:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              SelectableText(
                _userId ?? 'Cargando...',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              const Text(
                'FCM Token:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              SelectableText(
                _fcmToken ?? 'Cargando...',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Para borrado remoto, envía:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      '{\n  "to": "$_fcmToken",\n  "data": {\n    "action": "DELETE_DATA",\n    "userId": "$_userId"\n  }\n}',
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _userId ?? ''));
              _showSnackBar('User ID copiado');
            },
            child: const Text('Copiar User ID'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _fcmToken ?? ''));
              _showSnackBar('FCM Token copiado');
            },
            child: const Text('Copiar Token'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Sensibles'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Ver información',
            onPressed: _showInfoDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Eliminar todos',
            onPressed: _deleteAllData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '🔐 Información Confidencial',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildSensitiveField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildSensitiveField(
                    controller: _creditCardController,
                    label: 'Tarjeta de Crédito',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildSensitiveField(
                    controller: _ssnController,
                    label: 'Número de Seguro Social',
                    icon: Icons.badge,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Cambios'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _generateSampleData,
                    icon: const Icon(Icons.autorenew),
                    label: const Text('Generar Datos de Ejemplo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildSensitiveField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
