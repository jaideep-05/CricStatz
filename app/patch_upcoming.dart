import 'dart:io';

void main() {
  final file = File('lib/screens/match/upcoming_fixtures_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // 1. Add _handleDeleteMatch into the State class
  final appendPoint = '  Widget _buildHeader(BuildContext context) {';
  final newDeleteMethod = '''  Future<void> _handleDeleteMatch(Match match) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Match?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to permanently delete \${match.teamAId} vs \${match.teamBId}?',
          style: const TextStyle(color: AppPalette.textMuted),
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
         await MatchService.deleteMatch(match.id);
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Match deleted successfully')),
         );
         setState(() {
           _fixturesFuture = _loadFixtures();
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

  // 2. Pass onDelete to _FixtureCard
  final mapUpcomingOld = '''                        ...data.upcoming.map((match) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _FixtureCard(match: match),
                            )),''';
  final mapUpcomingNew = '''                        ...data.upcoming.map((match) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _FixtureCard(
                                match: match,
                                onDelete: () => _handleDeleteMatch(match),
                              ),
                            )),''';
  content = content.replaceFirst(mapUpcomingOld, mapUpcomingNew);

  // 3. Pass onDelete to _LiveFixtureCard
  final liveWidgetOld = '''                                itemBuilder: (context, index) {
                                  return _LiveFixtureCard(
                                      match: data.live[index]);
                                },''';
  final liveWidgetNew = '''                                itemBuilder: (context, index) {
                                  final match = data.live[index];
                                  return _LiveFixtureCard(
                                    match: match,
                                    onDelete: () => _handleDeleteMatch(match),
                                  );
                                },''';
  content = content.replaceFirst(liveWidgetOld, liveWidgetNew);

  // 4. Update _FixtureCard signature
  final fcClassOld = '''class _FixtureCard extends StatelessWidget {
  const _FixtureCard({required this.match});

  final Match match;''';
  final fcClassNew = '''class _FixtureCard extends StatelessWidget {
  const _FixtureCard({required this.match, required this.onDelete});

  final Match match;
  final VoidCallback onDelete;''';
  content = content.replaceFirst(fcClassOld, fcClassNew);

  // 5. Update _FixtureCard UI
  final fcUiOld = '''                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: formatColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.matchFormat ?? 'T20',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                    ),
                  ),
                ],
              ),
            ),''';
  final fcUiNew = '''                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: formatColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.matchFormat ?? 'T20',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
            ),''';
  content = content.replaceFirst(fcUiOld, fcUiNew);

  // 6. Update _LiveFixtureCard signature
  final lfcClassOld = '''class _LiveFixtureCard extends StatelessWidget {
  const _LiveFixtureCard({required this.match});

  final Match match;''';
  final lfcClassNew = '''class _LiveFixtureCard extends StatelessWidget {
  const _LiveFixtureCard({required this.match, required this.onDelete});

  final Match match;
  final VoidCallback onDelete;''';
  content = content.replaceFirst(lfcClassOld, lfcClassNew);

  // 7. Update _LiveFixtureCard UI
  final lfcUiOld = '''                match.matchFormat?.toUpperCase() ?? 'MATCH',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),''';
  final lfcUiNew = '''                match.matchFormat?.toUpperCase() ?? 'MATCH',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),''';
  content = content.replaceFirst(lfcUiOld, lfcUiNew);

  file.writeAsStringSync(content);
  print('Patch applied successfully to upcoming_fixtures_screen.dart');
}
