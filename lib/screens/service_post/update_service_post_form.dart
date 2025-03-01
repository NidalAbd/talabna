import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/interaction_widget/point_balance.dart';
import 'package:talbna/screens/widgets/category_dropdown.dart';
import 'package:talbna/screens/widgets/error_widget.dart';
import 'package:talbna/screens/widgets/image_picker_button.dart';
import 'package:talbna/screens/widgets/location_picker.dart';
import 'package:talbna/screens/widgets/subcategory_dropdown.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../../provider/language.dart';

class UpdatePostScreen extends StatefulWidget {
  final int userId;
  final int servicePostId;
  final ServicePost servicePost;

  const UpdatePostScreen({
    super.key,
    required this.userId,
    required this.servicePostId,
    required this.servicePost,
  });

  @override
  _UpdatePostScreenState createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ImagePickerButtonState> _imagePickerButtonKey =
      GlobalKey<ImagePickerButtonState>();
  final Language _language = Language();
  final PageController _pageController = PageController();
  late final ValueNotifier<List<Photo>> _photosNotifier;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _typeController;
  late final String _selectedPriceCurrency;

  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;
  List<Photo>? _pickedImages;
  bool _isLoading = false;
  bool _isFormDirty = false;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {'title': 'الصور', 'icon': Icons.image},
    {'title': 'التفاصيل', 'icon': Icons.description},
    {'title': 'الفئة', 'icon': Icons.category},
    {'title': 'السعر', 'icon': Icons.monetization_on},
  ];

  @override
  void initState() {
    super.initState();
    _photosNotifier = ValueNotifier(widget.servicePost.photos ?? []);
    _initializeData();
  }

  void _initializeData() {
    final post = widget.servicePost;

    // Initialize controllers
    _titleController = TextEditingController(text: post.title);
    _descriptionController = TextEditingController(text: post.description);
    _priceController = TextEditingController(text: post.price?.toString() ?? '0');
    _typeController = TextEditingController(text: post.type ?? 'عرض');

    // Add listeners after setting initial values
    _titleController.addListener(_markFormDirty);
    _descriptionController.addListener(_markFormDirty);
    _priceController.addListener(_markFormDirty);

    // Initialize state variables
    _selectedPriceCurrency = post.priceCurrency ?? 'دولار امريكي';
    _selectedCategory = post.category;
    _selectedSubCategory = post.subCategory;

    // Initialize photos with a direct copy
    if (post.photos != null && post.photos!.isNotEmpty) {
      _pickedImages = List<Photo>.from(post.photos!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _photosNotifier.value = List<Photo>.from(post.photos!);
      });
    }
  }
  void _markFormDirty() {
    if (!mounted) return;
    Future.microtask(() {
      if (!_isFormDirty) {
        setState(() => _isFormDirty = true);
      }
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Images
        return true;
      case 1: // Details
        return _titleController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty;
      case 2: // Category
        return _selectedCategory != null && _selectedSubCategory != null;
      case 3: // Price
        if (_selectedCategory?.id == 7) return true;
        final price = double.tryParse(_priceController.text) ?? 0;
        return price > 0;
      default:
        return true;
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: Colors.grey[200],
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 16),
          _buildStepsList(),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          final step = _steps[index];
          final isActive = _currentStep == index;
          final isCompleted = index < _currentStep;

          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : isCompleted
                            ? Colors.green
                            : Colors.grey[300],
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: isActive || isCompleted ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step['title'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isActive ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _language.tImageText(),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ImagePickerButton(
                key: _imagePickerButtonKey,
                onImagesPicked: (photos) {
                  if (photos != null) {
                    setState(() {
                      _pickedImages = List<Photo>.from(photos);
                      _photosNotifier.value = photos;
                      _markFormDirty();
                    });
                  }
                },
                initialPhotosNotifier: _photosNotifier,
                maxImages: 4,
                deleteApi: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                textDirection: TextDirection.rtl,
                maxLength: 14,
                decoration: InputDecoration(
                  labelText: _language.tTitleText(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? _language.tRequiredText() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLength: 5000,
                textDirection: TextDirection.rtl,
                minLines: 1,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: _language.tDescriptionText(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? _language.tRequiredText() : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return SingleChildScrollView(
        child: Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoriesDropdown(
              onCategorySelected: (newCategory) {
                if (!mounted) return;
                Future.microtask(() {
                  setState(() {
                    _selectedCategory = newCategory;
                    // Only reset subcategory if category changed
                    if (newCategory.id != widget.servicePost.category?.id) {
                      _selectedSubCategory = null;
                    }
                    _markFormDirty();
                  });
                });
              },
              language: _language.toString(),
              initialValue: widget.servicePost.category,
            ),
            const SizedBox(height: 16),
            SubCategoriesDropdown(
              selectedCategory:
                  _selectedCategory ?? widget.servicePost.category,
              onSubCategorySelected: (newSubCategory) {
                if (!mounted) return;
                Future.microtask(() {
                  setState(() {
                    _selectedSubCategory = newSubCategory;
                    _markFormDirty();
                  });
                });
              },
              initialValue: widget.servicePost.subCategory,
              selectedSubCategory:
                  _selectedSubCategory ?? widget.servicePost.subCategory,
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildPriceSection() {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedCategory?.id != 7) ...[
                TextFormField(
                  controller: _priceController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: _language.tPriceText(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return _language.tRequiredText();
                    if (double.tryParse(value!) == null)
                      return _language.tInvalidNumberText();
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: _language.tCurrencyText(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _selectedPriceCurrency,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _markFormDirty();
                    });
                  }
                },
                items: const ['دولار امريكي', 'دينار اردني', 'شيكل']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: _language.tTypeText(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _typeController.text,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _typeController.text = newValue;
                      _markFormDirty();
                    });
                  }
                },
                items: const ['عرض', 'طلب']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate() || !_validateForm()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create updated service post with current photos
      final updatedPost = ServicePost(
        id: widget.servicePostId,
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        priceCurrency: _selectedPriceCurrency,
        locationLatitudes: widget.servicePost.locationLatitudes,
        locationLongitudes: widget.servicePost.locationLongitudes,
        userId: widget.userId,
        type: _typeController.text,
        category: _selectedCategory ?? widget.servicePost.category,
        subCategory: _selectedSubCategory ?? widget.servicePost.subCategory,
        photos: _pickedImages,
      );

      // Convert photos to MultipartFile objects
      final List<http.MultipartFile> imageFiles = [];
      if (_pickedImages != null) {
        for (var photo in _pickedImages!) {
          // Only process new photos (ones without an ID)
          if (photo.id == null && photo.src != null) {
            try {
              final file = File(photo.src!);
              if (await file.exists()) {
                final bytes = await file.readAsBytes();
                final mimeType = lookupMimeType(photo.src!) ??
                    (photo.isVideo ?? false ? 'video/mp4' : 'image/jpeg');

                final multipartFile = http.MultipartFile.fromBytes(
                  'images[]',
                  bytes,
                  filename: p.basename(photo.src!),
                  contentType: MediaType.parse(mimeType),
                );
                imageFiles.add(multipartFile);
              }
            } catch (e) {
              print('Error processing image: $e');
            }
          }
        }
      }

      // Add the update events
      context.read<ServicePostBloc>().add(
          UpdateServicePostEvent(updatedPost, imageFiles)
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_language.tPostUpdatedSuccessfully()))
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Submit error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_language.tErrorUpdatingPost()))
        );
      }
    }
  }

  Future<List<http.MultipartFile>> _processImages() async {
    final imageFiles = <http.MultipartFile>[];
    final localImages = _imagePickerButtonKey.currentState?.getLocalImages();

    if (localImages == null || localImages.isEmpty) return imageFiles;

    for (final photo in localImages) {
      if (photo.src == null) continue;

      // Skip if it's a server URL
      if (photo.src!.startsWith('http')) continue;

      try {
        final file = File(photo.src!);
        final bytes = await file.readAsBytes();
        final mimeType = lookupMimeType(photo.src!) ?? 'image/jpeg';

        if (_isValidImageType(mimeType)) {
          final imageFile = http.MultipartFile.fromBytes(
            'images[]',
            bytes,
            filename: p.basename(photo.src!),
            contentType: MediaType.parse(mimeType),
          );
          imageFiles.add(imageFile);
        }
      } catch (e) {
        print('Error processing image: $e');
      }
    }

    return imageFiles;
  }

  bool _isValidImageType(String mimeType) {
    return ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'video/mp4']
        .contains(mimeType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_language.tUpdateText()),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PointBalance(
              userId: widget.userId,
              showBalance: true,
              canClick: true,
            ),
          ),
        ],
      ),
      body: BlocListener<ServicePostBloc, ServicePostState>(
        listener: (context, state) {
          print('Current state: $state'); // Debug state changes

          if (state is ServicePostOperationSuccess) {
            if (mounted) {
              setState(() => _isLoading = false);
              showCustomSnackBar(context, 'success',
                  type: SnackBarType.success);
              Navigator.of(context).pop();
            }
          } else if (state is ServicePostImageDeletingSuccess) {
            if (mounted) {
              showCustomSnackBar(context, 'info', type: SnackBarType.info);
            }
          } else if (state is ServicePostOperationFailure) {
            print(
                'Operation failure: ${state.errorMessage}'); // Debug error message
            if (mounted) {
              setState(() => _isLoading = false);
              ErrorCustomWidget.show(context, message: state.errorMessage);
            }
          }
        },
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildStepIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    if (mounted) {
                      setState(() => _currentStep = index);
                    }
                  },
                  children: [
                    _buildImageSection(),
                    _buildDetailsSection(),
                    _buildCategorySection(),
                    _buildPriceSection(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (mounted) {
                        setState(() {
                          _currentStep--;
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      }
                    },
              icon: const Icon(Icons.arrow_back),
              label: Text(_language.tPreviousText()),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ElevatedButton.icon(
            onPressed: _isLoading
                ? null
                : () {
                    if (_currentStep < _steps.length - 1) {
                      if (_validateCurrentStep()) {
                        if (mounted) {
                          setState(() {
                            _currentStep++;
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(_language.tFillAllFieldsText())),
                        );
                      }
                    } else {
                      if (_validateForm()) {
                        handleSubmit();
                      }
                    }
                  },
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(_currentStep < _steps.length - 1
                    ? Icons.arrow_forward
                    : Icons.check),
            label: Text(_currentStep < _steps.length - 1
                ? _language.tNextText()
                : _language.tUpdateText()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    if (_selectedCategory == null || _selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_language.tSelectCategoryText())));
      return false;
    }

    if (_selectedCategory?.id != 7) {
      final price = double.tryParse(_priceController.text) ?? 0;
      if (price <= 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_language.tEnterPriceText())));
        return false;
      }
    }

    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_language.tFillAllFieldsText())));
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _typeController.dispose();
    _pageController.dispose();
    _photosNotifier.dispose();

    super.dispose();
  }
}
