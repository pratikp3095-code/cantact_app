import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import '../providers/contacts_provider.dart';
import '../screens/contact_detail_screen.dart';
import '../utils/app_theme.dart';
import '../widgets/contact_avatar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 20,
              right: 16,
              bottom: 12,
            ),
            child: const Text(
              'Favorites',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF202124),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ContactsProvider>(
              builder: (context, provider, _) {
                final favorites = provider.favorites;

                if (favorites.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        '${favorites.length} favorite${favorites.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5F6368),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Horizontal favorites grid at top
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: favorites.length,
                        itemBuilder: (ctx, i) => _FavoriteChip(
                          contact: favorites[i],
                          index: i,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        'All favorites',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5F6368),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: favorites.length,
                        itemBuilder: (ctx, i) => _FavoriteListTile(
                          contact: favorites[i],
                          index: i,
                          provider: provider,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_outline, size: 80, color: Color(0xFFDADCE0)),
          const SizedBox(height: 16),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF80868B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Star a contact to add it here',
            style: TextStyle(fontSize: 14, color: Color(0xFF9AA0A6)),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

class _FavoriteChip extends StatelessWidget {
  final Contact contact;
  final int index;

  const _FavoriteChip({required this.contact, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ContactDetailScreen(contact: contact)),
      ),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 80,
        child: Column(
          children: [
            Stack(
              children: [
                ContactAvatar(contact: contact, radius: 32, fontSize: 22),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBBC04),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              contact.firstName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF202124),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn()
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}

class _FavoriteListTile extends StatelessWidget {
  final Contact contact;
  final int index;
  final ContactsProvider provider;

  const _FavoriteListTile({
    required this.contact,
    required this.index,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContactDetailScreen(contact: contact)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              ContactAvatar(contact: contact, radius: 22, fontSize: 14),
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
                    Text(
                      contact.phoneNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call, color: AppTheme.primaryColor, size: 22),
                onPressed: () async {
                  final uri = Uri(scheme: 'tel', path: contact.phoneNumber);
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              IconButton(
                icon: const Icon(Icons.star, color: Color(0xFFFBBC04), size: 22),
                onPressed: () => provider.toggleFavorite(contact),
                tooltip: 'Remove from favorites',
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn()
        .slideX(begin: 0.05, end: 0);
  }
}
