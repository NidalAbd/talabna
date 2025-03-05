import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/interaction_widget/point_balance.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';
import 'package:talbna/screens/widgets/category_dropdown.dart';
import 'package:talbna/screens/widgets/image_picker_button.dart';
import 'package:talbna/screens/widgets/subcategory_dropdown.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import 'package:talbna/utils/functions.dart';
import '../../data/models/photos.dart';
import '../../provider/language.dart';

class ServicePostFormScreen extends StatefulWidget {
  const ServicePostFormScreen({super.key, required this.userId});
  final int userId;

  @override
  State<ServicePostFormScreen> createState() => _ServicePostFormScreenState();
}

class _ServicePostFormScreenState extends State<ServicePostFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  final GlobalKey<ImagePickerButtonState> _imagePickerButtonKey = GlobalKey<ImagePickerButtonState>();
  final PageController _pageController = PageController();
  final Language _language = Language();
  final ValueNotifier<List<Photo>?> _initialPhotos = ValueNotifier(null);
  final ScrollController _scrollController = ScrollController();

  // Form data storage
  final Map<String, dynamic> _formData = {};

  int _currentStep = 0;
  String _title = '';
  String _description = '';
  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;
  double _price = 0;
  final double _locationLatitudes = 31.9539;
  final double _locationLongitudes = 35.2376;
  List<Photo> _pickedImages = [];
  String _selectedPriceCurrency = 'دولار امريكي';
  String _selectedType = 'عرض';
  String _selectedHaveBadge = 'عادي';
  int _selectedBadgeDuration = 0;
  int _calculatedPoints = 0;
  bool balanceOut = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with saved values
    _titleController = TextEditingController(text: _formData['title'] ?? '');
    _descriptionController = TextEditingController(text: _formData['description'] ?? '');
    _priceController = TextEditingController(text: (_formData['price'] ?? 0).toString());

    // Initialize state from saved form data
    _title = _formData['title'] ?? '';
    _description = _formData['description'] ?? '';
    _price = _formData['price'] ?? 0;
    _selectedCategory = _formData['category'];
    _selectedSubCategory = _formData['subCategory'];
    _pickedImages = List<Photo>.from(_formData['images'] ?? []);
    _selectedPriceCurrency = _formData['priceCurrency'] ?? 'دولار امريكي';
    _selectedType = _formData['type'] ?? 'عرض';
    _selectedHaveBadge = _formData['haveBadge'] ?? 'عادي';
    _selectedBadgeDuration = _formData['badgeDuration'] ?? 0;

    // Set initial photos
    _initialPhotos.value = _pickedImages;

    // Add listeners to update both state and form data
    _titleController.addListener(() {
      setState(() {
        _title = _titleController.text;
        _saveFormData('title', _title);
      });
    });

    _descriptionController.addListener(() {
      setState(() {
        _description = _descriptionController.text;
        _saveFormData('description', _description);
      });
    });

    _priceController.addListener(() {
      setState(() {
        _price = double.tryParse(_priceController.text) ?? 0;
        _saveFormData('price', _price);
      });
    });
  }

  void _saveFormData(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
  }

  List<Map<String, dynamic>> get _formSteps => [
    {
      'title': _language.tImageText(),
      'icon': Icons.image,
      'isCompleted': true,
      'content': _buildImageSection(),
    },
    {
      'title': _language.tTitleText(),
      'icon': Icons.description,
      'isCompleted': _title.isNotEmpty && _description.isNotEmpty,
      'content': _buildDetailsSection(),
    },
    {
      'title': _language.tCategoryText(),
      'icon': Icons.category,
      'isCompleted': _selectedCategory != null && _selectedSubCategory != null,
      'content': _buildCategorySection(),
    },
    {
      'title': _language.tPriceText(),
      'icon': Icons.monetization_on,
      'isCompleted': _selectedCategory?.id == 7 || _price > 0,
      'content': _buildPricingSection(),
    },
    {
      'title': _language.tFeaturedText(),
      'icon': Icons.star,
      'isCompleted': true,
      'content': _buildFeaturesSection(),
    },
  ];

  void _updateCalculatedPoints() {
    final int haveBadge = _selectedHaveBadge == 'ذهبي'
        ? 2
        : _selectedHaveBadge == 'ماسي'
        ? 10
        : 0;
    _calculatedPoints = _selectedBadgeDuration * haveBadge;
    setState(() {});
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        if (_title.isEmpty || _description.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_language.tFillAllFieldsText())),
          );
          return false;
        }
        break;
      case 2:
        if (_selectedCategory == null || _selectedSubCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_language.tSelectCategoryText())),
          );
          return false;
        }
        break;
      case 3:
        if (_selectedCategory?.id != 7 && _price <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_language.tEnterPriceText())),
          );
          return false;
        }
        break;
    }
    return true;
  }

  Widget _buildStepIndicator() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _formSteps.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _formSteps.length,
              itemBuilder: (context, index) {
                final step = _formSteps[index];
                final isActive = _currentStep == index;
                final isCompleted = step['isCompleted'] as bool;

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
                          color: isActive
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
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
          ),
        ],
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
                onImagesPicked: (List<Photo>? pickedPhotos) {
                  if (pickedPhotos != null) {
                    setState(() {
                      _pickedImages = pickedPhotos;
                      _saveFormData('images', pickedPhotos);
                    });
                  }
                },
                initialPhotosNotifier: _initialPhotos,
                maxImages: 4,
                deleteApi: false,
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
                decoration: InputDecoration(
                  labelText: _language.tTitleText(),
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                textDirection: TextDirection.rtl,
                maxLength: 14,
                validator: (value) =>
                (value?.isEmpty ?? true) ? _language.tRequiredText() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: _language.tDescriptionText(),
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLength: 5000,
                maxLines: 3,
                textDirection: TextDirection.rtl,
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
                onCategorySelected: (Category newCategory) {
                  setState(() {
                    _selectedCategory = newCategory;
                    _selectedSubCategory = null;
                    _saveFormData('category', newCategory);
                    _saveFormData('subCategory', null);
                  });
                },
                language: _language.toString(),
                initialValue: _selectedCategory,
              ),
              const SizedBox(height: 16),
              if (_selectedCategory != null)
                SubCategoriesDropdown(
                  selectedCategory: _selectedCategory,
                  onSubCategorySelected: (SubCategory newSubCategory) {
                    setState(() {
                      _selectedSubCategory = newSubCategory;
                      _saveFormData('subCategory', newSubCategory);
                    });
                  },
                  selectedSubCategory: _selectedSubCategory,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    if (_selectedCategory?.id == 7) {
      return Center(child: Text(_language.tPriceNotRequiredText()));
    }

    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: _language.tPriceText(),
                  prefixIcon: const Icon(Icons.monetization_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                textDirection: TextDirection.rtl,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return _language.tRequiredText();
                  if (double.tryParse(value!) == null) return _language.tInvalidNumberText();
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: _language.tCurrencyText(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _selectedPriceCurrency,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPriceCurrency = newValue;
                      _saveFormData('priceCurrency', newValue);
                    });
                  }
                },
                items: ['دولار امريكي', 'دينار اردني', 'شيكل']
                    .map((String value) => DropdownMenuItem<String>(
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
                value: _selectedType,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                      _saveFormData('type', newValue);
                    });
                  }
                },
                items: ['عرض', 'طلب']
                    .map((String value) => DropdownMenuItem<String>(
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

  Widget _buildFeaturesSection() {
    if (_selectedCategory?.id == 7) {
      return Center(child: Text(_language.tFeaturesNotAvailableText()));
    }

    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: _language.tFeaturedText(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _selectedHaveBadge,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedHaveBadge = newValue;
                      if (_selectedHaveBadge == 'عادي') {
                        _selectedBadgeDuration = 0;
                        _saveFormData('badgeDuration', 0);
                      } else if (_selectedBadgeDuration == 0) {
                        _selectedBadgeDuration = 1;
                        _saveFormData('badgeDuration', 1);
                      }
                      _saveFormData('haveBadge', newValue);
                      _updateCalculatedPoints();
                    });
                  }
                },
                items: ['عادي', 'ذهبي', 'ماسي']
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
              ),
              if (_selectedHaveBadge != 'عادي') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: _language.tDurationText(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: _selectedBadgeDuration,
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedBadgeDuration = newValue;
                        _saveFormData('badgeDuration', newValue);
                        _updateCalculatedPoints();
                      });
                    }
                  },
                  items: <int>[0, 1, 2, 3, 4, 5, 6, 7]
                      .where((int value) => _selectedHaveBadge == 'عادي' ? true : value != 0)
                      .map((int value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text('${_language.tDayText()} $value'),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _language.tPointsDeductionText(_calculatedPoints, _selectedHaveBadge, _selectedBadgeDuration),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
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
              onPressed: _isSubmitting ? null : () {
                setState(() {
                  _currentStep--;
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
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
            onPressed: _isSubmitting ? null : () {
              if (_currentStep < _formSteps.length - 1) {
                if (_validateCurrentStep()) {
                  setState(() {
                    _currentStep++;
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              } else {
                _submitForm();
              }
            },
            icon: _isSubmitting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Icon(_currentStep < _formSteps.length - 1
                ? Icons.arrow_forward
                : Icons.check),
            label: Text(_currentStep < _formSteps.length - 1
                ? _language.tNextText()
                : _language.tCreateText()),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      if (!_validateCurrentStep()) {
        setState(() => _isSubmitting = false);
        return;
      }

      // Validate required fields
      if (_selectedCategory == null || _selectedSubCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_language.tSelectCategoryText())),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      checkBadgeAndShowMessage(context, _selectedHaveBadge, _selectedBadgeDuration);

      final imageFiles = <http.MultipartFile>[];

      // Process images if any are selected
      for (final photo in _pickedImages) {
        if (photo.src != null) {
          try {
            final file = File(photo.src!);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final mimeType = lookupMimeType(photo.src!) ?? 'image/jpeg';

              if (['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'video/mp4']
                  .contains(mimeType)) {
                final imageFile = http.MultipartFile.fromBytes(
                  'images[]',
                  bytes,
                  filename: p.basename(photo.src!),
                  contentType: MediaType.parse(mimeType),
                );
                imageFiles.add(imageFile);
              }
            }
          } catch (e) {
            print('Error processing image: $e');
          }
        }
      }

      final servicePost = ServicePost(
        title: _title,
        description: _description,
        price: _price,
        priceCurrency: _selectedPriceCurrency,
        locationLatitudes: _locationLatitudes,
        locationLongitudes: _locationLongitudes,
        userId: widget.userId,
        type: _selectedType,
        haveBadge: _selectedHaveBadge,
        badgeDuration: _selectedBadgeDuration,
        category: _selectedCategory!,
        subCategory: _selectedSubCategory!,
        photos: _pickedImages,
      );

      context.read<ServicePostBloc>().add(CreateServicePostEvent(servicePost, imageFiles));
    } catch (e) {
      print('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_language.tErrorText())),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_language.tCreatePostText()),
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
          if (state is ServicePostOperationSuccess) {
            setState(() => _isSubmitting = false);
            showCustomSnackBar(context, 'success', type: SnackBarType.success);
            Navigator.of(context).pop();
          } else if (state is ServicePostLoading) {
            // Loading is handled by button state
          } else if (state is ServicePostOperationFailure) {
            setState(() => _isSubmitting = false);
            if (state.errorMessage.contains(_language.tInsufficientBalanceText())) {
              setState(() => balanceOut = true);
            }
            showCustomSnackBar(context, 'error', type: SnackBarType.error);
          }
        },
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: _formSteps.map((step) => step['content'] as Widget).toList(),
              ),
            ),
            _buildNavigationButtons(),
            if (balanceOut) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(_language.tInsufficientBalanceText()),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PurchaseRequestScreen(
                              userID: widget.userId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_language.tPurchasePointsText()),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}