import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/enums/habit_enums.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../domain/entities/habit.dart';
import '../../providers/app_providers.dart';
import '../../providers/habit_providers.dart';
import '../../providers/notification_providers.dart';
import '../../widgets/common/custom_text_field.dart';

/// Screen for creating and editing habits
class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId, this.isEditing = false});
  final String? habitId;
  final bool isEditing;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  // final _formKey = GlobalKey<FormState>(); // TODO: Add form validation
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetCountController = TextEditingController(text: '1');
  final _unitController = TextEditingController();

  HabitCategory _selectedCategory = HabitCategory.health;
  HabitDifficulty _selectedDifficulty = HabitDifficulty.easy;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  DateTime? _reminderTime;
  bool _hasReminder = false;
  bool _isLoading = false;

  // Validation errors
  String? _nameError;
  String? _descriptionError;
  String? _targetCountError;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.habitId != null) {
      _loadHabitData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetCountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _loadHabitData() async {
    setState(() => _isLoading = true);

    try {
      final habitAsync = ref.read(habitByIdProvider(widget.habitId!));
      final habit = habitAsync.when(
        data: (habit) => habit,
        loading: () => null,
        error: (_, __) => null,
      );

      if (habit != null && mounted) {
        setState(() {
          _nameController.text = habit.name;
          _descriptionController.text = habit.description;
          _selectedCategory = habit.category;
          _selectedDifficulty = habit.difficulty;
          _selectedFrequency = habit.frequency;
          _targetCountController.text = habit.targetCount.toString();
          _unitController.text = habit.unit ?? '';
          _reminderTime = habit.reminderTime;
          _hasReminder = habit.reminderTime != null;
        });
      }
    } on Exception {
      if (mounted) {
        _showErrorDialog('Failed to load habit data');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateForm() {
    var isValid = true;

    setState(() {
      _nameError = null;
      _descriptionError = null;
      _targetCountError = null;
    });

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Habit name is required');
      isValid = false;
    } else if (_nameController.text.trim().length < 2) {
      setState(() => _nameError = 'Habit name must be at least 2 characters');
      isValid = false;
    } else if (_nameController.text.trim().length > 50) {
      setState(() => _nameError = 'Habit name must be less than 50 characters');
      isValid = false;
    }

    // Validate description
    if (_descriptionController.text.trim().isEmpty) {
      setState(() => _descriptionError = 'Description is required');
      isValid = false;
    } else if (_descriptionController.text.trim().length < 5) {
      setState(
        () => _descriptionError = 'Description must be at least 5 characters',
      );
      isValid = false;
    } else if (_descriptionController.text.trim().length > 200) {
      setState(
        () =>
            _descriptionError = 'Description must be less than 200 characters',
      );
      isValid = false;
    }

    // Validate target count
    final targetCountText = _targetCountController.text.trim();
    if (targetCountText.isEmpty) {
      setState(() => _targetCountError = 'Target count is required');
      isValid = false;
    } else {
      final targetCount = int.tryParse(targetCountText);
      if (targetCount == null || targetCount < 1) {
        setState(
          () => _targetCountError = 'Target count must be a positive number',
        );
        isValid = false;
      } else if (targetCount > 999) {
        setState(
          () => _targetCountError = 'Target count must be less than 1000',
        );
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _saveHabit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final targetCount = int.parse(_targetCountController.text.trim());
      final unit = _unitController.text.trim().isEmpty
          ? null
          : _unitController.text.trim();

      if (widget.isEditing && widget.habitId != null) {
        // Update existing habit
        final habitAsync = ref.read(habitByIdProvider(widget.habitId!));
        final existingHabit = habitAsync.when(
          data: (habit) => habit,
          loading: () => null,
          error: (_, __) => null,
        );

        if (existingHabit != null) {
          final updatedHabit = existingHabit.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            difficulty: _selectedDifficulty,
            frequency: _selectedFrequency,
            reminderTime: _hasReminder ? _reminderTime : null,
            colorValue: AppTheme.getCategoryColor(
              _selectedCategory.name,
            ).toARGB32(),
            targetCount: targetCount,
            unit: unit,
          );

          await ref.read(habitRepositoryProvider).updateHabit(updatedHabit);
        }
      } else {
        // Create new habit
        final newHabit = Habit(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          difficulty: _selectedDifficulty,
          frequency: _selectedFrequency,
          createdAt: DateTime.now(),
          reminderTime: _hasReminder ? _reminderTime : null,
          colorValue: AppTheme.getCategoryColor(
            _selectedCategory.name,
          ).toARGB32(),
          targetCount: targetCount,
          unit: unit,
        );

        await ref.read(habitRepositoryProvider).createHabit(newHabit);
      }

      // Schedule notification if reminder is set
      final notificationNotifier = ref.read(habitNotificationProvider.notifier);
      if (widget.isEditing && widget.habitId != null) {
        // For editing, we need to get the updated habit from the repository
        final updatedHabitAsync = ref.read(habitByIdProvider(widget.habitId!));
        final updatedHabit = updatedHabitAsync.when(
          data: (habit) => habit,
          loading: () => null,
          error: (_, __) => null,
        );
        if (updatedHabit != null) {
          await notificationNotifier.updateHabitNotification(updatedHabit);
        }
      }

      // Refresh habits list
      ref
        ..invalidate(habitsProvider)
        ..invalidate(activeHabitsProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } on Exception {
      if (mounted) {
        _showErrorDialog('Failed to save habit. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final time = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.systemGrey4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () =>
                        Navigator.pop(context, _reminderTime ?? DateTime.now()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: _reminderTime ?? DateTime.now(),
                onDateTimeChanged: (time) => _reminderTime = time,
              ),
            ),
          ],
        ),
      ),
    );

    if (time != null) {
      setState(() {
        _reminderTime = time;
        _hasReminder = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.isEditing ? 'Edit Habit' : 'New Habit'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _saveHabit,
          child: Text(
            'Save',
            style: TextStyle(
              color: _isLoading ? CupertinoColors.systemGrey : null,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 12),

              CustomTextField(
                placeholder: 'Habit name (e.g., "Morning Run")',
                controller: _nameController,
                errorText: _nameError,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
              ),
              const SizedBox(height: 16),

              CustomTextArea(
                placeholder: 'Describe your habit and why it matters to you...',
                controller: _descriptionController,
                errorText: _descriptionError,
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // Category Section
              _buildSectionHeader('Category'),
              const SizedBox(height: 12),
              _buildCategoryPicker(),
              const SizedBox(height: 24),

              // Difficulty Section
              _buildSectionHeader('Difficulty'),
              const SizedBox(height: 12),
              _buildDifficultyPicker(),
              const SizedBox(height: 24),

              // Frequency Section
              _buildSectionHeader('Frequency'),
              const SizedBox(height: 12),
              _buildFrequencyPicker(),
              const SizedBox(height: 24),

              // Target & Unit Section
              _buildSectionHeader('Target'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      placeholder: 'Count',
                      controller: _targetCountController,
                      errorText: _targetCountError,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      placeholder: 'Unit (optional, e.g., "pages", "minutes")',
                      controller: _unitController,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reminder Section
              _buildSectionHeader('Reminder'),
              const SizedBox(height: 12),
              _buildReminderSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: CupertinoColors.label,
    ),
  );

  Widget _buildCategoryPicker() => DecoratedBox(
    decoration: BoxDecoration(
      color: CupertinoColors.systemBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CupertinoColors.systemGrey4),
    ),
    child: Column(
      children: HabitCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? CupertinoColors.systemBlue.withValues(alpha: 0.1)
                  : null,
              border: category != HabitCategory.values.last
                  ? const Border(
                      bottom: BorderSide(color: CupertinoColors.systemGrey5),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  category.icon,
                  size: 24,
                  color: isSelected
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? CupertinoColors.systemBlue
                          : CupertinoColors.label,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    CupertinoIcons.checkmark,
                    color: CupertinoColors.systemBlue,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _buildDifficultyPicker() => DecoratedBox(
    decoration: BoxDecoration(
      color: CupertinoColors.systemBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CupertinoColors.systemGrey4),
    ),
    child: Column(
      children: HabitDifficulty.values.map((difficulty) {
        final isSelected = _selectedDifficulty == difficulty;
        final color = AppTheme.getDifficultyColor(difficulty.name);
        return GestureDetector(
          onTap: () => setState(() => _selectedDifficulty = difficulty),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.1) : null,
              border: difficulty != HabitDifficulty.values.last
                  ? const Border(
                      bottom: BorderSide(color: CupertinoColors.systemGrey5),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    difficulty.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? color : CupertinoColors.label,
                    ),
                  ),
                ),
                Text(
                  '${difficulty.xpMultiplier}x XP',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                if (isSelected)
                  Icon(CupertinoIcons.checkmark, color: color, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _buildFrequencyPicker() => DecoratedBox(
    decoration: BoxDecoration(
      color: CupertinoColors.systemBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CupertinoColors.systemGrey4),
    ),
    child: Column(
      children: HabitFrequency.values.map((frequency) {
        final isSelected = _selectedFrequency == frequency;
        return GestureDetector(
          onTap: () => setState(() => _selectedFrequency = frequency),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? CupertinoColors.systemBlue.withOpacity(0.1)
                  : null,
              border: frequency != HabitFrequency.values.last
                  ? const Border(
                      bottom: BorderSide(color: CupertinoColors.systemGrey5),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  _getFrequencyIcon(frequency),
                  color: isSelected
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.systemGrey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    frequency.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? CupertinoColors.systemBlue
                          : CupertinoColors.label,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    CupertinoIcons.checkmark,
                    color: CupertinoColors.systemBlue,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );

  IconData _getFrequencyIcon(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return CupertinoIcons.sun_max;
      case HabitFrequency.weekly:
        return CupertinoIcons.calendar;
      case HabitFrequency.monthly:
        return CupertinoIcons.calendar_today;
    }
  }

  Widget _buildReminderSection() => DecoratedBox(
    decoration: BoxDecoration(
      color: CupertinoColors.systemBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CupertinoColors.systemGrey4),
    ),
    child: Column(
      children: [
        // Enable reminder toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.bell,
                color: CupertinoColors.systemGrey,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Enable Reminder', style: TextStyle(fontSize: 16)),
              ),
              CupertinoSwitch(
                value: _hasReminder,
                onChanged: (value) => setState(() {
                  _hasReminder = value;
                  if (!value) _reminderTime = null;
                }),
              ),
            ],
          ),
        ),

        // Time picker (shown when reminder is enabled)
        if (_hasReminder) ...[
          Container(height: 1, color: CupertinoColors.systemGrey5),
          GestureDetector(
            onTap: _selectReminderTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.time,
                    color: CupertinoColors.systemGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Reminder Time',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    _reminderTime != null
                        ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                        : 'Select Time',
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey3,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
