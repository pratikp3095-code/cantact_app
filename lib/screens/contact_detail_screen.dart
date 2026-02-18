import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import '../providers/contacts_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/contact_avatar.dart';
import 'contact_form_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late Contact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  Future<void> _callNumber(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _deleteContact() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete contact'),
        content: Text(
            'Are you sure you want to delete ${_contact.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<ContactsProvider>().deleteContact(_contact.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _editContact() async {
    final updated = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(
        builder: (_) => ContactFormScreen(contact: _contact),
      ),
    );
    if (updated != null) {
      setState(() => _contact = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContactsProvider>();
    // Sync with provider state
    final latest = provider.contacts.firstWhere(
      (c) => c.id == _contact.id,
      orElse: () => _contact,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  latest.isFavorite ? Icons.star : Icons.star_border,
                  color: latest.isFavorite ? const Color(0xFFFBBC04) : null,
                ),
                onPressed: () async {
                  await provider.toggleFavorite(latest);
                  setState(() => _contact = latest.copyWith(isFavorite: !latest.isFavorite));
                },
                tooltip: latest.isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: _editContact,
                tooltip: 'Edit',
              ),
              PopupMenuButton(
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppTheme.errorColor),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') _deleteContact();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.getAvatarColor(_contact.firstName).withOpacity(0.15),
                      Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    ContactAvatar(contact: latest, radius: 56, fontSize: 36)
                        .animate()
                        .scale(duration: 400.ms, curve: Curves.easeOut),
                    const SizedBox(height: 16),
                    Text(
                      latest.fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF202124),
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    if (latest.jobTitle != null || latest.company != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          [latest.jobTitle, latest.company]
                              .where((e) => e != null)
                              .join(' · '),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5F6368),
                          ),
                        ).animate().fadeIn(delay: 150.ms),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.call,
                    label: 'Call',
                    color: AppTheme.primaryColor,
                    onTap: () => _callNumber(latest.phoneNumber),
                  ),
                  if (latest.email != null)
                    _ActionButton(
                      icon: Icons.email,
                      label: 'Email',
                      color: AppTheme.accentColor,
                      onTap: () => _sendEmail(latest.email!),
                    ),
                  _ActionButton(
                    icon: Icons.message,
                    label: 'SMS',
                    color: const Color(0xFF9334E6),
                    onTap: () => _sendSms(latest.phoneNumber),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            ),
          ),

          // Info sections
          SliverList(
            delegate: SliverChildListDelegate([
              _InfoCard(
                children: [
                  _InfoRow(
                    icon: Icons.phone,
                    label: 'Mobile',
                    value: latest.phoneNumber,
                    onTap: () => _callNumber(latest.phoneNumber),
                  ),
                  if (latest.secondaryPhone != null)
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Other',
                      value: latest.secondaryPhone!,
                      onTap: () => _callNumber(latest.secondaryPhone!),
                    ),
                  if (latest.email != null)
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: latest.email!,
                      onTap: () => _sendEmail(latest.email!),
                    ),
                ],
              ).animate().fadeIn(delay: 250.ms),
              if (latest.company != null || latest.address != null)
                _InfoCard(
                  children: [
                    if (latest.company != null)
                      _InfoRow(
                        icon: Icons.business_outlined,
                        label: 'Company',
                        value: latest.company!,
                      ),
                    if (latest.address != null)
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: latest.address!,
                      ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
              if (latest.notes != null)
                _InfoCard(
                  children: [
                    _InfoRow(
                      icon: Icons.notes,
                      label: 'Notes',
                      value: latest.notes!,
                    ),
                  ],
                ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5F6368), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF5F6368),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: onTap != null ? AppTheme.primaryColor : const Color(0xFF202124),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Color(0xFFBDC1C6), size: 20),
          ],
        ),
      ),
    );
  }
}
