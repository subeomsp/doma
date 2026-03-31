import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/recipe_provider.dart';
import '../../providers/tags_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final recipesAsyncValue = ref.watch(recipeListProvider);
    final selectedTags = ref.watch(tagFilterProvider);
    final tagsAsyncValue = ref.watch(tagsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('DOMA'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: '조리법을 찾아보세요',
                hintStyle: TextStyle(fontFamily: 'GowunDodum', color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                filled: true,
                fillColor: const Color(0xFFF9F9FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          // Tags
          SizedBox(
            height: 36,
            child: tagsAsyncValue.when(
              data: (dbTags) {
                final List<String> availableTags = ['전체', ...dbTags.map((t) => t.name)];
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: availableTags.length,
                  itemBuilder: (context, index) {
                    final tag = availableTags[index];
                    final isAllTag = tag == '전체';
                    final isSelected = isAllTag ? selectedTags.isEmpty : selectedTags.contains(tag);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          if (isAllTag) {
                            ref.read(tagFilterProvider.notifier).state = [];
                          } else {
                            final current = List<String>.from(selectedTags);
                            if (current.contains(tag)) {
                              current.remove(tag);
                            } else {
                              current.add(tag);
                            }
                            ref.read(tagFilterProvider.notifier).state = current;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tag.toUpperCase(),
                            style: TextStyle(fontFamily: 'GowunDodum', fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5, color: isSelected ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const SizedBox(),
              error: (e, st) => const SizedBox(),
            ),
          ),
          const SizedBox(height: 16),
          // List
          Expanded(
            child: recipesAsyncValue.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('아직 담아둔 조리법이 없습니다', style: TextStyle(fontFamily: 'GowunDodum', fontSize: 16, color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: recipes.length,
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return GestureDetector(
                      onTap: () => context.push('/detail/${recipe.id}'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                            BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 2, offset: const Offset(0, 1)),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                              child: Container(
                                width: 110,
                                height: double.infinity,
                                color: const Color(0xFFF4F4F5),
                                child: recipe.coverPhotoPath != null && recipe.coverPhotoPath!.isNotEmpty
                                    ? Image.file(File(recipe.coverPhotoPath!), fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset('assets/images/default.png', fit: BoxFit.cover))
                                    : Image.asset('assets/images/default.png', fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            recipe.title.toUpperCase(),
                                            style: TextStyle(fontFamily: 'Hahmlet', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(Icons.more_horiz, size: 20, color: Colors.grey.shade400),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Tags
                                    if (recipe.tags.isNotEmpty)
                                      Text(
                                        recipe.tags.take(2).map((t) => t.toUpperCase()).join('  •  '),
                                        style: TextStyle(fontFamily: 'GowunDodum', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                      ),
                                    const Spacer(),
                                    // Ingredients count
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.soup_kitchen_outlined, size: 16, color: Colors.grey.shade500),
                                        const SizedBox(width: 4),
                                        Text('재료 ${recipe.ingredients.length}가지', style: TextStyle(fontFamily: 'GowunDodum', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () => context.push('/edit'),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
