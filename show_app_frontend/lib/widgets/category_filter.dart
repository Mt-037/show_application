import 'package:flutter/material.dart';

class CategoryFilter extends StatefulWidget {
  final ValueChanged<String> onCategoryChanged;
  final String initialCategory;

  const CategoryFilter({
    super.key,
    required this.onCategoryChanged,
    this.initialCategory = 'movie',
  });

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryButton('movie', 'Films', Icons.movie),
          _buildCategoryButton('anime', 'Animés', Icons.animation),
          _buildCategoryButton('serie', 'Séries', Icons.tv),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => _handleCategoryChange(category),
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.grey[200],
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.black,
          ),
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  void _handleCategoryChange(String category) {
    setState(() {
      _selectedCategory = category;
    });
    widget.onCategoryChanged(category);
  }
}