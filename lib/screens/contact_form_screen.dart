import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import '../providers/contacts_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/contact_avatar.dart';

class ContactFormScreen extends StatefulWidget {
  final Contact? contact;

  const ContactFormScreen({super.key, this.contact});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _secondaryPhoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _jobTitleCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _notesCtrl;
  String? _avatarPath;
  bool _isSaving = false;

  bool get isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _firstNameCtrl = TextEditingController(text: c?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: c?.lastName ?? '');
    _phoneCtrl = TextEditingController(text: c?.phoneNumber ?? '');
    _secondaryPhoneCtrl = TextEditingController(text: c?.secondaryPhone ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _companyCtrl = TextEditingController(text: c?.company ?? '');
    _jobTitleCtrl = TextEditingController(text: c?.jobTitle ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _notesCtrl = TextEditingController(text: c?.notes ?? '');
    _avatarPath = c?.avatarPath;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _secondaryPhoneCtrl.dispose();
    _emailCtrl.dispose();
    _companyCtrl.dispose();
    _jobTitleCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: const Text('Take photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final img = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (img != null) setState(() => _avatarPath = img.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (img != null) setState(() => _avatarPath = img.path);
              },
            ),
            if (_avatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorColor),
                title: const Text('Remove photo', style: TextStyle(color: AppTheme.errorColor)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _avatarPath = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<ContactsProvider>();
      final contact = Contact(
        id: widget.contact?.id ?? const Uuid().v4(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        secondaryPhone: _secondaryPhoneCtrl.text.trim().isEmpty
            ? null
            : _secondaryPhoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        company: _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
        jobTitle: _jobTitleCtrl.text.trim().isEmpty ? null : _jobTitleCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        avatarPath: _avatarPath,
        isFavorite: widget.contact?.isFavorite ?? false,
      );

      if (isEditing) {
        await provider.updateContact(contact);
      } else {
        await provider.addContact(contact);
      }

      if (mounted) {
        Navigator.pop(context, contact);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving contact: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tempContact = Contact(
      id: '',
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      phoneNumber: '',
      avatarPath: _avatarPath,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit contact' : 'New contact'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: ContactAvatar(contact: tempContact, radius: 48, fontSize: 32),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name section
            _SectionLabel(label: 'Name'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    controller: _firstNameCtrl,
                    label: 'First name',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    controller: _lastNameCtrl,
                    label: 'Last name',
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone
            _SectionLabel(label: 'Phone'),
            const SizedBox(height: 8),
            _FormField(
              controller: _phoneCtrl,
              label: 'Phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Phone number is required' : null,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\(\) ]'))],
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _secondaryPhoneCtrl,
              label: 'Secondary phone (optional)',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\(\) ]'))],
            ),
            const SizedBox(height: 16),

            // Email
            _SectionLabel(label: 'Email'),
            const SizedBox(height: 8),
            _FormField(
              controller: _emailCtrl,
              label: 'Email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v != null && v.isNotEmpty && !v.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Company
            _SectionLabel(label: 'Work'),
            const SizedBox(height: 8),
            _FormField(
              controller: _companyCtrl,
              label: 'Company',
              icon: Icons.business_outlined,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _jobTitleCtrl,
              label: 'Job title',
              icon: Icons.work_outline,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Address
            _SectionLabel(label: 'Address'),
            const SizedBox(height: 8),
            _FormField(
              controller: _addressCtrl,
              label: 'Address',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Notes
            _SectionLabel(label: 'Notes'),
            const SizedBox(height: 8),
            _FormField(
              controller: _notesCtrl,
              label: 'Notes',
              icon: Icons.notes,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryColor,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20, color: const Color(0xFF5F6368)) : null,
      ),
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
    );
  }
}
