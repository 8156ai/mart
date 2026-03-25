import 'dart:math';

class CalculationResult {
  final double fabricMeters;
  final double linningMeters;
  final double fabricCostValue;
  final double linningCostValue;
  final double sewingCostSeamstress;
  final double sewingCostMy;
  final double profileCost;
  final double profileCostWithMarkup;
  final double ringsCost;
  final double additionalItemsCost;
  final double clientPrice;
  final double totalCost;
  final double profit;
  final String? error;
  final double totalWidthCm;
  final double rawMeters;
  final double pricePerMeterSeamstress;
  final List<PanelDetail> panelDetails;

  CalculationResult({
    required this.fabricMeters,
    required this.linningMeters,
    required this.fabricCostValue,
    required this.linningCostValue,
    required this.sewingCostSeamstress,
    required this.sewingCostMy,
    required this.profileCost,
    required this.profileCostWithMarkup,
    required this.ringsCost,
    required this.additionalItemsCost,
    required this.clientPrice,
    required this.totalCost,
    required this.profit,
    this.error,
    this.totalWidthCm = 0,
    this.rawMeters = 0,
    this.pricePerMeterSeamstress = 0,
    this.panelDetails = const [],
  });
}

class PanelDetail {
  final int panelNumber;
  final double widthCm;
  final double rawMeters;
  final double roundedMeters;

  PanelDetail({
    required this.panelNumber,
    required this.widthCm,
    required this.rawMeters,
    required this.roundedMeters,
  });
}

class CalculationService {
  /// Округление вверх до 0.5 м
  static double roundUpToHalf(double meters) {
    return (meters * 2).ceilToDouble() / 2;
  }

  /// Расчет количества колец для римских штор
  static int calculateRingsCount(double heightCm) {
    int ringsCount = (heightCm / 25).ceil();
    return ringsCount < 2 ? 2 : ringsCount;
  }

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
    required double sewingPricePerMeter,
    required double sewingMarkupPercent,
    required double ringPrice,
    required bool useRings,
    required List<Map<String, dynamic>> additionalItems,
  }) {
    String? error;
    double calculatedFabricMeters = 0;
    double calculatedLinningMeters = 0;
    double totalWidthCm = 0;
    double rawMeters = 0;
    List<PanelDetail> panelDetails = [];
    double ringsCost = 0;

    // ✅ РАСЧЕТ МЕТРАЖА ТКАНИ
    if (curtainType == 'roman' || curtainType == 'roman_lining') {
      // 📐 РИМСКИЕ ШТОРЫ - считаем как единое полотно
      double widthCm = cornice + leftHem + rightHem;
      double heightCm = height + topHem + bottomHem;

      if (widthCm <= rollWidth) {
        rawMeters = heightCm / 100;
        calculatedFabricMeters = roundUpToHalf(rawMeters);
        totalWidthCm = widthCm;
      } else {
        rawMeters = widthCm / 100;
        calculatedFabricMeters = roundUpToHalf(rawMeters);
        totalWidthCm = widthCm;
      }

      // Подклад для римских штор
      if (isLining) {
        calculatedLinningMeters = calculatedFabricMeters;
      }

      // Кольца для римских штор
      if (useRings) {
        int ringsCount = calculateRingsCount(height);
        ringsCost = ringsCount * ringPrice;
      }
    } else {
      // 📐 ПОРТЬЕРЫ/ТЮЛЬ
      // Формула: Общая ширина = (Карниз × Коэффициент) + (Левый + Правый) × Количество полотен
      double hemWidth = (leftHem + rightHem) * panels;
      double mainWidth = cornice * coef;
      totalWidthCm = mainWidth + hemWidth;
      rawMeters = totalWidthCm / 100;
      calculatedFabricMeters = roundUpToHalf(rawMeters);

      // ✅ ПОДКЛАД ДЛЯ ПОРТЬЕР - считается так же, как основная ткань
      // (если выбран чекбокс "Подклад" ИЛИ тип "Портьеры на подкладе")
      bool shouldUseLining = isLining || curtainType == 'curtains_lining';
      
      if (shouldUseLining) {
        calculatedLinningMeters = calculatedFabricMeters;
      }

      // Детальный расчет по каждому полотну
      double hemPerPanel = leftHem + rightHem;
      double widthPerPanelCm = (cornice * coef) + hemPerPanel;
      double rawMetersPerPanel = widthPerPanelCm / 100;
      double roundedMetersPerPanel = roundUpToHalf(rawMetersPerPanel);

      for (int i = 0; i < panels.toInt(); i++) {
        panelDetails.add(PanelDetail(
          panelNumber: i + 1,
          widthCm: widthPerPanelCm,
          rawMeters: rawMetersPerPanel,
          roundedMeters: roundedMetersPerPanel,
        ));
      }

      // Проверка высоты
      double heightWithHemsCm = height + topHem + bottomHem;
      if (heightWithHemsCm > rollWidth) {
        error = '⚠️ Высота с подгибами (${heightWithHemsCm.toStringAsFixed(0)} см) превышает ширину рулона ($rollWidth см)';
      }
    }

    // ✅ РАСЧЕТ СТОИМОСТИ ПОШИВА
    final sewingCostSeamstress = sewingPricePerMeter * calculatedFabricMeters;
    final sewingCostMy = sewingCostSeamstress * (1 + sewingMarkupPercent / 100);

    // ✅ РАСЧЕТ СТОИМОСТИ ТКАНИ (СЕБЕСТОИМОСТЬ)
    final fabricCostRaw = calculatedFabricMeters * fabricPrice;
    final linningCostRaw = calculatedLinningMeters * linningPrice;

    // ✅ НАЦЕНКА НА ТКАНЬ (100% - можно настроить)
    const fabricMarkupPercent = 100.0;
    
    // Цена для клиента (с наценкой)
    final fabricCostValue = fabricCostRaw * (1 + fabricMarkupPercent / 100);
    final linningCostValue = linningCostRaw * (1 + fabricMarkupPercent / 100);

    // ✅ РАСЧЕТ СТОИМОСТИ ПРОФИЛЯ
    final profileCost = (profilePrice * cornice / 100);
    final profileCostWithMarkup = profileCost + profileMarkup;

    // ✅ ДОПОЛНИТЕЛЬНЫЕ ПОЗИЦИИ
    double additionalCost = 0;
    for (var item in additionalItems) {
      additionalCost += (item['price'] as double?) ?? 0;
    }

    // ✅ ИТОГОВЫЕ СУММЫ
    final clientPrice = fabricCostValue +
        linningCostValue +
        sewingCostMy +
        profileCostWithMarkup +
        ringsCost +
        additionalCost;

    final totalCost = fabricCostRaw +
        linningCostRaw +
        sewingCostSeamstress +
        profileCost +
        ringsCost +
        additionalCost;

    final profit = clientPrice - totalCost;

    return CalculationResult(
      fabricMeters: calculatedFabricMeters,
      linningMeters: calculatedLinningMeters,
      fabricCostValue: fabricCostValue,
      linningCostValue: linningCostValue,
      sewingCostSeamstress: sewingCostSeamstress,
      sewingCostMy: sewingCostMy,
      profileCost: profileCost,
      profileCostWithMarkup: profileCostWithMarkup,
      ringsCost: ringsCost,
      additionalItemsCost: additionalCost,
      clientPrice: clientPrice,
      totalCost: totalCost,
      profit: profit,
      error: error,
      totalWidthCm: totalWidthCm,
      rawMeters: rawMeters,
      pricePerMeterSeamstress: sewingPricePerMeter,
      panelDetails: panelDetails,
    );
  }
}