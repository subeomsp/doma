import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/recipe_provider.dart';
import '../../providers/tags_provider.dart';

class TagManagementScreen extends ConsumerStatefulWidget {
  const TagManagementScreen({super.key});

  @override
  ConsumerState<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends ConsumerState<TagManagementScreen> {
  final _tagController = TextEditingController();

  Future<void> _addTag() async {
    final text = _tagController.text.trim();
    if (text.isNotEmpty) {
      final repo = ref.read(recipeRepositoryProvider);
      await repo.addTag(text);
      ref.invalidate(tagsProvider);
      _tagController.clear();
    }
  }

  Future<void> _deleteTag(int id) async {
    final repo = ref.read(recipeRepositoryProvider);
    await repo.deleteTag(id);
    ref.invalidate(tagsProvider);
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('분류 관리'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('새 분류 추가하기', style: TextStyle(fontFamily: 'GowunDodum')),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 2, offset: const Offset(0, 1)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      style: TextStyle(fontFamily: 'GowunDodum'),
                      decoration: InputDecoration(
                        hintText: '예: 한식, 매운맛, 손님상',
                        hintStyle: TextStyle(fontFamily: 'GowunDodum'),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: _addTag,
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('등록된 분류', style: TextStyle(fontFamily: 'GowunDodum')),
            const SizedBox(height: 12),
            Expanded(
              child: tagsAsync.when(
                data: (tags) {
                  if (tags.isEmpty) {
                    return Center(child: Text('아직 분류가 없습니다', style: TextStyle(fontFamily: 'GowunDodum')));
                  }
                  return ListView.builder(
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(tag.name.toUpperCase(), style: TextStyle(fontFamily: 'GowunDodum')),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                            onPressed: () => _deleteTag(tag.id),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
