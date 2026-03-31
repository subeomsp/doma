import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/recipe_provider.dart';
import '../../providers/units_provider.dart';

class UnitManagementScreen extends ConsumerStatefulWidget {
  const UnitManagementScreen({super.key});

  @override
  ConsumerState<UnitManagementScreen> createState() => _UnitManagementScreenState();
}

class _UnitManagementScreenState extends ConsumerState<UnitManagementScreen> {
  final _unitController = TextEditingController();

  Future<void> _addUnit() async {
    final text = _unitController.text.trim();
    if (text.isNotEmpty) {
      final repo = ref.read(recipeRepositoryProvider);
      await repo.addUnit(text);
      ref.invalidate(unitsProvider);
      _unitController.clear();
    }
  }

  Future<void> _deleteUnit(int id) async {
    final repo = ref.read(recipeRepositoryProvider);
    await repo.deleteUnit(id);
    ref.invalidate(unitsProvider);
  }

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('단위 관리'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('새 단위 추가하기', style: TextStyle(fontFamily: 'GowunDodum')),
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
                      controller: _unitController,
                      style: TextStyle(fontFamily: 'GowunDodum'),
                      decoration: InputDecoration(
                        hintText: '예: 꼬집, 컵, 큰술',
                        hintStyle: TextStyle(fontFamily: 'GowunDodum'),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onSubmitted: (_) => _addUnit(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: _addUnit,
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('등록된 단위', style: TextStyle(fontFamily: 'GowunDodum')),
            const SizedBox(height: 12),
            Expanded(
              child: unitsAsync.when(
                data: (units) {
                  if (units.isEmpty) {
                    return Center(child: Text('아직 단위가 없습니다', style: TextStyle(fontFamily: 'GowunDodum')));
                  }
                  return ListView.builder(
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(unit.name, style: TextStyle(fontFamily: 'GowunDodum')),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                            onPressed: () => _deleteUnit(unit.id),
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
