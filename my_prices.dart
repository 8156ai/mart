class MyPrices {
  static double curtainsBase = 1000;
  static double over3mPercent = 0.1;
  static double complexFabricPercent = 0.2;
  static double handFold = 1250;
  static double lining = 1450;
  static double seam = 280;
  static double romanTape = 1320;
  static double romanLining = 1600;
  static double romanRing = 20;
  static double bedspread = 1000;
  static double ruffle = 500;
  static double pillowcase = 500;
  static double pillowFill = 150;
  static double seatCushion = 1000;
  static double simpleCover = 1500;

  static Map<String, double> toMap() => {
    'curtainsBase': curtainsBase,
    'over3mPercent': over3mPercent,
    'complexFabricPercent': complexFabricPercent,
    'handFold': handFold,
    'lining': lining,
    'seam': seam,
    'romanTape': romanTape,
    'romanLining': romanLining,
    'romanRing': romanRing,
    'bedspread': bedspread,
    'ruffle': ruffle,
    'pillowcase': pillowcase,
    'pillowFill': pillowFill,
    'seatCushion': seatCushion,
    'simpleCover': simpleCover,
  };

  static void fromMap(Map<String, dynamic> map) {
    if (map.containsKey('curtainsBase')) curtainsBase = map['curtainsBase'] as double;
    if (map.containsKey('over3mPercent')) over3mPercent = map['over3mPercent'] as double;
    if (map.containsKey('complexFabricPercent')) complexFabricPercent = map['complexFabricPercent'] as double;
    if (map.containsKey('handFold')) handFold = map['handFold'] as double;
    if (map.containsKey('lining')) lining = map['lining'] as double;
    if (map.containsKey('seam')) seam = map['seam'] as double;
    if (map.containsKey('romanTape')) romanTape = map['romanTape'] as double;
    if (map.containsKey('romanLining')) romanLining = map['romanLining'] as double;
    if (map.containsKey('romanRing')) romanRing = map['romanRing'] as double;
    if (map.containsKey('bedspread')) bedspread = map['bedspread'] as double;
    if (map.containsKey('ruffle')) ruffle = map['ruffle'] as double;
    if (map.containsKey('pillowcase')) pillowcase = map['pillowcase'] as double;
    if (map.containsKey('pillowFill')) pillowFill = map['pillowFill'] as double;
    if (map.containsKey('seatCushion')) seatCushion = map['seatCushion'] as double;
    if (map.containsKey('simpleCover')) simpleCover = map['simpleCover'] as double;
  }

  // ✅ ДОБАВИТЬ МЕТОД
  static void loadPrices() {
    // Загрузка происходит через PricingRepository
  }
}