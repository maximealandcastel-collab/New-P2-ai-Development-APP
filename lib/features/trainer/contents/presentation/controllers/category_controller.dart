import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/models/category_model.dart';
import 'package:pler_to_pler_app/features/trainer/contents/domain/services/category_service.dart';

class CategoryController extends GetxController {
  CategoryController({
    required CategoryService service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final CategoryService _service;
  final ConnectivityService _connectivityService;

  static CategoryController get to => Get.find();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _submitLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteLoadingState = LoadingState.initial.obs;

  List<CategoryModel> get categories => _categories.where((e) => e.isActive == true).toList();

  LoadingState get loadingState => _loadingState.value;
  LoadingState get submitLoadingState => _submitLoadingState.value;
  LoadingState get deleteLoadingState => _deleteLoadingState.value;

  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) fetchCategories();
    });
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final hasCache = _service.hasCache();
      final isOnline = _connectivityService.isConnected.value;

      if (hasCache) {
        _categories.value = _service.getCachedCategories();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) {
        if (!hasCache) _loadingState.value = LoadingState.offline;
        return;
      }

      final result = await _service.fetchMyCategories();
      _categories.value = result;
      _loadingState.value = LoadingState.loaded;
    } on AppException catch (e) {
      if (_service.hasCache()) {
        _categories.value = _service.getCachedCategories();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('fetchCategories error: $e');
    } catch (e) {
      if (_service.hasCache()) {
        _categories.value = _service.getCachedCategories();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('fetchCategories error: $e');
    }
  }

  void setEditCategory(CategoryModel? category) {
    nameController.text = category?.category ?? '';
    descriptionController.text = category?.description ?? '';
  }

  Future<bool> submitCategory({CategoryModel? editingCategory}) async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) return false;

    try {
      _submitLoadingState.value = LoadingState.loading;

      if (editingCategory?.id != null) {
        await _service.updateCategory(
          categoryId: editingCategory!.id!,
          category: name,
          description: description,
        );
      } else {
        await _service.createCategory(
          category: name,
          description: description,
        );
      }

      _submitLoadingState.value = LoadingState.loaded;
      await fetchCategories();
      clearForm();
      Get.back(result: true);
      return true;
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _submitLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('submitCategory error: $e');
      return false;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      _deleteLoadingState.value = LoadingState.loading;
      await _service.deleteCategory(categoryId);
      _deleteLoadingState.value = LoadingState.loaded;
      await fetchCategories();
      Get.back(canPop: true);
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _deleteLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('deleteCategory error: $e');
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
