
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../repositories/user_profile_repository.dart';

class StepGoalScreen extends StatefulWidget {
  final UserProfileRepository repository;

  const StepGoalScreen({
    super.key,
    required this.repository,
  });

  @override
  State<StepGoalScreen> createState() => _StepGoalScreenState();
}

class _StepGoalScreenState extends State<StepGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  static const Color _coral = Color(0xFFEE846F);
  static const Color _blue = Color(0xFF65A7C1);

  @override
  void initState() {
    super.initState();
    _loadStepGoal();
  }

  Future<void> _loadStepGoal() async {
    try {
      final profile = await widget.repository.getProfile();

      if (profile == null) {
        throw StateError('Kullanıcı profili bulunamadı.');
      }

      if (!mounted) return;

      _goalController.text = profile.dailyStepGoal.toString();

      setState(() {
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Adım hedefi yüklenemedi.';
        _isLoading = false;
      });
    }
  }

  String? _validateGoal(String? value) {
    final goal = int.tryParse((value ?? '').trim());

    if (goal == null || goal < 100 || goal > 100000) {
      return '100 ile 100000 arasında bir hedef giriniz.';
    }

    return null;
  }

  void _changeGoal(int amount) {
  if (_isSaving) return;

  final current = int.tryParse(_goalController.text.trim()) ?? 0;

  final next = (current + amount).clamp(100, 100000);

  _goalController.value = TextEditingValue(
    text: next.toString(),
    selection: TextSelection.collapsed(
      offset: next.toString().length,
    ),
  );
}

  Future<void> _saveStepGoal() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    try {
      final goal = int.parse(_goalController.text.trim());

      await widget.repository.updateStepGoal(goal);

      if (!mounted) return;

      context.pop(true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adım hedefi kaydedilemedi.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _stepButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: _isSaving ? null : onPressed,
      icon: Icon(icon),
      iconSize: 25,
      style: IconButton.styleFrom(
        foregroundColor: _blue,
        backgroundColor: _blue.withValues(alpha: 0.10),
        fixedSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _goalInputCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _blue.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Günlük hedef',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _stepButton(
                icon: Icons.remove_rounded,
                onPressed: () => _changeGoal(-500),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: TextFormField(
                 controller: _goalController,
enabled: !_isSaving,
textAlign: TextAlign.center,
onChanged: (value) {
  setState(() {});
},
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    errorMaxLines: 2,
                  ),
                  validator: _validateGoal,
                ),
              ),

              const SizedBox(width: 8),

              _stepButton(
                icon: Icons.add_rounded,
                onPressed: () => _changeGoal(500),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'adım / gün',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Hedefini kendine göre ayarlayabilirsin.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendationCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface
            : const Color(0xFFEAF3F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _blue.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFE9AE36),
            size: 30,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Öneri',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '10.000 adım yaygın kullanılan bir günlük '
                  'hedeftir. Kendi aktivite düzeyine göre '
                  'daha düşük bir hedefle başlayıp '
                  'zamanla artırabilirsin.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final background = isDark
        ? theme.scaffoldBackgroundColor
        : const Color(0xFFF7FAFC);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Adım Hedefi'),
        centerTitle: true,
        backgroundColor: background,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              24, 24, 24, 16,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    color: _coral.withValues(alpha: 0.10),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.track_changes_rounded,
                                    color: _coral,
                                    size: 44,
                                  ),
                                ),

                                const SizedBox(height: 22),

                                Text(
                                  'Günlük Adım Hedefin',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  'Her gün ulaşmak istediğin adım '
                                  'sayısını belirle.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),

                                const SizedBox(height: 30),

                                _goalInputCard(),

                                const SizedBox(height: 22),

                                _recommendationCard(),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            24, 12, 24, 16,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed:
                                  _isSaving ? null : _saveStepGoal,
                              style: FilledButton.styleFrom(
                                backgroundColor: _coral,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Değişiklikleri Kaydet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
