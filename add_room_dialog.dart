import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/room.dart';
import '../providers/client_provider.dart';
import '../../../pricing/domain/seamstress_prices.dart';
import '../../../pricing/domain/my_prices.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_dropdown.dart';

class AddRoomDialog extends ConsumerStatefulWidget {
  final Client client;

  const AddRoomDialog({super.key, required this.client});

  @override
  ConsumerState<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends ConsumerState<AddRoomDialog> {
  late TextEditingController _roomController;
  late TextEditingController _corniceController;
  late TextEditingController _heightController;
  late TextEditingController _coefController;
  late TextEditingController _topHemController;
  late TextEditingController _bottomHemController;
  late TextEditingController _leftHemController;
  late TextEditingController _rightHemController;
  late TextEditingController _fabricPriceController;
  late TextEditingController _linningPriceController;
  late TextEditingController _profilePriceController;
  late TextEditingController _profileMarkupController;

  String _curtainType = 'curtains';
  bool _is3m = false;
  bool _isComplex = false;
  bool _isHandFold = false;
  bool _isLining = false;
  bool _isSeam = false;

  double _fabricMeters = 0;
  double _linningMeters = 0;
  double _fabricCostValue = 0;
  double _linningCostValue = 0;
  double _sewingCostSeamstress = 0;
  double _sewingCostMy = 0;
  double _profileCost = 0;
  double _profileMarkup = 0;
  double _clientPrice = 0;
  double _totalCost = 0;

  final List<Map<String, String>> _curtainTypes = [
    {'id': 'tulle', 'name': 'Тюль'},
    {'id': 'curtains', 'name': 'Портьеры'},
    {'id': 'curtains_lining', 'name': 'Портьеры на подкладе'},
    {'id': 'roman', 'name': 'Римские шторы'},
    {'id': 'roman_lining', 'name': 'Римские на подкладе'},
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _setupListeners();
  }

  void _initControllers() {
    _roomController = TextEditingController();
    _corniceController = TextEditingController();
    _heightController = TextEditingController();
    _coefController = TextEditingController(text: '2');
    _topHemController = TextEditingController(text: '10');
    _bottomHemController = TextEditingController(text: '10');
    _leftHemController = TextEditingController(text: '5');
    _rightHemController = TextEditingController(text: '5');
    _fabricPriceController = TextEditingController();
    _linningPriceController = TextEditingController();
    _profilePriceController = TextEditingController();
    _profileMarkupController = TextEditingController(text: '0');
  }

  void _setupListeners() {
    final controllers = [
      _corniceController,
      _coefController,
      _heightController,
      _leftHemController,
      _rightHemController,
      _fabricPriceController,
      _linningPriceController,
      _profilePriceController,
      _profileMarkupController,
    ];
    for (final c in controllers) {
      c.addListener(_calculate);
    }
  }

  void _calculate() {
    setState(() {
      final cornice = double.tryParse(_corniceController.text) ?? 0;
      final coef = double.tryParse(_coefController.text) ?? 2;
      final height = double.tryParse(_heightController.text) ?? 0;
      final left = double.tryParse(_leftHemController.text) ?? 0;
      final right = double.tryParse(_rightHemController.text) ?? 0;
      final fabricPrice = double.tryParse(_fabricPriceController.text) ?? 0;
      final linningPrice = double.tryParse(_linningPriceController.text) ?? 0;
      final profilePrice = double.tryParse(_profilePriceController.text) ?? 0;
      _profileMarkup = double.tryParse(_profileMarkupController.text) ?? 0;

      if (_curtainType == 'roman' || _curtainType == 'roman_lining') {
        double totalCm = cornice + left + right;
        _fabricMeters = (totalCm / 100 * 2).ceil() / 2;
        _linningMeters = _isLining ? (totalCm / 100 * 2).ceil() / 2 : 0;
      } else {
        double mainWidth = cornice * coef;
        double hemWidth = (left + right) * 1;
        double totalCm = mainWidth + hemWidth;
        _fabricMeters = (totalCm / 100 * 2).ceil() / 2;
        _linningMeters = _isLining ? (totalCm / 100 * 2).ceil() / 2 : 0;
      }

      _fabricCostValue = _fabricMeters * fabricPrice;
      _linningCostValue = _linningMeters * linningPrice;
      _sewingCostSeamstress = _calculateSewingCost(cornice, height, _fabricMeters, true);
      _sewingCostMy = _calculateSewingCost(cornice, height, _fabricMeters, false);
      _profileCost = (cornice / 100) * profilePrice;

      _clientPrice = (_fabricCostValue * 2) + _linningCostValue + _sewingCostMy + ((cornice / 100) * profilePrice * (1 + (_profileMarkup / 100)));
      _totalCost = _fabricCostValue + _linningCostValue + _sewingCostSeamstress + _profileCost;
    });
  }

  double _calculateSewingCost(double cornice, double height, double fabricMeters, bool forSeamstress) {
    double cost = 0;

    final base = forSeamstress ? SeamstressPrices.curtainsBase : MyPrices.curtainsBase;
    final over3m = forSeamstress ? SeamstressPrices.over3mPercent : MyPrices.over3mPercent;
    final complex = forSeamstress ? SeamstressPrices.complexFabricPercent : MyPrices.complexFabricPercent;
    final handFoldPrice = forSeamstress ? SeamstressPrices.handFold : MyPrices.handFold;
    final liningPrice = forSeamstress ? SeamstressPrices.lining : MyPrices.lining;
    final seamPrice = forSeamstress ? SeamstressPrices.seam : MyPrices.seam;
    final romanTapePrice = forSeamstress ? SeamstressPrices.romanTape : MyPrices.romanTape;
    final romanLiningPrice = forSeamstress ? SeamstressPrices.romanLining : MyPrices.romanLining;

    if (_curtainType == 'tulle' || _curtainType == 'curtains' || _curtainType == 'curtains_lining') {
      cost = base * fabricMeters;
      if (height > 300 && _is3m) {
        int extraSteps = ((height - 300) / 30).ceil();
        cost *= (1 + over3m * extraSteps);
      }
      if (_isComplex) cost *= (1 + complex);
      if (_isHandFold) cost += handFoldPrice * fabricMeters;
      if (_isLining || _curtainType == 'curtains_lining') cost += liningPrice * fabricMeters;
      if (_isSeam) cost += seamPrice * fabricMeters;
    } else if (_curtainType == 'roman' || _curtainType == 'roman_lining') {
      double area = (cornice / 100) * (height / 100);
      if (_isLining || _curtainType == 'roman_lining') {
        cost = romanLiningPrice * area;
      } else {
        cost = romanTapePrice * area;
      }
    }
    return cost;
  }

  @override
  void dispose() {
    _roomController.dispose();
    _corniceController.dispose();
    _heightController.dispose();
    _coefController.dispose();
    _topHemController.dispose();
    _bottomHemController.dispose();
    _leftHemController.dispose();
    _rightHemController.dispose();
    _fabricPriceController.dispose();
    _linningPriceController.dispose();
    _profilePriceController.dispose();
    _profileMarkupController.dispose();
    super.dispose();
  }

  void _saveRoom() {
    if (_roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название комнаты'), backgroundColor: Colors.red),
      );
      return;
    }

    final newRoom = Room(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _roomController.text,
      fabricMeters: _fabricMeters,
      clientPrice: _clientPrice,
      fabricCost: _fabricCostValue,
      sewingCostSeamstress: _sewingCostSeamstress,
      sewingCostMy: _sewingCostMy,
      profileCost: _profileCost,
      profileMarkup: _profileMarkup,
      totalCost: _totalCost,
      comment: '',
      contacts: '',
      cuttingInfo: '',
      isCompleted: false,
      technicalSpecs: {},
      createdAt: DateTime.now(),
    );

    final updatedClient = widget.client.copyWith(
      rooms: [...widget.client.rooms, newRoom],
      updatedAt: DateTime.now(),
    );

    ref.read(clientNotifierProvider.notifier).updateClient(updatedClient);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Комната добавлена'), backgroundColor: Colors.green),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('ДОБАВИТЬ КОМНАТУ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CustomInput(
              label: 'Название комнаты',
              controller: _roomController,
              hint: 'Гостиная, спальня',
            ),
            const SizedBox(height: 16),
            const Text('Параметры:', style: TextStyle(fontWeight: FontWeight.w500)),
            CustomDropdown(
              label: 'Тип штор',
              value: _curtainType,
              items: _curtainTypes,
              onChanged: (val) => setState(() {
                _curtainType = val!;
                _calculate();
              }),
            ),
            Row(
              children: [
                Expanded(
                  child: CustomInput(label: 'Карниз см', controller: _corniceController, isNumber: true),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomInput(label: 'Высота см', controller: _heightController, isNumber: true),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CustomInput(label: 'Коэф', controller: _coefController, isNumber: true),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomInput(label: 'Верх см', controller: _topHemController, isNumber: true),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CustomInput(label: 'Низ см', controller: _bottomHemController, isNumber: true),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomInput(label: 'Лево см', controller: _leftHemController, isNumber: true),
                ),
              ],
            ),
            CustomInput(label: 'Право см', controller: _rightHemController, isNumber: true),
            const SizedBox(height: 16),
            const Text('Цены:', style: TextStyle(fontWeight: FontWeight.w500)),
            CustomInput(label: 'Цена основной ткани руб/м', controller: _fabricPriceController, isNumber: true),
            CustomInput(label: 'Цена подкладочной ткани руб/м', controller: _linningPriceController, isNumber: true),
            CustomInput(label: 'Цена профиля руб/м', controller: _profilePriceController, isNumber: true),
            CustomInput(label: 'Наценка профиль %', controller: _profileMarkupController, isNumber: true),
            const SizedBox(height: 16),
            const Text('Опции:', style: TextStyle(fontWeight: FontWeight.w500)),
            CheckboxListTile(
              value: _is3m,
              onChanged: (v) => setState(() {
                _is3m = v!;
                _calculate();
              }),
              title: const Text('Высота над 3м', style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            CheckboxListTile(
              value: _isComplex,
              onChanged: (v) => setState(() {
                _isComplex = v!;
                _calculate();
              }),
              title: const Text('Сложная ткань', style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            CheckboxListTile(
              value: _isHandFold,
              onChanged: (v) => setState(() {
                _isHandFold = v!;
                _calculate();
              }),
              title: const Text('Ручная складка', style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            CheckboxListTile(
              value: _isLining,
              onChanged: (v) => setState(() {
                _isLining = v!;
                _calculate();
              }),
              title: const Text('Подклад', style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            CheckboxListTile(
              value: _isSeam,
              onChanged: (v) => setState(() {
                _isSeam = v!;
                _calculate();
              }),
              title: const Text('Стачной шов', style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF8B2346).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Основная ткань:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('${_fabricCostValue.toStringAsFixed(0)} руб'),
                      ],
                    ),
                    if (_linningCostValue > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Подкладочная ткань:', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('${_linningCostValue.toStringAsFixed(0)} руб'),
                        ],
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Пошив швеи:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('${_sewingCostSeamstress.toStringAsFixed(0)} руб'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Мой пошив:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('${_sewingCostMy.toStringAsFixed(0)} руб'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Клиент:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${_clientPrice.toStringAsFixed(0)} руб',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveRoom,
              icon: const Icon(Icons.check),
              label: const Text('ДОБАВИТЬ'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ОТМЕНА'),
            ),
          ],
        ),
      ),
    );
  }
}