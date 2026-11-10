
import 'package:flutter/material.dart';
import '../repositories/user_profile_repository.dart';

class UserInfoScreen extends StatefulWidget {
  final UserProfileRepository repository;

  const UserInfoScreen({
    super.key,
    required this.repository,
  });

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _stepGoalController = TextEditingController(
    text: '10000',
  );

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = await widget.repository.getProfile();

      if (!mounted) return;

      if (profile != null) {
        _heightController.text = profile.heightCm.toString();
        _weightController.text = profile.weightKg.toString();
        _stepGoalController.text = profile.dailyStepGoal.toString();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil bilgileri yüklenemedi.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateHeight(String? value) {
    final height = double.tryParse(
      (value ?? '').trim().replaceAll(',', '.'),
    );

    if (height == null || height < 80 || height > 250) {
      return 'Geçerli bir boy giriniz (80-250 cm).';
    }

    return null;
  }

  String? _validateWeight(String? value) {
    final weight = double.tryParse(
      (value ?? '').trim().replaceAll(',', '.'),
    );

    if (weight == null || weight < 20 || weight > 500) {
      return 'Geçerli bir kilo giriniz (20-500 kg).';
    }

    return null;
  }

  String? _validateStepGoal(String? value) {
    final goal = int.tryParse((value ?? '').trim());

    if (goal == null || goal < 100 || goal > 100000) {
      return '100 ile 100000 arasında bir hedef giriniz.';
    }

    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      await widget.repository.saveProfile(
        heightCm: double.parse(
          _heightController.text.trim().replaceAll(',', '.'),
        ),
        weightKg: double.parse(
          _weightController.text.trim().replaceAll(',', '.'),
        ),
        dailyStepGoal: int.parse(
          _stepGoalController.text.trim(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bilgileriniz başarıyla kaydedildi.'),
        ),
      );

      // Routing aşamasında PermissionsScreen'e geçilecek.
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bilgiler kaydedilemedi.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _stepGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                CircleAvatar(
                  radius: 42,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 44,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Hakkında Biraz Bilgi',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Aktivite hedeflerini sana göre kişiselleştirelim.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Boy',
                    suffixText: 'cm',
                    prefixIcon: Icon(Icons.height_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateHeight,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Kilo',
                    suffixText: 'kg',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateWeight,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _stepGoalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Günlük Adım Hedefi',
                    suffixText: 'adım',
                    prefixIcon: Icon(Icons.directions_walk_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateStepGoal,
                ),

                const SizedBox(height: 48),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Devam Et'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
