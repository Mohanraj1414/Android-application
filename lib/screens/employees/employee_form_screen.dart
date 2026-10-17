import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_text_field.dart';

/// Form screen handling both Create (Add Employee) and Update (Edit Employee) operations.
class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  bool get isEditing => employee != null;

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _designationController;
  late TextEditingController _notesController;

  late String _selectedDepartment;
  late String _selectedEmploymentType;
  late String _selectedStatus;
  late String _selectedLocation;
  late DateTime _selectedJoiningDate;
  late int _selectedAvatarColor;

  bool _isSaving = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    final emp = widget.employee;

    _idController = TextEditingController(text: emp?.employeeId ?? '');
    _nameController = TextEditingController(text: emp?.fullName ?? '');
    _emailController = TextEditingController(text: emp?.email ?? '');
    _phoneController = TextEditingController(text: emp?.phone ?? '');
    _designationController = TextEditingController(text: emp?.designation ?? '');
    _notesController = TextEditingController(text: emp?.notes ?? '');

    _selectedDepartment = emp?.department ?? AppConstants.departments.first;
    _selectedEmploymentType = emp?.employmentType ?? AppConstants.employmentTypes.first;
    _selectedStatus = emp?.employmentStatus ?? AppConstants.employmentStatuses.first;
    _selectedLocation = emp?.location ?? AppConstants.locations.first;
    _selectedJoiningDate = emp?.joiningDate ?? DateTime.now();
    _selectedAvatarColor = emp?.avatarColor ?? AppConstants.avatarColorHexes.first;

    // Auto-generate employee ID for new hires
    if (!widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateAutoId();
      });
    }
  }

  Future<void> _generateAutoId() async {
    final nextId = await context.read<EmployeeProvider>().getNextEmployeeId();
    if (mounted && _idController.text.isEmpty) {
      setState(() {
        _idController.text = nextId;
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedJoiningDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedJoiningDate = picked);
    }
  }

  Future<void> _saveEmployee() async {
    setState(() => _serverError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<EmployeeProvider>();
    final now = DateTime.now();

    final employeeData = Employee(
      id: widget.employee?.id,
      employeeId: _idController.text.trim().toUpperCase(),
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      phone: _phoneController.text.trim(),
      department: _selectedDepartment,
      designation: _designationController.text.trim(),
      joiningDate: _selectedJoiningDate,
      employmentType: _selectedEmploymentType,
      employmentStatus: _selectedStatus,
      location: _selectedLocation,
      avatarColor: _selectedAvatarColor,
      notes: _notesController.text.trim(),
      createdAt: widget.employee?.createdAt ?? now,
      updatedAt: now,
    );

    bool success;
    if (widget.isEditing) {
      success = await provider.updateEmployee(employeeData);
    } else {
      success = await provider.addEmployee(employeeData);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Profile updated successfully for ${employeeData.fullName}'
                : '${employeeData.fullName} onboarded successfully to ${employeeData.department}',
          ),
          backgroundColor: AppColors.successDark,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _serverError = provider.errorMessage ?? 'An error occurred while saving.';
      });
    }
  }

  String _deriveInitials() {
    final text = _nameController.text.trim();
    if (text.isEmpty) return 'NX';
    final parts = text.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Edit Employee Profile' : 'Add New Employee';
    final subtitle = widget.isEditing
        ? 'Update employment details and departmental assignments'
        : 'Register a new workforce member into the enterprise system';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveEmployee,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(_isSaving ? 'Saving...' : (widget.isEditing ? 'Update Profile' : 'Save Employee')),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Header Card
                  _buildFormHeaderCard(subtitle),
                  const SizedBox(height: 20),

                  // Server/Uniqueness Error Banner
                  if (_serverError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.dangerBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _serverError!,
                              style: const TextStyle(
                                color: AppColors.dangerDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Avatar & ID Strip
                  _buildAvatarCustomizer(),
                  const SizedBox(height: 24),

                  // Section 1: Basic Profile Details
                  _buildSectionCard(
                    title: 'Personal & Contact Information',
                    icon: Icons.person_outline_rounded,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: CustomTextField(
                              label: 'Full Legal Name',
                              hintText: 'e.g. Sarah Jenkins',
                              controller: _nameController,
                              isRequired: true,
                              validator: Validators.name,
                              prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.textMuted),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: CustomTextField(
                              label: 'Employee ID',
                              hintText: 'e.g. NEX-1011',
                              controller: _idController,
                              isRequired: true,
                              validator: Validators.employeeId,
                              prefixIcon: const Icon(Icons.tag_rounded, size: 20, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Corporate Work Email',
                              hintText: 'name@nexuscorp.com',
                              controller: _emailController,
                              isRequired: true,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                              prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.textMuted),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'Phone Number',
                              hintText: '+1 (555) 019-2834',
                              controller: _phoneController,
                              isRequired: true,
                              keyboardType: TextInputType.phone,
                              validator: Validators.phone,
                              prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Department & Employment Role
                  _buildSectionCard(
                    title: 'Organizational Assignment',
                    icon: Icons.corporate_fare_rounded,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Department *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedDepartment,
                                  isExpanded: true,
                                  decoration: const InputDecoration(),
                                  items: AppConstants.departments.map(
                                    (d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13))),
                                  ).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedDepartment = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'Job Designation',
                              hintText: 'e.g. Lead Staff Architect',
                              controller: _designationController,
                              isRequired: true,
                              validator: Validators.designation,
                              prefixIcon: const Icon(Icons.work_outline_rounded, size: 20, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Employment Type *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedEmploymentType,
                                  isExpanded: true,
                                  decoration: const InputDecoration(),
                                  items: AppConstants.employmentTypes.map(
                                    (t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))),
                                  ).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedEmploymentType = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Employment Status *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedStatus,
                                  isExpanded: true,
                                  decoration: const InputDecoration(),
                                  items: AppConstants.employmentStatuses.map(
                                    (s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))),
                                  ).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedStatus = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Joining Date *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: _selectJoiningDate,
                                  borderRadius: BorderRadius.circular(10),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      suffixIcon: Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.primary),
                                    ),
                                    child: Text(
                                      DateFormatter.format(_selectedJoiningDate),
                                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Office / Location *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedLocation,
                                  isExpanded: true,
                                  decoration: const InputDecoration(),
                                  items: AppConstants.locations.map(
                                    (l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 13))),
                                  ).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedLocation = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Notes & Performance Summary
                  _buildSectionCard(
                    title: 'Executive Notes & Key Responsibilities',
                    icon: Icons.notes_rounded,
                    children: [
                      CustomTextField(
                        label: 'Internal Notes (Optional)',
                        hintText: 'Enter performance summaries, key projects, or internal HR remarks...',
                        controller: _notesController,
                        maxLines: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Bottom Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveEmployee,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check_rounded, size: 18),
                        label: Text(_isSaving ? 'Saving...' : (widget.isEditing ? 'Save Changes' : 'Save Employee')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeaderCard(String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.isEditing ? Icons.manage_accounts_rounded : Icons.person_add_alt_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing ? 'Update Employee Record' : 'Create Employee Record',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCustomizer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          AvatarWidget(
            initials: _deriveInitials(),
            backgroundColor: Color(_selectedAvatarColor),
            size: 56,
            status: _selectedStatus,
            showStatus: true,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Color Accent',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose a corporate identity color swatch for this profile badge.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.avatarColorHexes.map((hex) {
                    final isSelected = hex == _selectedAvatarColor;
                    return InkWell(
                      onTap: () => setState(() => _selectedAvatarColor = hex),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(hex),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Color(hex).withAlpha(150),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
