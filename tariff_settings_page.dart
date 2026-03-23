import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/seamstress_prices.dart';
import '../../domain/my_prices.dart';
import '../providers/pricing_provider.dart';

class TariffSettingsPage extends ConsumerStatefulWidget {
  const TariffSettingsPage({super.key});

  @override
  ConsumerState<TariffSettingsPage> createState() => _TariffSettingsPageState();
}

class _TariffSettingsPageState extends ConsumerState<TariffSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKeySeamstress = GlobalKey<FormState>();
  final _formKeyMy = GlobalKey<FormState>();

  late Map<String, TextEditingController> _seamstressControllers;
  late Map<String, TextEditingController> _myControllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initControllers();
  }

  void _initControllers() {
    _seamstressControllers = {
      'curtainsBase': TextEditingController(text: SeamstressPrices.curtainsBase.toString()),
      'over3mPercent': TextEditingController(text: SeamstressPrices.over3mPercent.toString()),
      'complexFabricPercent': TextEditingController(text: SeamstressPrices.complexFabricPercent.toString()),
      'handFold': TextEditingController(text: SeamstressPrices.handFold.toString()),
      'lining': TextEditingController(text: SeamstressPrices.lining.toString()),
      'seam': TextEditingController(text: SeamstressPrices.seam.toString()),
      'romanTape': TextEditingController(text: SeamstressPrices.romanTape.toString()),
      'romanLining': TextEditingController(text: SeamstressPrices.romanLining.toString()),
      'romanRing': TextEditingController(text: SeamstressPrices.romanRing.toString()),
      'bedspread': TextEditingController(text: SeamstressPrices.bedspread.toString()),
      'ruffle': TextEditingController(text: SeamstressPrices.ruffle.toString()),
      'pillowcase': TextEditingController(text: SeamstressPrices.pillowcase.toString()),
      'pillowFill': TextEditingController(text: SeamstressPrices.pillowFill.toString()),
      'seatCushion': TextEditingController(text: SeamstressPrices.seatCushion.toString()),
      'simpleCover': TextEditingController(text: SeamstressPrices.simpleCover.toString()),
    };

    _myControllers = {
      'curtainsBase': TextEditingController(text: MyPrices.curtainsBase.toString()),
      'over3mPercent': TextEditingController(text: MyPrices.over3mPercent.toString()),
      'complexFabricPercent': TextEditingController(text: MyPrices.complexFabricPercent.toString()),
      'handFold': TextEditingController(text: MyPrices.handFold.toString()),
      'lining': TextEditingController(text: MyPrices.lining.toString()),
      'seam': TextEditingController(text: MyPrices.seam.toString()),
      'romanTape': TextEditingController(text: MyPrices.romanTape.toString()),
      'romanLining': TextEditingController(text: MyPrices.romanLining.toString()),
      'romanRing': TextEditingController(text: MyPrices.romanRing.toString()),
      'bedspread': TextEditingController(text: MyPrices.bedspread.toString()),
      'ruffle': TextEditingController(text: MyPrices.ruffle.toString()),
      'pillowcase': TextEditingController(text: MyPrices.pillowcase.toString()),
      'pillowFill': TextEditingController(text: MyPrices.pillowFill.toString()),
      'seatCushion': TextEditingController(text: MyPrices.seatCushion.toString()),
      'simpleCover': TextEditingController(text: MyPrices.simpleCover.toString()),
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    _seamstressControllers.values.forEach((c) => c.dispose());
    _myControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _saveSeamstressPrices() {
    if (_formKeySeamstress.currentState!.validate()) {
      final newPrices = <String, double>{};
      _seamstressControllers.forEach((key, controller) {
        newPrices[key] = double.tryParse(controller.text) ?? 0;
      });
      ref.read(pricingNotifierProvider.notifier).updateSeamstressPrices(newPrices);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Цены для швеи обновлены'), backgroundColor: Colors.green),
      );
    }
  }

  void _saveMyPrices() {
    if (_formKeyMy.currentState!.validate()) {
      final newPrices = <String, double>{};
      _myControllers.forEach((key, controller) {
        newPrices[key] = double.tryParse(controller.text) ?? 0;
      });
      ref.read(pricingNotifierProvider.notifier).updateMyPrices(newPrices);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Мои цены обновлены'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ ТАРИФЫ'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '💼 Для швеи'),
            Tab(text: '👤 Мои цены'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSeamstressTab(),
          _buildMyPricesTab(),
        ],
      ),
    );
  }

  Widget _buildSeamstressTab() => Form(
    key: _formKeySeamstress,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCard('🪟 ПОРТЬЕРЫ / ТЮЛЬ', [
            _buildField('Тюль/Портьеры до 3м (₽/м)', 'curtainsBase', _seamstressControllers),
            _buildField('Надбавка >3м (%)', 'over3mPercent', _seamstressControllers),
            _buildField('Сложная ткань (%)', 'complexFabricPercent', _seamstressControllers),
            _buildField('Ручная складка (₽/м)', 'handFold', _seamstressControllers),
            _buildField('Подклад (₽/м)', 'lining', _seamstressControllers),
            _buildField('Стачной шов (₽/м)', 'seam', _seamstressControllers),
          ]),
          _buildCard('🏛️ РИМСКИЕ ШТОРЫ', [
            _buildField('На ленте/кулиске (₽/м²)', 'romanTape', _seamstressControllers),
            _buildField('На подкладе (₽/м²)', 'romanLining', _seamstressControllers),
            _buildField('Кольцо (₽/шт)', 'romanRing', _seamstressControllers),
          ]),
          _buildCard('🛏️ ДОП. ИЗДЕЛИЯ', [
            _buildField('Покрывало (₽/шт)', 'bedspread', _seamstressControllers),
            _buildField('Рюшка (₽/м)', 'ruffle', _seamstressControllers),
            _buildField('Наволочка (₽/шт)', 'pillowcase', _seamstressControllers),
            _buildField('Наперник (₽/шт)', 'pillowFill', _seamstressControllers),
            _buildField('Сидушка (₽/шт)', 'seatCushion', _seamstressControllers),
            _buildField('Чехол (₽/шт)', 'simpleCover', _seamstressControllers),
          ]),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _saveSeamstressPrices,
            icon: const Icon(Icons.check),
            label: const Text('СОХРАНИТЬ'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    ),
  );

  Widget _buildMyPricesTab() => Form(
    key: _formKeyMy,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCard('🪟 ПОРТЬЕРЫ / ТЮЛЬ (НАЦЕНКА)', [
            _buildField('Тюль/Портьеры до 3м (₽/м)', 'curtainsBase', _myControllers),
            _buildField('Надбавка >3м (%)', 'over3mPercent', _myControllers),
            _buildField('Сложная ткань (%)', 'complexFabricPercent', _myControllers),
            _buildField('Ручная складка (₽/м)', 'handFold', _myControllers),
            _buildField('Подклад (₽/м)', 'lining', _myControllers),
            _buildField('Стачной шов (₽/м)', 'seam', _myControllers),
          ]),
          _buildCard('🏛️ РИМСКИЕ ШТОРЫ (НАЦЕНКА)', [
            _buildField('На ленте/кулиске (₽/м²)', 'romanTape', _myControllers),
            _buildField('На подкладе (₽/м²)', 'romanLining', _myControllers),
            _buildField('Кольцо (₽/шт)', 'romanRing', _myControllers),
          ]),
          _buildCard('🛏️ ДОП. ИЗДЕЛИЯ (НАЦЕНКА)', [
            _buildField('Покрывало (₽/шт)', 'bedspread', _myControllers),
            _buildField('Рюшка (₽/м)', 'ruffle', _myControllers),
            _buildField('Наволочка (₽/шт)', 'pillowcase', _myControllers),
            _buildField('Наперник (₽/шт)', 'pillowFill', _myControllers),
            _buildField('Сидушка (₽/шт)', 'seatCushion', _myControllers),
            _buildField('Чехол (₽/шт)', 'simpleCover', _myControllers),
          ]),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _saveMyPrices,
            icon: const Icon(Icons.check),
            label: const Text('СОХРАНИТЬ'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF8B2346),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCard(String title, List<Widget> children) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );

  Widget _buildField(String label, String key, Map<String, TextEditingController> controllers) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controllers[key],
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          isDense: true,
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'Введите значение';
          if (double.tryParse(val) == null) return 'Только числа';
          return null;
        },
      ),
    );
}