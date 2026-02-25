import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormulaPrepSheetPage extends StatefulWidget {
  const FormulaPrepSheetPage({super.key});

  @override
  State<FormulaPrepSheetPage> createState() => _FormulaPrepSheetPageState();
}

class _FormulaPrepSheetPageState extends State<FormulaPrepSheetPage> {
  final _formKey = GlobalKey<FormState>();

  final _patientNameCtrl = TextEditingController();
  final _mrnCtrl = TextEditingController();
  final _intakeCtrl = TextEditingController();
  final _frequencyCtrl = TextEditingController();
  final _formulaKcalCtrl = TextEditingController();
  final _additivesCtrl = TextEditingController(); // optional
  final _rnPhoneCtrl = TextEditingController();

  @override
  void dispose() {
    _patientNameCtrl.dispose();
    _mrnCtrl.dispose();
    _intakeCtrl.dispose();
    _frequencyCtrl.dispose();
    _formulaKcalCtrl.dispose();
    _additivesCtrl.dispose();
    _rnPhoneCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    BuildContext context,
    String label, {
    String? hint,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: theme.colorScheme.surface,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        fontWeight: FontWeight.w600,
      ),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        fontStyle: FontStyle.italic,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _patientNameCtrl.clear();
    _mrnCtrl.clear();
    _intakeCtrl.clear();
    _frequencyCtrl.clear();
    _formulaKcalCtrl.clear();
    _additivesCtrl.clear();
    _rnPhoneCtrl.clear();
    setState(() {});
  }

  void _saveForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.6,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Formula Prep Sheet',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: theme.colorScheme.surface,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DefaultTextStyle(
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.25,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _previewRow(
                              context,
                              'Patient Name',
                              _patientNameCtrl.text,
                            ),
                            _previewRow(context, 'MRN', _mrnCtrl.text),
                            _previewRow(context, 'Intake', _intakeCtrl.text),
                            _previewRow(
                              context,
                              'Frequency',
                              _frequencyCtrl.text,
                            ),
                            _previewRow(
                              context,
                              'Formula + kcal/oz',
                              _formulaKcalCtrl.text,
                            ),
                            if (_additivesCtrl.text.trim().isNotEmpty)
                              _previewRow(
                                context,
                                'Additives',
                                _additivesCtrl.text,
                              ),
                            _previewRow(
                              context,
                              'RN + phone#',
                              _rnPhoneCtrl.text,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(CupertinoIcons.check_mark),
                    label: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _previewRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.tertiary,
      appBar: AppBar(
        title: Text(
          'Formula Prep Sheet',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Clear form',
            onPressed: _clearForm,
            icon: const Icon(CupertinoIcons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Card(
            elevation: 3,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _gap(),
                    TextFormField(
                      controller: _patientNameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        context,
                        'Patient name',
                        hint: 'e.g., John Smith',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _gap(),
                    TextFormField(
                      controller: _mrnCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        context,
                        'MRN (number only)',
                        hint: 'e.g., 1234567',
                      ),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Required';
                        if (!RegExp(r'^\d+$').hasMatch(t)) return 'Digits only';
                        return null;
                      },
                    ),
                    _gap(),
                    TextFormField(
                      controller: _intakeCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        context,
                        'Intake',
                        hint: 'e.g., 90 mL',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _gap(),
                    TextFormField(
                      controller: _frequencyCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        context,
                        'Frequency',
                        hint: 'e.g., continuous or q3h',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _gap(),
                    TextFormField(
                      controller: _formulaKcalCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        context,
                        'Formula + kcal/oz',
                        hint: 'e.g., Elecare 24 kcal/oz',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _gap(),
                    TextFormField(
                      controller: _additivesCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        context,
                        'Additives (optional)',
                        hint: 'e.g., CAA or beneprotein',
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      controller: _rnPhoneCtrl,
                      textInputAction: TextInputAction.done,
                      decoration: _decoration(
                        context,
                        'RN + phone#',
                        hint: 'e.g., D. Siaj 12345',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(' Save  '),
                        onPressed: _saveForm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _gap() => const SizedBox(height: 14);
}
