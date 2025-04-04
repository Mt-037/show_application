import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/show.dart';
import '../config/api_config.dart';

class ShowCard extends StatelessWidget {
  final Show show;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShowCard({
    super.key,
    required this.show,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Image avec hauteur fixe
              _buildImageSection(context),
              const SizedBox(height: 12),

              // Titre et catégorie
              Text(
                show.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Badge de catégorie
              _buildCategoryBadge(context),
              const SizedBox(height: 8),

              // Description
              Text(
                show.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Boutons d'action
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 150, // Hauteur fixe pour toutes les images
        width: double.infinity,
        color: Colors.grey[200],
        child: show.imageUrl != null && show.imageUrl!.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: '${ApiConfig.baseUrl}${show.imageUrl}',
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.broken_image,
            size: 40,
            color: Colors.grey,
          ),
        )
            : const Center(
          child: Icon(
            Icons.movie,
            size: 40,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(show.category),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        show.category.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          color: Theme.of(context).primaryColor,
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: onDelete,
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'movie':
        return Colors.blue;
      case 'anime':
        return Colors.purple;
      case 'serie':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}