import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<String> {
  LanguageCubit() : super('ar'); // Set the default language

  void setLanguage(String lang) {
    emit(lang);
  }
}
