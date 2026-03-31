import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:image_picker/image_picker.dart';
import '../../models/recipe.dart';
import '../../models/ingredient.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/tags_provider.dart';
import '../../providers/units_provider.dart';

class RecipeEditScreen extends ConsumerStatefulWidget {
  final int? recipeId;
  const RecipeEditScreen({super.key, this.recipeId});

  @override
  ConsumerState<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends ConsumerState<RecipeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _memoController = TextEditingController();
  
  final _ingNameController = TextEditingController();
  final _ingQtyController = TextEditingController();
  String? _selectedUnit;
  
  List<Ingredient> _ingredients = [];
  List<String> _selectedTags = [];
  String? _coverPhotoPath;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.recipeId != null) {
      final repo = ref.read(recipeRepositoryProvider);
      final recipe = await repo.getRecipe(widget.recipeId!);
      if (recipe != null) {
        _titleController.text = recipe.title;
        _youtubeController.text = recipe.youtubeUrl ?? '';
        _memoController.text = recipe.memo ?? '';
        _selectedTags = List.from(recipe.tags);
        _coverPhotoPath = recipe.coverPhotoPath;
        _ingredients = List.from(recipe.ingredients);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _youtubeController.dispose();
    _memoController.dispose();
    _ingNameController.dispose();
    _ingQtyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverPhotoPath = pickedFile.path;
      });
    }
  }

  void _addIngredientInline() {
    final name = _ingNameController.text.trim();
    final qty = _ingQtyController.text.trim();
    final unit = _selectedUnit ?? '';
    
    if (name.isNotEmpty) {
      setState(() {
        _ingredients.add(Ingredient()..name = name..amount = qty..unit = unit);
        _ingNameController.clear();
        _ingQtyController.clear();
        // Keep _selectedUnit as is for convenience
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_ingNameController.text.trim().isNotEmpty) {
      _addIngredientInline();
    }
    
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재료를 하나 이상 적어주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final repo = ref.read(recipeRepositoryProvider);
    
    Recipe recipe;
    if (widget.recipeId != null) {
      recipe = (await repo.getRecipe(widget.recipeId!))!;
    } else {
      recipe = Recipe();
    }

    recipe.title = _titleController.text.trim();
    recipe.youtubeUrl = _youtubeController.text.trim().isEmpty ? null : _youtubeController.text.trim();
    recipe.memo = _memoController.text.trim().isEmpty ? null : _memoController.text.trim();
    recipe.ingredients = _ingredients;
    recipe.tags = _selectedTags;
    recipe.coverPhotoPath = _coverPhotoPath;

    await repo.saveRecipe(recipe);

    ref.invalidate(recipeListProvider);
    if (widget.recipeId != null) {
      ref.invalidate(recipeDetailProvider(widget.recipeId!));
    }

    if (mounted) context.pop();
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: TextStyle(fontFamily: 'Hahmlet', fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Colors.black)),
    );
  }

  Widget _shadowInput({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _minimalistInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'GowunDodum', fontSize: 13, color: Colors.grey.shade400),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsyncValue = ref.watch(tagsProvider);
    final availableTags = tagsAsyncValue.value?.map((t) => t.name).toList() ?? [];

    final unitsAsyncValue = ref.watch(unitsProvider);
    final dbUnits = unitsAsyncValue.value?.map((u) => u.name).toList() ?? [];
    
    // Ensure selected unit is valid or reset to null
    if (_selectedUnit != null && !dbUnits.contains(_selectedUnit)) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) setState(() => _selectedUnit = null);
       });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('DOMA'),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 60, top: 16),
              children: [
                // Cover Photo Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_coverPhotoPath != null && _coverPhotoPath!.isNotEmpty)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                child: Image.file(File(_coverPhotoPath!), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                              const SizedBox(width: 8),
                              Text('표지 바꾸기', style: TextStyle(fontFamily: 'GowunDodum')),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                _sectionLabel('조리명'),
                _shadowInput(
                  child: TextFormField(
                    controller: _titleController,
                    style: TextStyle(fontFamily: 'GowunDodum', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                    decoration: _minimalistInputDecoration('조리법의 이름을 적어주세요'),
                    validator: (value) => value == null || value.trim().isEmpty ? '조리명을 적어주세요' : null,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                _sectionLabel('재료'),
                // Active Ingredients List
                ..._ingredients.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Ingredient ing = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Text('•  ', style: TextStyle(fontFamily: 'GowunDodum')),
                        Expanded(child: Text(ing.name ?? '', style: TextStyle(fontFamily: 'GowunDodum'))),
                        Text('${ing.amount ?? ''} ${ing.unit ?? ''}'.trim(), style: TextStyle(fontFamily: 'GowunDodum')),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _removeIngredient(idx),
                          child: Icon(Icons.close, size: 14, color: Colors.grey.shade300),
                        )
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 8),
                // Input Row for Ingredients
                _shadowInput(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _ingNameController,
                            style: TextStyle(fontFamily: 'GowunDodum', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                            decoration: InputDecoration(
                              hintText: '재료명', 
                              hintStyle: TextStyle(fontFamily: 'GowunDodum', fontSize: 13, color: Colors.grey.shade400),
                              border: InputBorder.none, 
                              isDense: true
                            ),
                          ),
                        ),
                        Container(height: 24, width: 1, color: Colors.grey.shade200),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _ingQtyController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'GowunDodum', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                            decoration: InputDecoration(
                              hintText: '수량', 
                              hintStyle: TextStyle(fontFamily: 'GowunDodum', fontSize: 13, color: Colors.grey.shade400),
                              border: InputBorder.none, 
                              isDense: true
                            ),
                          ),
                        ),
                        Container(height: 24, width: 1, color: Colors.grey.shade200),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: Text('단위', style: TextStyle(fontFamily: 'GowunDodum', fontSize: 13, color: Colors.grey.shade400)),
                              value: _selectedUnit,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, size: 16),
                              style: TextStyle(fontFamily: 'GowunDodum', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                              alignment: Alignment.center,
                              items: [
                                ...dbUnits.map((u) => DropdownMenuItem(value: u, child: Center(child: Text(u, style: const TextStyle(color: Colors.black))))),
                                const DropdownMenuItem(value: '__EDIT__', child: Center(child: Text('✎ 단위 편집', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)))),
                              ],
                              onChanged: (val) {
                                if (val == '__EDIT__') {
                                  context.push('/units');
                                } else if (val != null) {
                                  setState(() => _selectedUnit = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _addIngredientInline,
                    icon: const Icon(Icons.add_circle),
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),
                _sectionLabel('조리 기록'),
                _shadowInput(
                  child: TextFormField(
                    controller: _memoController,
                    maxLines: 5,
                    style: TextStyle(fontFamily: 'GowunDodum', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black, height: 1.6),
                    decoration: _minimalistInputDecoration('만드는 법이나 덧붙일 내용을 적어주세요'),
                  ),
                ),

                const SizedBox(height: 32),
                _sectionLabel('출처'),
                _shadowInput(
                  child: TextFormField(
                    controller: _youtubeController,
                    style: TextStyle(fontFamily: 'GowunDodum', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                    decoration: _minimalistInputDecoration('출처 링크를 적어주세요'),
                  ),
                ),

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('분류'),
                    GestureDetector(
                      onTap: () => context.push('/tags'),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text('편집', style: TextStyle(fontFamily: 'GowunDodum', fontSize: 11, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, color: Colors.grey.shade600)),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ...availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTags.remove(tag);
                            } else {
                              _selectedTags.add(tag);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            border: isSelected ? Border.all(color: Colors.black) : Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag.toUpperCase(),
                            style: TextStyle(fontFamily: 'GowunDodum', color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () => context.push('/tags'),
                      child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey.shade200),
                           borderRadius: BorderRadius.circular(20),
                           color: Colors.white,
                           boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                         ),
                         child: Icon(Icons.add, size: 16, color: Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Save Button (securely within scroll bounds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('기록 보관하기', style: TextStyle(fontFamily: 'Hahmlet', fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
