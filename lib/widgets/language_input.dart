import 'package:flutter/material.dart';
import 'package:tripaldashboard/core/models/translation.dart';

/// A widget for inputting text in multiple languages
class LanguageInput extends StatefulWidget {
  final TranslationField? initialValue;
  final String label;
  final Function(TranslationField value) onChanged;
  final bool isMultiline;
  final int maxLines;
  final int? maxLength;
  final bool isRequired;

  const LanguageInput({
    Key? key,
    this.initialValue,
    required this.label,
    required this.onChanged,
    this.isMultiline = false,
    this.maxLines = 1,
    this.maxLength,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<LanguageInput> createState() => _LanguageInputState();
}

class _LanguageInputState extends State<LanguageInput> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _enController;
  late TextEditingController _arController;
  late TextEditingController _kuController;
  late TextEditingController _badController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize text controllers with initial values if provided
    _enController = TextEditingController(text: widget.initialValue?.en ?? '');
    _arController = TextEditingController(text: widget.initialValue?.ar ?? '');
    _kuController = TextEditingController(text: widget.initialValue?.ku ?? '');
    _badController = TextEditingController(text: widget.initialValue?.bad ?? '');
    
    // Add listeners to update the parent widget when text changes
    _enController.addListener(_notifyChange);
    _arController.addListener(_notifyChange);
    _kuController.addListener(_notifyChange);
    _badController.addListener(_notifyChange);
  }
  
  void _notifyChange() {
    widget.onChanged(
      TranslationField(
        en: _enController.text,
        ar: _arController.text,
        ku: _kuController.text,
        bad: _badController.text,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _enController.dispose();
    _arController.dispose();
    _kuController.dispose();
    _badController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (widget.isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'English'),
                  Tab(text: 'العربية'),
                  Tab(text: 'کوردی'),
                  Tab(text: 'بادینی'),
                ],
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
              SizedBox(
                height: widget.isMultiline ? 150 : 60,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // English input
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _enController,
                        maxLines: widget.isMultiline ? widget.maxLines : 1,
                        maxLength: widget.maxLength,
                        decoration: const InputDecoration(
                          hintText: 'Enter text in English',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    
                    // Arabic input
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _arController,
                        maxLines: widget.isMultiline ? widget.maxLines : 1,
                        maxLength: widget.maxLength,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          hintText: 'أدخل النص بالعربية',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    
                    // Kurdish input
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _kuController,
                        maxLines: widget.isMultiline ? widget.maxLines : 1,
                        maxLength: widget.maxLength,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          hintText: 'دەقی کوردی بنووسە',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    
                    // Badinani input
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _badController,
                        maxLines: widget.isMultiline ? widget.maxLines : 1,
                        maxLength: widget.maxLength,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          hintText: 'دەقێ ب بادینی بنڤیسە',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 