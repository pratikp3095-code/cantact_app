import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/database_service.dart';

class ContactsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Contact> _contacts = [];
  List<Contact> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String _searchQuery = '';

  List<Contact> get contacts => _contacts;
  List<Contact> get favorites => _contacts.where((c) => c.isFavorite).toList();
  List<Contact> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Contact> get displayedContacts =>
      _isSearching ? _searchResults : _contacts;

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _contacts = await _db.getAllContacts();
    } catch (e) {
      debugPrint('Error loading contacts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContact(Contact contact) async {
    await _db.insertContact(contact);
    await loadContacts();
  }

  Future<void> updateContact(Contact contact) async {
    await _db.updateContact(contact);
    await loadContacts();
  }

  Future<void> deleteContact(String id) async {
    await _db.deleteContact(id);
    await loadContacts();
  }

  Future<void> toggleFavorite(Contact contact) async {
    final updated = contact.copyWith(isFavorite: !contact.isFavorite);
    await _db.updateContact(updated);
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = updated;
      notifyListeners();
    }
  }

  Future<void> searchContacts(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _isSearching = false;
      _searchResults = [];
    } else {
      _isSearching = true;
      _searchResults = await _db.searchContacts(query);
    }
    notifyListeners();
  }

  void clearSearch() {
    _isSearching = false;
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  Map<String, List<Contact>> get groupedContacts {
    final Map<String, List<Contact>> grouped = {};
    for (final contact in displayedContacts) {
      final key = contact.firstName.isNotEmpty
          ? contact.firstName[0].toUpperCase()
          : '#';
      grouped.putIfAbsent(key, () => []).add(contact);
    }
    return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }
}
