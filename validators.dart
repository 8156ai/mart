class Validators {
  // ✅ Валидация имени клиента
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠️ Введите имя';
    }
    if (value.length < 2) {
      return '⚠️ Минимум 2 символа';
    }
    if (value.length > 50) {
      return '⚠️ Максимум 50 символов';
    }
    return null;
  }

  // ✅ Валидация телефона
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠️ Введите телефон';
    }
    final phoneRegex = RegExp(r'^(\+7|8|7)?[0-9]{10}$');
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (!phoneRegex.hasMatch(cleaned)) {
      return '⚠️ Некорректный номер (10-11 цифр)';
    }
    return null;
  }

  // ✅ Валидация положительного числа
  static String? validatePositiveNumber(String? value, {String fieldName = 'Поле'}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final num = double.tryParse(value);
    if (num == null) {
      return '⚠️ Введите число';
    }
    if (num <= 0) {
      return '⚠️ Введите положительное число';
    }
    if (num > 10000) {
      return '⚠️ Слишком большое значение';
    }
    return null;
  }

  // ✅ Валидация размеров
  static String? validateDimension(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final num = double.tryParse(value);
    if (num == null) {
      return '⚠️ Введите число';
    }
    if (num < 0 || num > 5000) {
      return '⚠️ Некорректный размер (0-5000)';
    }
    return null;
  }

  // ✅ Валидация цены
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final num = double.tryParse(value);
    if (num == null) {
      return '⚠️ Введите число';
    }
    if (num < 0 || num > 1000000) {
      return '⚠️ Некорректная цена';
    }
    return null;
  }

  // ✅ Проверка валидности формы
  static bool isFormValid(String name, String phone) {
    return validateName(name) == null && validatePhone(phone) == null;
  }
}