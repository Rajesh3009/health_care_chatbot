import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Theme'),
      ),
      body: ListView.builder(
        itemCount: ThemeNotifier.themes.length,
        itemBuilder: (context, index) {
          final theme = ThemeNotifier.themes[index];
          final isSelected = currentTheme == theme.theme;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(theme.name),
              trailing: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.theme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(index);
              },
              selected: isSelected,
            ),
          );
        },
      ),
    );
  }
}
