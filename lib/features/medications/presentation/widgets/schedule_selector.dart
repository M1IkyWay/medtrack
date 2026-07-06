import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/models/local_time.dart';
import '../../domain/models/medication_enums.dart';
import '../../domain/models/schedule.dart';
import '../medication_presentation.dart';

/// Editor for a [Schedule] — shows only the fields the selected [ScheduleType]
/// needs. Stateful only to own the numeric controllers, so typing in them
/// doesn't reset the cursor; everything else is derived from [value].
class ScheduleSelector extends StatefulWidget {
  const ScheduleSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final Schedule value;
  final ValueChanged<Schedule> onChanged;

  @override
  State<ScheduleSelector> createState() => _ScheduleSelectorState();
}

class _ScheduleSelectorState extends State<ScheduleSelector> {
  late final TextEditingController _intervalController;
  late final TextEditingController _totalDosesController;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController(
      text: widget.value.intervalDays?.toString() ?? '',
    );
    _totalDosesController = TextEditingController(
      text: widget.value.totalDoses?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _totalDosesController.dispose();
    super.dispose();
  }

  Schedule get _schedule => widget.value;

  void _emit(Schedule schedule) => widget.onChanged(schedule);

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    final time = LocalTime(picked.hour, picked.minute);
    if (_schedule.times.contains(time)) return;
    _emit(_schedule.copyWith(times: [..._schedule.times, time]..sort()));
  }

  void _removeTime(LocalTime time) {
    _emit(
      _schedule.copyWith(
        times: _schedule.times.where((t) => t != time).toList(),
      ),
    );
  }

  void _toggleWeekday(int day) {
    final days = {...?_schedule.daysOfWeek};
    if (!days.remove(day)) days.add(day);
    final sorted = days.toList()..sort();
    _emit(_schedule.copyWith(daysOfWeek: sorted));
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _schedule.startDate : _schedule.endDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    _emit(
      isStart
          ? _schedule.copyWith(startDate: picked)
          : _schedule.copyWith(endDate: picked),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = _schedule.type;
    final usesTimes = type != ScheduleType.asNeeded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<ScheduleType>(
          initialValue: type,
          decoration: InputDecoration(labelText: l10n.fieldScheduleType),
          items: [
            for (final t in ScheduleType.values)
              DropdownMenuItem(value: t, child: Text(t.label(l10n))),
          ],
          onChanged: (t) {
            if (t != null) _emit(_schedule.copyWith(type: t));
          },
        ),
        if (usesTimes) ...[
          const SizedBox(height: 16),
          _FieldLabel(l10n.fieldTimes),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final time in _schedule.times)
                InputChip(
                  label: Text(time.format()),
                  onDeleted: () => _removeTime(time),
                ),
              ActionChip(
                avatar: const Icon(Symbols.add, size: 18),
                label: Text(l10n.addTime),
                onPressed: _addTime,
              ),
            ],
          ),
        ],
        if (type == ScheduleType.weekly) ...[
          const SizedBox(height: 16),
          _FieldLabel(l10n.fieldDaysOfWeek),
          const SizedBox(height: 8),
          _WeekdayPicker(
            selected: {...?_schedule.daysOfWeek},
            onToggle: _toggleWeekday,
          ),
        ],
        if (type == ScheduleType.everyNDays) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _intervalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.fieldIntervalDays),
            onChanged: (v) =>
                _emit(_schedule.copyWith(intervalDays: int.tryParse(v))),
          ),
        ],
        if (type == ScheduleType.course) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _totalDosesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.fieldTotalDoses),
            onChanged: (v) =>
                _emit(_schedule.copyWith(totalDoses: int.tryParse(v))),
          ),
        ],
        if (type != ScheduleType.once && type != ScheduleType.asNeeded) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: l10n.fieldStartDate,
                  date: _schedule.startDate,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: l10n.fieldEndDate,
                  date: _schedule.endDate,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
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

class _WeekdayPicker extends StatelessWidget {
  const _WeekdayPicker({required this.selected, required this.onToggle});

  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    // A reference Monday (2024-01-01) to derive localized weekday short names.
    final reference = DateTime(2024, 1, 1);
    final formatter = DateFormat.E(locale);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var day = 1; day <= 7; day++)
          FilterChip(
            selected: selected.contains(day),
            label: Text(
              formatter.format(reference.add(Duration(days: day - 1))),
            ),
            onSelected: (_) => onToggle(day),
          ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final text = date == null
        ? context.l10n.notSet
        : DateFormat.yMMMd(locale).format(date!);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(text),
      ),
    );
  }
}
