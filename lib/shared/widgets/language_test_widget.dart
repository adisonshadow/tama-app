import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageTestWidget extends StatelessWidget {
  const LanguageTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language Test Widget',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Current Language: ${languageProvider.currentLanguage}'),
                const SizedBox(height: 8),
                Text('Title: ${FlutterI18n.translate(context, 'auth.login.title')}'),
                const SizedBox(height: 8),
                Text('Subtitle: ${FlutterI18n.translate(context, 'auth.login.subtitle')}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final newLang = languageProvider.currentLanguage == 'en' ? 'zh_TW' : 'en';
                    await languageProvider.switchLanguage(context, newLang);
                  },
                  child: Text('Switch to ${languageProvider.currentLanguage == 'en' ? 'Chinese' : 'English'}'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
