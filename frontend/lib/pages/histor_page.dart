import 'package:agriscan/pages/chat_detail_page.dart';
import 'package:agriscan/pages/login_page.dart';
import 'package:agriscan/services/api_config.dart';
import 'package:agriscan/services/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final bool darkMode;
  const HistoryPage({super.key, required this.darkMode});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _conversations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final isLoggedIn = await AuthStorage.isLoggedIn();
      if (!isLoggedIn) {
        setState(() {
          _loading = false;
          _error = 'non_connecte';
        });
        return;
      }

      final userId = await AuthStorage.getUserId();
      final token = await AuthStorage.getToken();

      final response = await http
          .get(
        Uri.parse(ApiConfig.historique(userId!)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() {
          _conversations = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'erreur_serveur';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'pas_de_connexion';
        _loading = false;
      });
    }
  }

  Future<void> _supprimerConversation(int id) async {
    final token = await AuthStorage.getToken();
    try {
      await http.delete(
        Uri.parse(ApiConfig.conversation(id)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _loadHistorique();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de supprimer')),
        );
      }
    }
  }

  // ── Confirmation avant suppression ────────────────────────
  Future<bool?> _confirmerSuppression(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ?'),
        content:
        const Text('Cette conversation sera supprimée définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  IconData _iconSaison(String? saison) {
    switch (saison) {
      case 'Printemps':
        return Icons.local_florist;
      case 'Été':
        return Icons.wb_sunny;
      case 'Automne':
        return Icons.eco;
      case 'Hiver':
        return Icons.ac_unit;
      default:
        return Icons.grass;
    }
  }

  Color _couleurSaison(String? saison) {
    switch (saison) {
      case 'Printemps':
        return Colors.pink;
      case 'Été':
        return Colors.orange;
      case 'Automne':
        return Colors.brown;
      case 'Hiver':
        return Colors.lightBlue;
      default:
        return const Color(0xFF4CD964);
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = widget.darkMode;
    final bg = darkMode ? const Color(0xFF121212) : Colors.grey[100]!;
    final textColor = darkMode ? Colors.white : Colors.black87;

    return ColoredBox(
      color: bg,
      child: Column(
        children: [
          // ── AppBar ──────────────────────────────────────────
          Container(
            color: const Color(0xFF4CD964),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 8,
              bottom: 12,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Historique',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadHistorique,
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(darkMode, textColor, bg)),
        ],
      ),
    );
  }

  Widget _buildBody(bool darkMode, Color textColor, Color bg) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4CD964)),
      );
    }

    // ── Pas connecté ──────────────────────────────────────
    if (_error == 'non_connecte') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 64, color: Color(0xFF4CD964)),
              const SizedBox(height: 16),
              Text(
                'Connectez-vous pour voir votre historique',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD964),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                  _loadHistorique();
                },
                child: const Text(
                  'Se connecter',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Erreur réseau ────────────────────────────────────
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Impossible de charger l'historique",
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD964)),
              onPressed: _loadHistorique,
              child: const Text('Réessayer',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    // ── Liste vide ──────────────────────────────────────
    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: darkMode ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun historique pour l\'instant',
              style: TextStyle(
                color: darkMode ? Colors.white54 : Colors.black45,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos analyses apparaîtront ici',
              style: TextStyle(
                color: darkMode ? Colors.white24 : Colors.black26,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // ── Liste conversations ──────────────────────────────
    return RefreshIndicator(
      color: const Color(0xFF4CD964),
      onRefresh: _loadHistorique,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        itemBuilder: (ctx, i) {
          final conv = _conversations[i];
          final saison = conv['saison'] as String?;
          final couleur = _couleurSaison(saison);

          return Dismissible(
            key: Key(conv['id'].toString()),
            direction: DismissDirection.endToStart,
            // ✅ Confirmation avant suppression
            confirmDismiss: (_) => _confirmerSuppression(context),
            onDismissed: (_) => _supprimerConversation(conv['id']),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailPage(
                    conversationId: conv['id'],
                    titre: conv['titre'],
                    darkMode: darkMode,
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkMode
                      ? const Color(0xFF2A2A2A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: couleur.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_iconSaison(saison),
                          color: couleur, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conv['titre'] ?? 'Sans titre',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                conv['dateCreation'] ?? '',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.chat_bubble_outline,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${conv['nombreMessages']} messages',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          if (saison != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: couleur.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                saison,
                                style: TextStyle(
                                  color: couleur,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}