import 'package:flutter/material.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/providers/search_provider.dart';

/// Bottom sheet for search filters and sort options
class SearchFilterSheet extends StatelessWidget {
  final SearchProvider searchProvider;

  const SearchFilterSheet({
    super.key,
    required this.searchProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter & Sort',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                // Filter by type
                Text(
                  'Filter by Type',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SearchFilterType.values.map((type) {
                    return FilterChip(
                      selected: searchProvider.filterType == type,
                      label: Text(_getFilterTypeLabel(type)),
                      onSelected: (selected) {
                        if (selected) {
                          searchProvider.setFilterType(type);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Sort options
                Text(
                  'Sort by',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...SearchSortOption.values.map((option) {
                  return RadioListTile<SearchSortOption>(
                    title: Text(_getSortOptionLabel(option)),
                    value: option,
                    groupValue: searchProvider.sortOption,
                    onChanged: (value) {
                      if (value != null) {
                        searchProvider.setSortOption(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterTypeLabel(SearchFilterType type) {
    switch (type) {
      case SearchFilterType.all:
        return 'All';
      case SearchFilterType.courses:
        return 'Courses';
      case SearchFilterType.decks:
        return 'Decks';
      case SearchFilterType.quizzes:
        return 'Quizzes';
      case SearchFilterType.flashcards:
        return 'Flashcards';
    }
  }

  String _getSortOptionLabel(SearchSortOption option) {
    switch (option) {
      case SearchSortOption.relevance:
        return 'Relevance';
      case SearchSortOption.dateNewest:
        return 'Newest First';
      case SearchSortOption.dateOldest:
        return 'Oldest First';
      case SearchSortOption.nameAscending:
        return 'Name (A-Z)';
      case SearchSortOption.nameDescending:
        return 'Name (Z-A)';
    }
  }
}

