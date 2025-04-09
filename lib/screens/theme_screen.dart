import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentTheme = ref.watch(themeProvider);
    final themes = themeNotifier.getAvailableThemes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Theme'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: themes.length,
        itemBuilder: (context, index) {
          final theme = themes[index];
          final isSelected = currentTheme.primaryColor == theme.primaryColor &&
              currentTheme.brightness == (theme.isDark ? Brightness.dark : Brightness.light);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                theme.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              trailing: Icon(
                Icons.check_circle,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
              selected: isSelected,
              onTap: () {
                themeNotifier.setTheme(index);
              },
            ),
          );
        },
      ),
    );
  }
}
