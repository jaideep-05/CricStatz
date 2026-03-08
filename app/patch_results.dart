import 'dart:io';

void main() {
  final file = File('lib/screens/stats/results_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // 1. Add _handleDeleteMatch into the State class
  final appendPoint = '  Widget _buildHeader(BuildContext context) {';
  final newDeleteMethod = '''  Future<void> _handleDeleteMatch(String matchId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Match?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to permanently delete this match?',
          style: TextStyle(color: AppPalette.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: AppPalette.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      try {
         await MatchService.deleteMatch(matchId);
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Match deleted successfully')),
         );
         setState(() {
           _sectionsFuture = _loadSections();
         });
      } catch (e) {
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to delete match: \$e')),
         );
      }
    }
  }

  Widget _buildHeader(BuildContext context) {''';
  content = content.replaceFirst(appendPoint, newDeleteMethod);

  // 2. Pass onDelete to _ResultCard
  final mapResultsOld = '''                            );
                          },
                        ),''';
  final mapResultsNew = '''                                onDelete: () => _handleDeleteMatch(data.matchId),
                            );
                          },
                        ),''';
  content = content.replaceFirst(mapResultsOld, mapResultsNew);
  
  final resCardCallOld = '''                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ResultCard(data: data),
                              );''';
  final resCardCallNew = '''                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ResultCard(
                                  data: data,
                                  onDelete: () => _handleDeleteMatch(data.matchId),
                                ),
                              );''';
  content = content.replaceFirst(resCardCallOld, resCardCallNew);


  // 4. Update _ResultCard signature
  final rcClassOld = '''class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.data});

  final _ResultData data;''';
  final rcClassNew = '''class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.data, required this.onDelete});

  final _ResultData data;
  final VoidCallback onDelete;''';
  content = content.replaceFirst(rcClassOld, rcClassNew);

  // 5. Update _ResultCard UI
  final rcUiOld = '''                Text(
                  data.status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.textMuted,
                        fontSize: 12,
                      ),
                ),
              ],
            ),''';
  final rcUiNew = '''                Row(
                  children: [
                    Text(
                      data.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppPalette.textMuted,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),''';
  content = content.replaceFirst(rcUiOld, rcUiNew);


  file.writeAsStringSync(content);
  print('Patch applied successfully to results_screen.dart');
}
