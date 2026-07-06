import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/medication_providers.dart';
import '../../domain/models/local_time.dart';
import '../../domain/models/medication.dart';
import '../../domain/models/medication_enums.dart';
import '../../domain/models/schedule.dart';
import '../medication_presentation.dart';
import '../widgets/dose_form_selector.dart';
import '../widgets/schedule_selector.dart';

/// Create / edit form for a medication.
///
/// When [medicationId] is null the form creates a new entry; otherwise it loads
/// and edits the existing one. Persistence and validation logic delegate to the
/// repository and the schedule value object — the widget only collects input.
class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({this.medicationId, super.key});

  final int? medicationId;

  bool get isEditing => medicationId != null;

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _prescribedForController = TextEditingController();
  final _doseAmountController = TextEditingController();
  final _notesController = TextEditingController();

  MedicationForm _form = MedicationForm.tablet;
  DoseUnit _unit = DoseUnit.mg;
  Schedule _schedule = const Schedule(
    type: ScheduleType.daily,
    times: [LocalTime(9, 0)],
  );

  DateTime? _createdAt;
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loading = true;
      _loadExisting();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericNameController.dispose();
    _prescribedForController.dispose();
    _doseAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final existing = await ref
        .read(medicationRepositoryProvider)
        .findById(widget.medicationId!);
    if (!mounted) return;
    if (existing != null) {
      _nameController.text = existing.name;
      _genericNameController.text = existing.genericName ?? '';
      _prescribedForController.text = existing.prescribedFor ?? '';
      _doseAmountController.text = _trimAmount(existing.doseAmount);
      _notesController.text = existing.notes ?? '';
      _form = existing.form;
      _unit = existing.doseUnit;
      _schedule = existing.schedule;
      _createdAt = existing.createdAt;
    }
    setState(() => _loading = false);
  }

  static String _trimAmount(double amount) =>
      amount == amount.roundToDouble() ? amount.toInt().toString() : '$amount';

  String? _validateScheduleOrError(AppLocalizations l10n) {
    final usesTimes = _schedule.type != ScheduleType.asNeeded;
    if (usesTimes && _schedule.times.isEmpty) {
      return l10n.validationAtLeastOneTime;
    }
    if (_schedule.type == ScheduleType.weekly &&
        (_schedule.daysOfWeek?.isEmpty ?? true)) {
      return l10n.validationSelectDays;
    }
    return null;
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    final scheduleError = _validateScheduleOrError(l10n);
    if (scheduleError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(scheduleError)));
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final repository = ref.read(medicationRepositoryProvider);
    final medication = Medication(
      id: widget.medicationId,
      name: _nameController.text.trim(),
      genericName: _emptyToNull(_genericNameController.text),
      prescribedFor: _emptyToNull(_prescribedForController.text),
      notes: _emptyToNull(_notesController.text),
      form: _form,
      doseUnit: _unit,
      doseAmount: double.parse(_doseAmountController.text.replaceAll(',', '.')),
      schedule: _schedule,
      createdAt: _createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (widget.isEditing) {
        await repository.update(medication);
        ref.invalidate(medicationByIdProvider(widget.medicationId!));
      } else {
        await repository.add(medication);
      }
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? l10n.medicationFormEditTitle
              : l10n.medicationFormAddTitle,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  _SectionTitle(l10n.sectionBasicInfo),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldName,
                      hintText: l10n.fieldNameHint,
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _genericNameController,
                    decoration: InputDecoration(
                      labelText: l10n.fieldGenericName,
                      hintText: l10n.fieldGenericNameHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _prescribedForController,
                    decoration: InputDecoration(
                      labelText: l10n.fieldPrescribedFor,
                      hintText: l10n.fieldPrescribedForHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(l10n.fieldForm),
                  const SizedBox(height: 8),
                  DoseFormSelector(
                    value: _form,
                    onChanged: (form) => setState(() => _form = form),
                  ),

                  const SizedBox(height: 24),
                  _SectionTitle(l10n.sectionDosage),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _doseAmountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.fieldDoseAmount,
                          ),
                          validator: _amountValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<DoseUnit>(
                          initialValue: _unit,
                          decoration: InputDecoration(
                            labelText: l10n.fieldDoseUnit,
                          ),
                          items: [
                            for (final unit in DoseUnit.values)
                              DropdownMenuItem(
                                value: unit,
                                child: Text(unit.label),
                              ),
                          ],
                          onChanged: (unit) {
                            if (unit != null) setState(() => _unit = unit);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _SectionTitle(l10n.sectionSchedule),
                  ScheduleSelector(
                    value: _schedule,
                    onChanged: (schedule) =>
                        setState(() => _schedule = schedule),
                  ),

                  const SizedBox(height: 24),
                  _SectionTitle(l10n.sectionMealRelation),
                  _MealRelationSelector(
                    value: _schedule.mealRelation,
                    onChanged: (relation) => setState(
                      () => _schedule = _schedule.copyWith(
                        mealRelation: relation,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionTitle(l10n.sectionNotes),
                  TextFormField(
                    controller: _notesController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(hintText: l10n.fieldNotesHint),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.commonSave),
                ),
              ),
            ),
    );
  }

  String? _requiredValidator(String? value) =>
      (value == null || value.trim().isEmpty)
      ? context.l10n.validationRequired
      : null;

  String? _amountValidator(String? value) {
    final l10n = context.l10n;
    if (value == null || value.trim().isEmpty) return l10n.validationRequired;
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return l10n.validationInvalidNumber;
    if (parsed <= 0) return l10n.validationPositive;
    return null;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: context.textStyles.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textStyles.labelLarge?.copyWith(
      color: context.colors.onSurfaceVariant,
    ),
  );
}

class _MealRelationSelector extends StatelessWidget {
  const _MealRelationSelector({required this.value, required this.onChanged});

  final MealRelation value;
  final ValueChanged<MealRelation> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RadioGroup<MealRelation>(
      groupValue: value,
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
      child: Column(
        children: [
          for (final relation in MealRelation.values)
            RadioListTile<MealRelation>(
              contentPadding: EdgeInsets.zero,
              value: relation,
              title: Text(relation.label(l10n)),
            ),
        ],
      ),
    );
  }
}
