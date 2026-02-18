import 'dart:io';
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../utils/app_theme.dart';

class ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double radius;
  final double fontSize;

  const ContactAvatar({
    super.key,
    required this.contact,
    this.radius = 24,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (contact.avatarPath != null && contact.avatarPath!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(contact.avatarPath!)),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.getAvatarColor(contact.firstName),
      child: Text(
        contact.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
