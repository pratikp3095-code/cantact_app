import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/contact.dart';
import '../screens/contact_detail_screen.dart';
import 'contact_avatar.dart';

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final int index;
  final VoidCallback? onDelete;
  final VoidCallback? onFavoriteToggle;

  const ContactListTile({
    super.key,
    required this.contact,
    this.index = 0,
    this.onDelete,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContactDetailScreen(contact: contact),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ContactAvatar(contact: contact),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF202124),
                      ),
                    ),
                    if (contact.phoneNumber.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact.phoneNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5F6368),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (contact.isFavorite)
                const Icon(Icons.star, color: Color(0xFFFBBC04), size: 18),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 30))
        .fadeIn(duration: 200.ms)
        .slideX(begin: 0.05, end: 0, duration: 200.ms);
  }
}
