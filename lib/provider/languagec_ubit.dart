import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<String> {
  LanguageCubit() : super('العربية'); // Set the default language

  void setLanguage(String lang) {
    emit(lang);
  }
}
