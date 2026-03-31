import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../providers/recipe_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열 수 없습니다')),
        );
      }
    }
  }

  void _deleteRecipe(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('조리법을 삭제할까요?'),
        content: const Text('삭제한 뒤에는 되돌릴 수 없습니다'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(recipeRepositoryProvider);
      await repo.deleteRecipe(recipeId);
      ref.invalidate(recipeListProvider);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecipe = ref.watch(recipeDetailProvider(recipeId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('DOMA'),
        centerTitle: true,
      ),
      body: asyncRecipe.when(
        data: (recipe) {
          if (recipe == null) return const Center(child: Text('조리법을 찾을 수 없습니다.'));
          
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            children: [
              // Image
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (recipe.coverPhotoPath != null && recipe.coverPhotoPath!.isNotEmpty)
                      ? Image.file(
                          File(recipe.coverPhotoPath!),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Image.asset('assets/images/default.png', width: double.infinity, height: 180, fit: BoxFit.cover),
                        )
                      : Image.asset('assets/images/default.png', width: double.infinity, height: 180, fit: BoxFit.cover),
                ),
              ),

              // Title and Actions Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: TextStyle(fontFamily: 'Hahmlet', fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black, height: 1.2),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit, color: Colors.black, size: 24), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => context.push('/edit?id=$recipeId')),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.black, size: 24), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _deleteRecipe(context, ref)),
                ],
              ),
              const SizedBox(height: 24),

              // Tags
              if (recipe.tags.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: recipe.tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFF9F9FB), border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(20)),
                    child: Text(t.toUpperCase(), style: TextStyle(fontFamily: 'GowunDodum', fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.0, color: Colors.black)),
                  )).toList(),
                ),
              
              const SizedBox(height: 32),
              Divider(color: Colors.grey.shade300, height: 1),
              const SizedBox(height: 24),
              
              // Ingredients
              Text('재료', style: TextStyle(fontFamily: 'Hahmlet', fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Colors.black)),
              const SizedBox(height: 24),
              
              if (recipe.ingredients.isEmpty)
                Text('적어둔 재료가 없습니다', style: TextStyle(fontFamily: 'GowunDodum', color: Colors.grey))
              else
                ...recipe.ingredients.map((ing) {
                  final qtyText = (ing.amount ?? '') + ((ing.amount != null && ing.amount!.isNotEmpty && ing.unit != null && ing.unit!.isNotEmpty) ? ' ' : '') + (ing.unit ?? '');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(ing.name ?? '', style: TextStyle(fontFamily: 'GowunDodum', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(qtyText, textAlign: TextAlign.right, style: TextStyle(fontFamily: 'GowunDodum', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black)),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade300, height: 1),
              const SizedBox(height: 24),

              // Culinary Notes
              Text('조리 기록', style: TextStyle(fontFamily: 'Hahmlet', fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Colors.black)),
              const SizedBox(height: 24),
              
              Container(
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.black, width: 2.5)),
                ),
                padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
                child: Text(
                  recipe.memo?.isEmpty ?? true ? '적어둔 기록이 없습니다' : recipe.memo!,
                  style: TextStyle(fontFamily: 'GowunDodum', fontSize: 14, height: 1.8, color: Colors.grey.shade600, fontWeight: FontWeight.w400),
                ),
              ),
              
              const SizedBox(height: 64),
              
              // Source Link
              if (recipe.youtubeUrl != null && recipe.youtubeUrl!.isNotEmpty) ...[
                Center(
                  child: Column(
                    children: [
                      Text('출처 기록', style: TextStyle(fontFamily: 'GowunDodum', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.grey.shade500)),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _launchUrl(context, recipe.youtubeUrl!),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 4),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('원문 보기', style: TextStyle(fontFamily: 'GowunDodum', color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.5)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_outward, color: Colors.black, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 60),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
