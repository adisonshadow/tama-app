import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return PopupMenuButton<String>(
          icon: Image.asset(
            'assets/images/langZh.png',
            width: 32,
            height: 32,
          ),
          onSelected: (String languageCode) async {
            await languageProvider.switchLanguage(context, languageCode);
          },
          itemBuilder: (BuildContext context) {
            return LanguageProvider.supportedLanguages.map((language) {
              return PopupMenuItem<String>(
                value: language['code']!,
                child: Row(
                  children: [
                    Text(
                      language['nativeName']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${language['name']!})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}
