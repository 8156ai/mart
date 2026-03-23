class CalculationResult {
  final double fabricMeters;
  final double linningMeters;
  final double fabricCostValue;
  final double linningCostValue;
  final double sewingCostSeamstress;
  final double sewingCostMy;
  final double profileCostWithMarkup;
  final double clientPrice;
  final double totalCost;
  final double profit;
  final String? error;

  CalculationResult({
    required this.fabricMeters,
    required this.linningMeters,
    required this.fabricCostValue,
    required this.linningCostValue,
    required this.sewingCostSeamstress,
    required this.sewingCostMy,
    required this.profileCostWithMarkup,
    required this.clientPrice,
    required this.totalCost,
    required this.profit,
    this.error,
  });
}

class CalculationService {
  static CalculationResult calculate({
    required String curtainType,
    required double cornice,
    required double height,
    required double coef,
    required double topHem,
    required double bottomHem,
    required double leftHem,
    required double rightHem,
    required double rollWidth,
    required double fabricPrice,
    required double linningPrice,
    required double profilePrice,
    required double profileMarkup,
    required bool isLining,
    required double panels,
    required double sewingCostSeamstress,
    required double sewingCostMy,
    required List<Map<String, dynamic>> additionalItems,
  }) {
    String? error;

    double calculatedFabricMeters = 0;
    double calculatedLinningMeters = 0;

    // ✅ ИСПРАВЛЕННЫЙ РАСЧЕТ МЕТРАЖА
    if (curtainType == 'roman' || curtainType == 'roman_lining') {
      // Римские шторы: просто ширина + подгибы
      double widthCm = cornice + leftHem + rightHem;
      double heightCm = height + topHem + bottomHem;
      
      // Если ширина вмещается в рулон - по ширине, иначе по высоте
      if (widthCm <= rollWidth) {
        calculatedFabricMeters = (heightCm / 100 * 2).ceil() / 2;
      } else {
        calculatedFabricMeters = (widthCm / 100 * 2).ceil() / 2;
      }
      
      // Подклад для римских штор
      calculatedLinningMeters = isLining ? calculatedFabricMeters : 0;
    } else {
      // Портьеры/Тюль: коэффициент сборки
      double mainWidth = cornice * coef;
      double hemWidth = (leftHem + rightHem) * panels;
      double totalWidthCm = mainWidth + hemWidth;
      
      // По ширине рулона раскраивается высота
      double heightWithHemsCm = height + topHem + bottomHem;
      
      // Количество раскроев по высоте
      int cutsPerRoll = (rollWidth / heightWithHemsCm).floor();
      if (cutsPerRoll < 1) {
        error = 'Высота (${heightWithHemsCm.toStringAsFixed(0)} см) > рулона ($rollWidth см)';
        cutsPerRoll = 1;
      }
      
      // Метраж = (всю ширину / 100) * (количество полотен / куты на рулон)
      calculatedFabricMeters = (totalWidthCm / 100) * panels;
      
      // ✅ ПОДКЛАД СЧИТАЕТСЯ ОТДЕЛЬНО
      calculatedLinningMeters = isLining ? (totalWidthCm / 100) * panels : 0;
    }

    // Проверка на превышение размеров
    if ((height + topHem + bottomHem) > rollWidth) {
      error = 'Высота (${(height + topHem + bottomHem).toStringAsFixed(0)} см) > рулона ($rollWidth см)';
    }

    // ✅ ПРАВИЛЬНЫЙ РАСЧЕТ СТОИМОСТИ
    final fabricCostValue = calculatedFabricMeters * fabricPrice;
    final linningCostValue = calculatedLinningMeters * linningPrice;
    
    // Профиль: цена за м * ширина карниза / 100 * наценка %
    final profileCost = (profilePrice * cornice / 100);
    final profileCostWithMarkup = profileCost + profileMarkup;

    // Дополнительные позиции
    double additionalCost = 0;
    for (var item in additionalItems) {
      additionalCost += (item['price'] as double?) ?? 0;
    }

    // ✅ ПРАВИЛЬНАЯ ФОРМУЛА ЦЕНЫ ДЛЯ КЛИЕНТА
    final clientPrice = fabricCostValue + linningCostValue + sewingCostMy + profileCostWithMarkup + additionalCost;
    final totalCost = fabricCostValue + linningCostValue + sewingCostSeamstress + profileCost + additionalCost;
    final profit = clientPrice - totalCost;

    return CalculationResult(
      fabricMeters: calculatedFabricMeters,
      linningMeters: calculatedLinningMeters,
      fabricCostValue: fabricCostValue,
      linningCostValue: linningCostValue,
      sewingCostSeamstress: sewingCostSeamstress,
      sewingCostMy: sewingCostMy,
      profileCostWithMarkup: profileCostWithMarkup,
      clientPrice: clientPrice,
      totalCost: totalCost,
      profit: profit,
      error: error,
    );
  }
}