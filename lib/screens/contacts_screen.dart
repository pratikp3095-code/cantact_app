import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/contacts_provider.dart';
import '../screens/contact_form_screen.dart';
import '../utils/app_theme.dart';
import '../widgets/contact_list_tile.dart';
import '../widgets/contact_avatar.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _isSearchActive = !_isSearchActive);
    if (!_isSearchActive) {
      _searchController.clear();
      context.read<ContactsProvider>().clearSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Search bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: _isSearchActive
                ? _buildSearchBar()
                : _buildHeader(),
          ),
          Expanded(child: _buildContactsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContactFormScreen()),
        ),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('New contact'),
      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Contacts',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202124),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF5F6368)),
          onPressed: _toggleSearch,
          tooltip: 'Search',
        ),
        const SizedBox(width: 4),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
          child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 20),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _toggleSearch,
        ),
        Expanded(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search contacts...',
              border: InputBorder.none,
              fillColor: Colors.transparent,
            ),
            onChanged: (query) =>
                context.read<ContactsProvider>().searchContacts(query),
          ),
        ),
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              context.read<ContactsProvider>().clearSearch();
            },
          ),
      ],
    );
  }

  Widget _buildContactsList() {
    return Consumer<ContactsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final contacts = provider.displayedContacts;

        if (contacts.isEmpty) {
          return _buildEmptyState(provider.isSearching);
        }

        if (provider.isSearching) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: contacts.length,
            itemBuilder: (ctx, i) => ContactListTile(
              contact: contacts[i],
              index: i,
            ),
          );
        }

        // Grouped contacts
        final grouped = provider.groupedContacts;
        final keys = grouped.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: keys.fold(0, (sum, k) => sum! + grouped[k]!.length + 1),
          itemBuilder: (ctx, index) {
            int cursor = 0;
            for (final key in keys) {
              if (index == cursor) {
                return _SectionHeader(letter: key);
              }
              cursor++;
              final sectionContacts = grouped[key]!;
              if (index < cursor + sectionContacts.length) {
                final contactIndex = index - cursor;
                return ContactListTile(
                  contact: sectionContacts[contactIndex],
                  index: contactIndex,
                );
              }
              cursor += sectionContacts.length;
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.people_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No contacts found' : 'No contacts yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search term'
                : 'Tap + to add your first contact',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String letter;
  const _SectionHeader({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 12, bottom: 4),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
