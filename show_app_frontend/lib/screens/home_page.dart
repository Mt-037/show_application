import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile_page.dart';
import 'add_show_page.dart';
import 'update_show_page.dart';
import '../config/api_config.dart';
import '../models/show.dart';
import '../widgets/category_filter.dart'; // Nouveau widget importé

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<Show> _movies = [];
  List<Show> _anime = [];
  List<Show> _series = [];
  String _currentFilter = 'all'; // Nouvel état pour le filtre

  Future<void> _fetchShows() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.showsEndpoint}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Show> shows = data.map((json) => Show.fromJson(json)).toList();

        if (mounted) {
          setState(() {
            _movies = shows.where((show) => show.category == 'movie').toList();
            _anime = shows.where((show) => show.category == 'anime').toList();
            _series = shows.where((show) => show.category == 'serie').toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('Erreur de chargement: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Erreur: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteShow(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Voulez-vous vraiment supprimer ce show?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final response = await http.delete(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.showsEndpoint}/$id'),
        );

        if (response.statusCode == 200) {
          _fetchShows();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Show supprimé avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            _showError('Échec de la suppression: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (mounted) {
          _showError('Erreur: ${e.toString()}');
        }
      }
    }
  }

  Future<void> _navigateToUpdate(Show show) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateShowPage(show: show),
      ),
    );

    if (result == true && mounted) {
      _fetchShows();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchShows();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildShowList(List<Show> shows) {
    if (shows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_filter, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Aucun show disponible',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchShows,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: shows.length,
        itemBuilder: (context, index) {
          final show = shows[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Dismissible(
              key: Key(show.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                await _deleteShow(show.id);
                return false;
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _navigateToUpdate(show),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: show.imageUrl != null
                              ? Image.network(
                            '${ApiConfig.baseUrl}${show.imageUrl}',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          )
                              : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                show.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                show.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToUpdate(show),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchShows,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Ajouter un show'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddShowPage()),
                ).then((_) {
                  if (mounted) _fetchShows();
                });
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Ajout du filtre par catégorie
          CategoryFilter(
            initialCategory: _selectedIndex == 0
                ? 'movie'
                : _selectedIndex == 1
                ? 'anime'
                : 'serie',
            onCategoryChanged: (category) {
              setState(() {
                _selectedIndex = category == 'movie'
                    ? 0
                    : category == 'anime'
                    ? 1
                    : 2;
              });
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildShowList(_movies),
                _buildShowList(_anime),
                _buildShowList(_series),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Films',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.animation),
            label: 'Animés',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'Séries',
          ),
        ],
      ),
    );
  }
}