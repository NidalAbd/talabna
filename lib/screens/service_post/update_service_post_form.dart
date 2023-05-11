import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
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

class UpdatePostScreen extends StatefulWidget {
  final int userId;
  final int servicePostId;
  const UpdatePostScreen(
      {Key? key, required this.userId, required this.servicePostId})
      : super(key: key);
  @override
  _UpdatePostScreenState createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final GlobalKey<ImagePickerButtonState> _imagePickerButtonKey = GlobalKey<ImagePickerButtonState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldTitleController = TextEditingController();
  final TextEditingController _oldDescriptionController =
      TextEditingController();
  final TextEditingController _oldPriceController = TextEditingController();
  final TextEditingController _selectedPriceCurrency = TextEditingController();
  final TextEditingController _oldTypeController = TextEditingController();
  final TextEditingController _oldLocationLatitudesController =
      TextEditingController();
  final TextEditingController _oldLocationLongitudesController =
      TextEditingController();

  final ValueNotifier<List<Photo>?> _initialPhotos = ValueNotifier(null);

  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;
  List<Photo>? _pickedImages = [];
  bool _isLoading = false;

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
  @override
  void initState() {
    super.initState();
    _oldTypeController.text = 'عرض';
    _selectedPriceCurrency.text = 'شيكل';
    // Load the service post data
    BlocProvider.of<ServicePostBloc>(context)
        .add(LoadOldOrNewFormEvent(servicePostId: widget.servicePostId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Post'),
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
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<ServicePostBloc, ServicePostState>(
            listener: (context, state) {
              print(state);

              if (state is ServicePostOperationSuccess) {
                SuccessWidget.show(context, 'Post updated successfully');
                setState(() {
                  _isLoading = false;
                });
                Navigator.of(context).pop();

              }if (state is ServicePostImageDeletingSuccess) {
                SuccessWidget.show(context, 'image removed');
                setState(() {
                });
              } else if (state is ServicePostOperationFailure) {
                ErrorCustomWidget.show(context, state.errorMessage);
                setState(() {
                  _isLoading = false;
                });
              }
            },
            builder: (context, state) {
              if (state is ServicePostFormLoadSuccess) {
                // Update the title and description controllers with the old values
                _oldTitleController.text = state.servicePost!.title!;
                _oldDescriptionController.text = state.servicePost!.description!;
                _oldPriceController.text = state.servicePost!.price.toString();
                _selectedPriceCurrency.text = state.servicePost!.priceCurrency!;
                _oldLocationLatitudesController.text = state.servicePost!.locationLatitudes.toString();
                _oldLocationLongitudesController.text = state.servicePost!.locationLongitudes.toString();
                _selectedCategory?.name = state.servicePost!.category!;
                _selectedSubCategory?.name = state.servicePost!.subCategory!;
                _initialPhotos.value = state.servicePost!.photos;

              }
              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildImagePickerButton(),

                    LocationPicker(
                      onLocationPicked: (LatLng location) {
                        setState(() {
                          _oldLocationLatitudesController.text =
                              location.latitude.toString();
                          _oldLocationLongitudesController.text =
                              location.longitude.toString();
                        });
                      },
                    ),
                    TextFormField(
                      controller: _oldTitleController,
                      textDirection: TextDirection.rtl,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    Wrap(
                      children: [
                        TextFormField(
                          controller: _oldDescriptionController,
                          textDirection: TextDirection.rtl,
                          maxLines: 8, // set maxLines to 10 to allow up to 500 characters
                          decoration: const InputDecoration(
                            labelText: 'الوصف',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ]
                    ),
                    CategoriesDropdown(
                      onCategorySelected: _onCategorySelected,
                      initialCategory: _selectedCategory,
                    ),
                    const SizedBox(height: 8.0),
                    SubCategoriesDropdown(
                      selectedCategory: _selectedCategory,
                      onSubCategorySelected: _onSubCategorySelected,
                      initialSubCategory: _selectedSubCategory,
                    ),
                    TextFormField(
                      controller: _oldPriceController,
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
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'العملة',
                      ),
                      value: _selectedPriceCurrency.text,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPriceCurrency.text = newValue!;
                        });
                      },
                      items: <String>['شيكل', 'دولار امريكي', 'دينار اردني']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                     DropdownButtonFormField<String>(
                       decoration: const InputDecoration(
                         labelText: 'النوع',
                       ),
                       value: _oldTypeController.text,
                       onChanged: (String? newValue) {
                         setState(() {
                           _oldTypeController.text = newValue!;
                         });
                       },
                       items: <String>['عرض', 'طلب']
                           .map<DropdownMenuItem<String>>((String value) {
                         return DropdownMenuItem<String>(
                          value: value,
                           child: Text(value),
                         );
                      }).toList(),
                     ),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final imageFiles = <http.MultipartFile>[];
                        final List<Photo>? localImages = _imagePickerButtonKey.currentState?.getLocalImages();
                        for (final photo in localImages!) {
                                if (photo.src != null) {
                                  final bytes =
                                      await File(photo.src!).readAsBytes();
                                  final mimeType = lookupMimeType(photo.src!);
                                  if (mimeType == 'image/jpeg' ||
                                      mimeType == 'image/jpg' ||
                                      mimeType == 'image/png' ||
                                      mimeType == 'image/gif') {
                                    final imageFile = http.MultipartFile.fromBytes(
                                      'images[]',
                                      bytes,
                                      filename: p.basename(photo.src!),
                                      contentType: MediaType.parse(
                                          mimeType!), // use the detected MIME type for the image file
                                    );
                                    imageFiles.add(imageFile);

                                  } else {
                                    print('Unsupported image format: $mimeType');
                                  }
                                }
                              }
                        context.read<ServicePostBloc>().add(UpdatePhotoServicePostEvent(widget.servicePostId, imageFiles));

                        final servicePost = ServicePost(
                                  id: widget.servicePostId,
                                  title: _oldTitleController.text,
                                  description: _oldDescriptionController.text,
                                  price:
                                      double.tryParse(_oldPriceController.text) ??
                                          0,
                                  priceCurrency: _selectedPriceCurrency.text,
                                  locationLatitudes: double.tryParse(
                                          _oldLocationLatitudesController.text) ??
                                      0,
                                  locationLongitudes: double.tryParse(
                                          _oldLocationLongitudesController.text) ??
                                      0,
                                  userId: widget.userId,
                                  type: _oldTypeController.text,
                                  category: _selectedCategory!.id
                                      .toString(), // use the category ID instead of the name
                                  subCategory: _selectedSubCategory!.id
                                      .toString(), // use the subcategory ID instead of the name
                                  photos: _pickedImages);
                        context.read<ServicePostBloc>().add(UpdateServicePostEvent(servicePost, imageFiles));
                            },
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Update Post'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
