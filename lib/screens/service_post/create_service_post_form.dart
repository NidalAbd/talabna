import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';

import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/service_post.dart';

import 'package:talbna/screens/interaction_widget/point_balance.dart';
import 'package:talbna/screens/widgets/category_dropdown.dart';
import 'package:talbna/screens/widgets/image_picker_button.dart';
import 'package:talbna/screens/widgets/location_picker.dart';
import 'package:talbna/screens/widgets/subcategory_dropdown.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/utils/functions.dart';
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ServicePostFormScreen extends StatefulWidget {
  const ServicePostFormScreen({Key? key,required this.userId}) : super(key: key);
  final int userId;
  @override
  State<ServicePostFormScreen> createState() => _ServicePostFormScreenState();
}

class _ServicePostFormScreenState extends State<ServicePostFormScreen> {
  final GlobalKey<ImagePickerButtonState> _imagePickerButtonKey = GlobalKey<ImagePickerButtonState>();
  final _formKey = GlobalKey<FormState>();
  late String _title = '';
  late String _description= '';
  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;
  late double _price = 0;
  late double _locationLatitudes = 0.0;
  late double _locationLongitudes = 0.0;
  late List<Photo> _pickedImages = [];
  late String _selectedPriceCurrency = 'شيكل';
  late String _selectedType = 'عرض';
  late String _selectedHaveBadge = 'عادي';
  late int _selectedBadgeDuration = _selectedHaveBadge == 'عادي' ? 0 : 1;
  late int _calculatedPoints = 0;
  final ValueNotifier<List<Photo>?> _initialPhotos = ValueNotifier(null);
  Widget _buildImagePickerButton() {
    return ImagePickerButton(
      key: _imagePickerButtonKey,
      onImagesPicked: (List<Photo>? pickedPhotos) {
        if (pickedPhotos != null) {
          setState(() {
            _pickedImages = pickedPhotos;
          });
        }
      },
      initialPhotosNotifier: _initialPhotos,
    );
  }
  Future<void> _submitForm() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()){
      checkBadgeAndShowMessage(context, _selectedHaveBadge, _selectedBadgeDuration);
      if (_selectedCategory == null || _selectedSubCategory == null) {
        ErrorWidget('Please select a category and subcategory.');
        return;
      }
      final imageFiles = <http.MultipartFile>[];
      for (final photo in _pickedImages) {
        if (photo.src != null) {
          final bytes = await File(photo.src!).readAsBytes();
          final mimeType = lookupMimeType(photo.src!);
          if (mimeType == 'image/jpeg' ||
              mimeType == 'image/jpg' ||
              mimeType == 'image/png' ||
              mimeType == 'image/gif') {
            final imageFile = http.MultipartFile.fromBytes(
              'images[]',
              bytes,
              filename: p.basename(photo.src!),
              contentType: MediaType.parse(mimeType!), // use the detected MIME type for the image file
            );
            imageFiles.add(imageFile);
          } else {
              print('Unsupported image format: $mimeType');
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
          category: _selectedCategory?.id.toString(), // use the category ID instead of the name
          subCategory: _selectedSubCategory?.id.toString(), // use the subcategory ID instead of the name
          photos: _pickedImages
      );
      context.read<ServicePostBloc>().add(CreateServicePostEvent(servicePost , imageFiles));
    }
  }

  void _updateCalculatedPoints() {
    final int haveBadge = _selectedHaveBadge == 'ذهبي' ? 2 : _selectedHaveBadge == 'ماسي' ? 10 : 0;
    _calculatedPoints = _selectedBadgeDuration * haveBadge;
  }

  void _onCategorySelected(Category newCategory) {
    setState(() {
      _selectedCategory = newCategory;
    });
  }
  void _onSubCategorySelected(SubCategory newSubCategory) {
    setState(() {
      _selectedSubCategory = newSubCategory;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('اضافة منشور'),
          actions:  [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  PointBalance(userId: widget.userId, showBalance: true,),
                ],
              ),
            ),
          ],
        ),
        body: BlocListener<ServicePostBloc, ServicePostState>(
        listener: (context, state) {
          print(state);
      if (state is ServicePostOperationSuccess) {
        SuccessWidget.show(context, 'Service Post created successfully');
        Navigator.of(context).pop();
      } else if (state is ServicePostOperationFailure) {
        ErrorWidget('Error creating : ${state.errorMessage}');
      }
        },
          child: Form(
            key: _formKey,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildImagePickerButton(),

                  LocationPicker(
                    onLocationPicked: (LatLng location) {
                      setState(() {
                        _locationLatitudes = location.latitude;
                        _locationLongitudes = location.longitude;
                      });
                    },
                  ),
                  TextFormField(
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _title = value;
                      });
                    },
                  ),
                  TextFormField(
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _description = value;
                      });
                    },
                  ),
                  CategoriesDropdown(
                    onCategorySelected: _onCategorySelected,
                  ),
                  const SizedBox(height: 8.0),
                  SubCategoriesDropdown(
                    selectedCategory: _selectedCategory,
                    onSubCategorySelected: _onSubCategorySelected,
                  ),

                  TextFormField(
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'السعر',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _price = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(

                    decoration: const InputDecoration(
                      labelText: 'العملة',
                    ),
                    value: _selectedPriceCurrency,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPriceCurrency = newValue!;
                      });
                    },

                    items: <String>['شيكل', 'دولار امريكي', 'دينار اردني'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<String>(
                    decoration:  const InputDecoration(
                      labelText: 'النوع',
                    ),
                    value: _selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                    items: <String>['عرض', 'طلب'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'تمييز النشر',
                    ),
                    value: _selectedHaveBadge,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedHaveBadge = newValue!;
                        if (_selectedHaveBadge == 'عادي') {
                          _selectedBadgeDuration = 0;
                        } else if (_selectedBadgeDuration == 0) {
                          _selectedBadgeDuration = 1; // Set the default value for ذهبي or ماسي
                        }
                        _updateCalculatedPoints();
                      });
                    },
                    items: <String>['عادي', 'ذهبي', 'ماسي'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Visibility(
                    visible: _selectedHaveBadge != 'عادي',
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'المدة',
                      ),
                      value: _selectedBadgeDuration,
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedBadgeDuration = newValue!;
                          _updateCalculatedPoints();
                        });
                      },
                      items: <int>[0, 1, 2, 3, 4, 5, 6, 7].where((int value) {
                        return _selectedHaveBadge == 'عادي' ? true : value != 0;
                      }).map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('يوم $value'),
                        );
                      }).toList(),

                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Visibility(
                    visible: _selectedHaveBadge != 'عادي',
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ستخصم $_calculatedPoints من رصيد نقاطك عند تمييز النشر بـ $_selectedHaveBadge لمدة $_selectedBadgeDuration يوم',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('اضافة'),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}