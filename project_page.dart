import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/room.dart';
import '../providers/client_provider.dart';
import '../../../pricing/domain/seamstress_prices.dart';
import '../../../pricing/domain/my_prices.dart';
import '../../../pricing/presentation/providers/pricing_provider.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../../../shared/widgets/custom_checkbox.dart';
import '../widgets/cutting_preview.dart';
import '../widgets/sewing_cost_summary.dart';
import './technical_task_viewer.dart';
import '../../../../shared/services/technical_task_generator.dart';
import '../../../../shared/services/invoice_generator.dart';
import '../../../../shared/services/validators.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../../shared/services/calculation_service.dart';
import '../../../../shared/services/periodic_notification_service.dart';
import './archive_page.dart';
import './calendar_page.dart';
import '../../../pricing/presentation/screens/tariff_settings_page.dart';

class ProjectPage extends ConsumerStatefulWidget {
  const ProjectPage({super.key});

  @override
  ConsumerState<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends ConsumerState<ProjectPage> {
  late final TextEditingController _clientController;
  late final TextEditingController _phoneController;
  late final TextEditingController _roomController;
  late final TextEditingController _commentController;
  late final TextEditingController _corniceController;
  late final TextEditingController _heightController;
  late final TextEditingController _coefController;
  late final TextEditingController _topHemController;
  late final TextEditingController _bottomHemController;
  late final TextEditingController _leftHemController;
  late final TextEditingController _rightHemController;
  late final TextEditingController _rollWidthController;
  late final TextEditingController _fabricPriceController;
  late final TextEditingController _linningPriceController;
  late final TextEditingController _profilePriceController;
  late final TextEditingController _profileMarkupController;
  late final TextEditingController _panelsController;
  late final TextEditingController _ringsController;
  late final TextEditingController _techCommentController;
  late final TextEditingController _deadlineController;

  String _curtainType = 'curtains';
  String _corniceType = 'profile';
  String _status = 'work';
  bool _is3m = false;
  bool _isComplex = false;
  bool _isHandFold = false;
  bool _isLining = false;
  bool _isSeam = false;
  bool _isRings = false;
  bool _hideSewingCosts = false;

  double _panels = 2;
  double _fabricMeters = 0;
  double _linningMeters = 0;
  double _fabricCostValue = 0;
  double _linningCostValue = 0;
  double _sewingCostSeamstress = 0;
  double _sewingCostMy = 0;
  double _profileCost = 0;
  double _profileMarkup = 0;
  double _profileCostWithMarkup = 0;
  double _clientPrice = 0;
  double _totalCost = 0;
  double _profit = 0;
  String? _error;

  String _searchQuery = '';

  Client? _currentClient;
  Room? _editingRoom;

  List<Map<String, dynamic>> _additionalItems = [];
  Map<String, Room> _selectedRooms = {};

  final List<Map<String, String>> _curtainTypes = [
    {'id': 'tulle', 'name': 'Тюль'},
    {'id': 'curtains', 'name': 'Портьеры'},
    {'id': 'curtains_lining', 'name': 'Портьеры на подкладе'},
    {'id': 'roman', 'name': 'Римские шторы'},
    {'id': 'roman_lining', 'name': 'Римские на подкладе'},
  ];

  final List<Map<String, String>> _corniceTypes = [
    {'id': 'profile', 'name': 'Профиль'},
    {'id': 'roman', 'name': 'Римский карниз'},
  ];

  final List<Map<String, String>> _statuses = [
    {'id': 'work', 'name': 'В работе'},
    {'id': 'done', 'name': 'Закрыт'},
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _setupListeners();
    _initPeriodicNotifications();
  }

  void _initControllers() {
    _clientController = TextEditingController();
    _phoneController = TextEditingController();
    _roomController = TextEditingController();
    _commentController = TextEditingController();
    _corniceController = TextEditingController();
    _heightController = TextEditingController();
    _coefController = TextEditingController(text: '2');
    _topHemController = TextEditingController(text: '10');
    _bottomHemController = TextEditingController(text: '10');
    _leftHemController = TextEditingController(text: '5');
    _rightHemController = TextEditingController(text: '5');
    _rollWidthController = TextEditingController(text: '280');
    _fabricPriceController = TextEditingController();
    _linningPriceController = TextEditingController();
    _profilePriceController = TextEditingController();
    _profileMarkupController = TextEditingController(text: '');
    _panelsController = TextEditingController(text: '2');
    _ringsController = TextEditingController(text: '0');
    _techCommentController = TextEditingController();
    _deadlineController = TextEditingController(
      text: DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0],
    );
  }

  void _setupListeners() {
    final controllers = [
      _corniceController,
      _coefController,
      _leftHemController,
      _rightHemController,
      _fabricPriceController,
      _linningPriceController,
      _profilePriceController,
      _profileMarkupController,
      _panelsController,
      _heightController,
      _topHemController,
      _bottomHemController,
      _ringsController,
    ];
    for (final c in controllers) {
      c.addListener(() => setState(_calculate));
    }
  }

  void _initPeriodicNotifications() {
    PeriodicNotificationService.init();
  }

  @override
  void dispose() {
    final controllers = [
      _clientController,
      _phoneController,
      _roomController,
      _commentController,
      _corniceController,
      _heightController,
      _coefController,
      _topHemController,
      _bottomHemController,
      _leftHemController,
      _rightHemController,
      _rollWidthController,
      _fabricPriceController,
      _linningPriceController,
      _profilePriceController,
      _profileMarkupController,
      _panelsController,
      _ringsController,
      _techCommentController,
      _deadlineController,
    ];
    for (final c in controllers) c.dispose();
    super.dispose();
  }

  void _calculate() {
  _error = null;

  final cornice = double.tryParse(_corniceController.text) ?? 0;
  final coef = double.tryParse(_coefController.text) ?? 2;
  final height = double.tryParse(_heightController.text) ?? 0;
  final left = double.tryParse(_leftHemController.text) ?? 0;
  final right = double.tryParse(_rightHemController.text) ?? 0;
  final top = double.tryParse(_topHemController.text) ?? 0;
  final bottom = double.tryParse(_bottomHemController.text) ?? 0;
  final rollWidth = double.tryParse(_rollWidthController.text) ?? 280;
  final fabricPrice = double.tryParse(_fabricPriceController.text) ?? 0;
  final linningPrice = double.tryParse(_linningPriceController.text) ?? 0;
  final profilePrice = double.tryParse(_profilePriceController.text) ?? 0;

  _panels = double.tryParse(_panelsController.text) ?? 2;

  if (_profileMarkupController.text.isEmpty) {
    _profileMarkup = 0;
  } else {
    _profileMarkup = double.tryParse(_profileMarkupController.text) ?? 0;
  }

  final seamstressPrices = ref.read(seamstressPricesProvider);
  final myPrices = ref.read(myPricesProvider);

  // ============= ПРАВИЛЬНЫЙ РАСЧЕТ ЦЕН ПОШИВА =============
  double sewingPricePerMeter = 0;
  double sewingMarkupPercent = 0;
  double ringPrice = seamstressPrices['romanRing'] ?? 20;
  bool useRings = _isRings;
  
  // ✅ ВЫБОР ЦЕНЫ ПОШИВА В ЗАВИСИМОСТИ ОТ ТИПА ШТОР
  switch (_curtainType) {
    case 'tulle':
      sewingPricePerMeter = seamstressPrices['curtainsBase'] ?? 350;
      sewingMarkupPercent = ((myPrices['curtainsBase'] ?? 1000) / sewingPricePerMeter - 1) * 100;
      break;
      
    case 'curtains':
      sewingPricePerMeter = seamstressPrices['curtainsBase'] ?? 350;
      sewingMarkupPercent = ((myPrices['curtainsBase'] ?? 1000) / sewingPricePerMeter - 1) * 100;
      break;
      
    case 'curtains_lining':
      sewingPricePerMeter = seamstressPrices['curtainsLining'] ?? 520;
      sewingMarkupPercent = ((myPrices['curtainsLining'] ?? 1450) / sewingPricePerMeter - 1) * 100;
      break;
      
    case 'roman':
      sewingPricePerMeter = seamstressPrices['romanTape'] ?? 680;
      sewingMarkupPercent = ((myPrices['romanTape'] ?? 1320) / sewingPricePerMeter - 1) * 100;
      break;
      
    case 'roman_lining':
      sewingPricePerMeter = seamstressPrices['romanLining'] ?? 900;
      sewingMarkupPercent = ((myPrices['romanLining'] ?? 1600) / sewingPricePerMeter - 1) * 100;
      break;
  }
  
  // ✅ ДОБАВЛЯЕМ НАДБАВКИ (только для портьер и тюля)
  if (_curtainType == 'tulle' || _curtainType == 'curtains' || _curtainType == 'curtains_lining') {
    // Высота более 3м
    if (_is3m && height > 300) {
      double extraPercent = seamstressPrices['over3mPercent'] ?? 0.1;
      sewingPricePerMeter *= (1 + extraPercent);
      sewingMarkupPercent += (myPrices['over3mPercent'] ?? 0.1) * 100;
    }
    
    // Сложная ткань
    if (_isComplex) {
      double extraPercent = seamstressPrices['complexFabricPercent'] ?? 0.2;
      sewingPricePerMeter *= (1 + extraPercent);
      sewingMarkupPercent += (myPrices['complexFabricPercent'] ?? 0.2) * 100;
    }
    
    // Ручная складка
    if (_isHandFold) {
      double handFoldSeamstress = seamstressPrices['handFold'] ?? 130;
      double handFoldMy = myPrices['handFold'] ?? 1250;
      sewingPricePerMeter += handFoldSeamstress;
      sewingMarkupPercent = ((handFoldMy / handFoldSeamstress) - 1) * 100;
    }
  }
  
  // ✅ ВЫЗОВ СЕРВИСА РАСЧЕТА
  final result = CalculationService.calculate(
    curtainType: _curtainType,
    cornice: cornice,
    height: height,
    coef: coef,
    topHem: top,
    bottomHem: bottom,
    leftHem: left,
    rightHem: right,
    rollWidth: rollWidth,
    fabricPrice: fabricPrice,
    linningPrice: linningPrice,
    profilePrice: profilePrice,
    profileMarkup: _profileMarkup,
    isLining: _isLining,
    panels: _panels,
    sewingPricePerMeter: sewingPricePerMeter,
    sewingMarkupPercent: sewingMarkupPercent,
    ringPrice: ringPrice,
    useRings: useRings,
    additionalItems: _additionalItems,
  );

  setState(() {
    _error = result.error;
    _fabricMeters = result.fabricMeters;
    _linningMeters = result.linningMeters;
    _fabricCostValue = result.fabricCostValue;
    _linningCostValue = result.linningCostValue;
    _sewingCostSeamstress = result.sewingCostSeamstress;
    _sewingCostMy = result.sewingCostMy;
    _profileCost = result.profileCost;
    _profileCostWithMarkup = result.profileCostWithMarkup;
    _clientPrice = result.clientPrice;
    _totalCost = result.totalCost;
    _profit = result.profit;
    _additionalItems = [..._additionalItems];
  });
}

  void _loadRoom(Room room) {
    setState(() {
      _editingRoom = room;
      _roomController.text = room.name;
      _commentController.text = room.comment;
      _techCommentController.text = room.cuttingInfo;
      _deadlineController.text = (room.clientDeadline?.toString().split(' ')[0] ?? 
        DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0]);

      final specs = room.technicalSpecs;
      _corniceController.text = specs['cornice'].toStringAsFixed(0);
      _heightController.text = specs['height'].toStringAsFixed(0);
      _coefController.text = specs['coef'].toStringAsFixed(1);
      _topHemController.text = specs['topHem'].toStringAsFixed(0);
      _bottomHemController.text = specs['bottomHem'].toStringAsFixed(0);
      _leftHemController.text = specs['leftHem'].toStringAsFixed(0);
      _rightHemController.text = specs['rightHem'].toStringAsFixed(0);
      _fabricPriceController.text = specs['fabricPrice'].toStringAsFixed(0);
      _linningPriceController.text = specs['linningPrice'].toStringAsFixed(0);
      _profilePriceController.text = specs['profilePrice'].toStringAsFixed(0);
      _profileMarkupController.text = specs['profileMarkup'].toStringAsFixed(0);
      _panelsController.text = specs['panels'].toStringAsFixed(0);
      _ringsController.text = (specs['ringsQty'] ?? 0).toStringAsFixed(0);
      _curtainType = specs['curtainType'] ?? 'curtains';
      _status = room.isCompleted ? 'done' : 'work';
      _isHandFold = specs['isHandFold'] ?? false;
      _isLining = specs['isLining'] ?? false;
      _isSeam = specs['isSeam'] ?? false;
      _is3m = specs['is3m'] ?? false;
      _isComplex = specs['isComplex'] ?? false;
      _isRings = specs['isRings'] ?? false;

      _additionalItems = List<Map<String, dynamic>>.from(specs['additionalItems'] ?? []);

      _calculate();
    });

    NotificationService.info(context, '🏠 ${room.name} загружена');
  }

  void _loadClientData(Client client) {
    setState(() {
      _currentClient = client;
      _clientController.text = client.name;
      _phoneController.text = client.phone;
      _editingRoom = null;
      _roomController.clear();
      _commentController.clear();
      _techCommentController.clear();
      _deadlineController.text = DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0];
    });

    NotificationService.info(context, '👤 ${client.name} выбран');
  }

  Future<void> _generateTechTask() async {
    if (_corniceController.text.isEmpty || _heightController.text.isEmpty) {
      NotificationService.error(context, '⚠️ Заполните размеры');
      return;
    }

    await TechnicalTaskGenerator.generate(
      context: context,
      roomName: _roomController.text.isEmpty ? 'Комната' : _roomController.text,
      cornice: double.tryParse(_corniceController.text) ?? 0,
      height: double.tryParse(_heightController.text) ?? 0,
      coef: double.tryParse(_coefController.text) ?? 2,
      topHem: double.tryParse(_topHemController.text) ?? 0,
      bottomHem: double.tryParse(_bottomHemController.text) ?? 0,
      leftHem: double.tryParse(_leftHemController.text) ?? 0,
      rightHem: double.tryParse(_rightHemController.text) ?? 0,
      panels: _panels.toInt(),
      fabricMeters: _fabricMeters,
      sewingCostSeamstress: _sewingCostSeamstress,
      options: _getTechnicalSpecs(),
      techComment: _techCommentController.text,
      isHandFold: _isHandFold,
      isTape: _isSeam,
    );
  }

  void _saveClient() async {
    final nameError = Validators.validateName(_clientController.text);
    final phoneError = Validators.validatePhone(_phoneController.text);

    if (nameError != null) {
      NotificationService.error(context, nameError);
      return;
    }

    if (phoneError != null) {
      NotificationService.error(context, phoneError);
      return;
    }

    DateTime deadline = DateTime.parse(_deadlineController.text);

    final newRoom = Room(
      id: _editingRoom?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _roomController.text.isEmpty ? 'Комната' : _roomController.text,
      fabricMeters: _fabricMeters,
      clientPrice: _clientPrice,
      fabricCost: _fabricCostValue,
      sewingCostSeamstress: _sewingCostSeamstress,
      sewingCostMy: _sewingCostMy,
      profileCost: _profileCost,
      profileMarkup: _profileMarkup,
      totalCost: _totalCost,
      comment: _commentController.text,
      cuttingInfo: _techCommentController.text,
      isCompleted: _status == 'done',
      technicalSpecs: _getTechnicalSpecs(),
      createdAt: _editingRoom?.createdAt ?? DateTime.now(),
      clientDeadline: deadline,
      seamstressDeadline: deadline,
    );

    final clients = ref.read(clientNotifierProvider);
    final existingIndex = clients.indexWhere((c) => c.phone == _phoneController.text);

    if (existingIndex >= 0) {
      var rooms = [...clients[existingIndex].rooms];

      if (_editingRoom != null) {
        final roomIndex = rooms.indexWhere((r) => r.id == _editingRoom!.id);
        if (roomIndex >= 0) {
          rooms[roomIndex] = newRoom;
        }
      } else {
        rooms.add(newRoom);
      }

      final updatedClient = clients[existingIndex].copyWith(
        rooms: rooms,
        updatedAt: DateTime.now(),
        status: _status,
      );
      ref.read(clientNotifierProvider.notifier).updateClient(updatedClient);

      NotificationService.success(
        context,
        _editingRoom != null ? '✅ Комната обновлена' : '✅ Комната добавлена',
      );

      await PeriodicNotificationService.scheduleDeadlineNotifications(
        clientName: _clientController.text,
        roomName: _roomController.text,
        clientDeadline: deadline,
        seamstressDeadline: deadline,
      );
    } else {
      final newClient = Client(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _clientController.text,
        phone: _phoneController.text,
        status: _status,
        rooms: [newRoom],
        createdAt: DateTime.now(),
      );
      ref.read(clientNotifierProvider.notifier).addClient(newClient);
      NotificationService.success(context, '✅ Клиент создан');

      await PeriodicNotificationService.scheduleDeadlineNotifications(
        clientName: _clientController.text,
        roomName: _roomController.text,
        clientDeadline: deadline,
        seamstressDeadline: deadline,
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));
    await _generateTechTask();

    _clearForm();
  }

  Map<String, dynamic> _getTechnicalSpecs() => {
    'curtainType': _curtainType,
    'corniceType': _corniceType,
    'cornice': double.tryParse(_corniceController.text) ?? 0,
    'height': double.tryParse(_heightController.text) ?? 0,
    'coef': double.tryParse(_coefController.text) ?? 2,
    'panels': _panels,
    'topHem': double.tryParse(_topHemController.text) ?? 0,
    'bottomHem': double.tryParse(_bottomHemController.text) ?? 0,
    'leftHem': double.tryParse(_leftHemController.text) ?? 0,
    'rightHem': double.tryParse(_rightHemController.text) ?? 0,
    'fabricPrice': double.tryParse(_fabricPriceController.text) ?? 0,
    'linningPrice': double.tryParse(_linningPriceController.text) ?? 0,
    'profilePrice': double.tryParse(_profilePriceController.text) ?? 0,
    'profileMarkup': _profileMarkup,
    'is3m': _is3m,
    'isComplex': _isComplex,
    'isHandFold': _isHandFold,
    'isLining': _isLining,
    'isSeam': _isSeam,
    'isRings': _isRings,
    'ringsQty': int.tryParse(_ringsController.text) ?? 0,
    'additionalItems': _additionalItems,
  };

  void _clearForm() {
    setState(() {
      _editingRoom = null;
      _currentClient = null;
      _clientController.clear();
      _phoneController.clear();
      _roomController.clear();
      _commentController.clear();
      _corniceController.clear();
      _heightController.clear();
      _fabricPriceController.clear();
      _linningPriceController.clear();
      _profilePriceController.clear();
      _profileMarkupController.text = '';
      _panelsController.text = '2';
      _ringsController.text = '0';
      _techCommentController.clear();
      _deadlineController.text = DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0];
      _additionalItems.clear();

      _is3m = _isComplex = _isHandFold = _isLining = _isSeam = _isRings = false;
      _error = null;
      _calculate();
    });
  }

  Widget _buildIncomeRow(String label, double value, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500, fontSize: bold ? 16 : 14)),
          Text('${value.toStringAsFixed(0)} руб', style: TextStyle(fontWeight: FontWeight.bold, fontSize: bold ? 18 : 14, color: color)),
        ],
      ),
    );
  }

  void _showAdditionalItemsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('📦 ДОПОЛНИТЕЛЬНЫЕ ИЗДЕЛИЯ', 
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B2346))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._additionalItems.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: item['name'] ?? ''),
                            decoration: const InputDecoration(
                              labelText: 'Название', 
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            onChanged: (val) {
                              _additionalItems[idx]['name'] = val;
                              setState(() {});
                              this.setState(_calculate);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: TextEditingController(text: (item['price'] ?? 0).toStringAsFixed(0)),
                            decoration: const InputDecoration(
                              labelText: 'Цена', 
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              _additionalItems[idx]['price'] = double.tryParse(val) ?? 0;
                              setState(() {});
                              this.setState(_calculate);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            this.setState(() {
                              _additionalItems.removeAt(idx);
                              _calculate();
                            });
                            NotificationService.success(context, '🗑️ Позиция удалена');
                            Navigator.pop(ctx);
                            _showAdditionalItemsDialog();
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                this.setState(() {
                  _additionalItems.add({'name': '', 'price': 0});
                  _calculate();
                });
                setState(() {});
                NotificationService.success(context, '✅ Новая позиция добавлена');
              },
              child: const Text('➕ Добавить позицию', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('✅ Готово'),
            ),
          ],
        ),
      ),
    );
  }

  void _showIncomeDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final clients = ref.read(clientNotifierProvider);
          List<MapEntry<String, Room>> allRooms = [];
          
          for (var client in clients) {
            for (var room in client.rooms) {
              allRooms.add(MapEntry('${client.name} - ${room.name}', room));
            }
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            builder: (context, scrollController) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('💵 МОИ ДОХОДЫ ПО СДЕЛКАМ', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8B2346))),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    children: allRooms.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String label = entry.value.key;
                      
                      bool isSelected = _selectedRooms.containsKey(label);
                      
                      return FilterChip(
                        label: Text(label, style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        )),
                        selected: isSelected,
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: const Color(0xFF8B2346),
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
                              _selectedRooms[label] = allRooms[idx].value;
                            } else {
                              _selectedRooms.remove(label);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        if (_selectedRooms.isNotEmpty) ...[
                          ..._selectedRooms.entries.map((entry) {
                            String label = entry.key;
                            Room room = entry.value;
                            double profit = room.clientPrice - room.totalCost;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Клиент платит:', style: TextStyle(fontSize: 12)),
                                        Text('${room.clientPrice.toStringAsFixed(0)} руб', 
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Себестоимость:', style: TextStyle(fontSize: 12)),
                                        Text('${room.totalCost.toStringAsFixed(0)} руб', 
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Прибыль:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text('${profit.toStringAsFixed(0)} руб', 
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: profit >= 0 ? Colors.green : Colors.red,
                                          )),
                                      ],
                                    ),
                                    if (room.clientPrice > 0) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Маржа: ${((profit / room.clientPrice) * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                          const Divider(thickness: 2),
                          Card(
                            color: Colors.green.shade100,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('ИТОГО ПО ВЫБРАННЫМ СДЕЛКАМ', 
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8B2346))),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Клиент платит:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text('${_selectedRooms.values.fold<double>(0, (sum, r) => sum + r.clientPrice).toStringAsFixed(0)} руб', 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Себестоимость:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text('${_selectedRooms.values.fold<double>(0, (sum, r) => sum + r.totalCost).toStringAsFixed(0)} руб', 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange)),
                                    ],
                                  ),
                                  const Divider(thickness: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('ПРИБЫЛЬ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(
                                        '${(_selectedRooms.values.fold<double>(0, (sum, r) => sum + (r.clientPrice - r.totalCost))).toStringAsFixed(0)} руб',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('Выберите сделки выше', 
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTechnicalTasksList() {
    final clients = ref.read(clientNotifierProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('📋 ТЕХНИЧЕСКИЕ ЗАДАНИЯ', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B2346))),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: clients.fold<int>(0, (sum, c) => sum + c.rooms.length),
                  itemBuilder: (context, index) {
                    int roomIndex = 0;
                    late String clientName;
                    late Room room;
                    
                    for (var client in clients) {
                      if (index < roomIndex + client.rooms.length) {
                        clientName = client.name;
                        room = client.rooms[index - roomIndex];
                        break;
                      }
                      roomIndex += client.rooms.length;
                    }
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.description, color: Color(0xFF8B2346)),
                        title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(clientName, style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TechnicalTaskViewer(
                                clientName: clientName,
                                roomName: room.name,
                                room: room,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('МАРТ ПРО 8'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_money),
            tooltip: 'Мои доходы',
            onPressed: _showIncomeDetails,
          ),
          
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'Технические задания',
            onPressed: _showTechnicalTasksList,
          ),
          
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Новый заказ',
            onPressed: () {
              _clearForm();
              NotificationService.info(context, '✏️ Новый заказ');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Тарифы',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TariffSettingsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.archive),
            tooltip: 'Архив',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArchivePage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Календарь',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Тест уведомления',
            onPressed: () async {
              await PeriodicNotificationService.showNotification(
                title: '🔔 Тест Push',
                body: 'Уведомления работают!',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF8B2346), width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.curtains, size: 100, color: Color(0xFF8B2346)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('КЛИЕНТ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            DropdownButtonFormField<Client?>(
              value: _currentClient,
              items: [
                const DropdownMenuItem<Client?>(
                  value: null,
                  child: Text('+ Выберите клиента'),
                ),
                ...clients
                    .map((c) => DropdownMenuItem<Client?>(
                          value: c,
                          child: Text(c.name),
                        ))
                    .toList(),
              ],
              onChanged: (c) {
                if (c != null) {
                  _loadClientData(c);
                } else {
                  _clearForm();
                }
              },
              decoration: InputDecoration(
                labelText: 'Клиент',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            CustomInput(label: 'Имя', controller: _clientController),
            CustomInput(label: 'Телефон', controller: _phoneController, hint: '+7 (___)', isNumber: true),
            const SizedBox(height: 20),
            const Text('КОМНАТА', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (_currentClient != null && _currentClient!.rooms.isNotEmpty) ...[
              DropdownButtonFormField<Room?>(
                value: _editingRoom,
                items: [
                  const DropdownMenuItem<Room?>(
                    value: null,
                    child: Text('+ Новая комната'),
                  ),
                  ..._currentClient!.rooms
                      .map((r) => DropdownMenuItem<Room?>(
                            value: r,
                            child: Text(r.name),
                          ))
                      .toList(),
                ],
                onChanged: (r) {
                  if (r != null) {
                    _loadRoom(r);
                  } else {
                    setState(() {
                      _editingRoom = null;
                      _roomController.clear();
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Комната',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 8),
            ] else
              const SizedBox.shrink(),
            const SizedBox(height: 12),
            CustomInput(label: 'Название', controller: _roomController, hint: 'Гостиная'),
            CustomInput(label: 'Комментарий', controller: _commentController),
            const SizedBox(height: 20),
            const Text('ПАРАМЕТРЫ ШТОР', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            CustomDropdown(
              label: 'Тип штор',
              value: _curtainType,
              items: _curtainTypes,
              onChanged: (val) => setState(() {
                _curtainType = val!;
                _calculate();
              }),
            ),
            CustomDropdown(
              label: 'Тип карниза',
              value: _corniceType,
              items: _corniceTypes,
              onChanged: (val) => setState(() {
                _corniceType = val!;
              }),
            ),
            Row(
              children: [
                Expanded(child: CustomInput(label: 'Карниз см', controller: _corniceController, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: CustomInput(label: 'Высота см', controller: _heightController, isNumber: true)),
              ],
            ),
            Row(
              children: [
                Expanded(child: CustomInput(label: 'Коэф', controller: _coefController, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: CustomInput(label: 'Ширина рулона', controller: _rollWidthController, isNumber: true)),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 12), child: Text('Подгибы см:', style: TextStyle(fontWeight: FontWeight.w500))),
            Row(
              children: [
                Expanded(child: CustomInput(label: 'Верх', controller: _topHemController, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: CustomInput(label: 'Низ', controller: _bottomHemController, isNumber: true)),
              ],
            ),
            Row(
              children: [
                Expanded(child: CustomInput(label: 'Слева', controller: _leftHemController, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: CustomInput(label: 'Справа', controller: _rightHemController, isNumber: true)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('ТКАНИ И РАСЧЁТЫ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            CustomInput(label: 'Цена основной ткани руб/м', controller: _fabricPriceController, isNumber: true),
            CustomInput(label: 'Цена подкладочной ткани руб/м', controller: _linningPriceController, isNumber: true),
            Row(
              children: [
                Expanded(child: CustomInput(label: 'Полотен', controller: _panelsController, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: CustomInput(label: 'Профиль руб/м', controller: _profilePriceController, isNumber: true)),
              ],
            ),
            CustomInput(label: 'Надбавка профиль руб', controller: _profileMarkupController, isNumber: true),
            const SizedBox(height: 20),
            const Text('СРОК ИСПОЛНЕНИЯ ЗАКАЗА', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextField(
              controller: _deadlineController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Срок исполнения',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(_deadlineController.text),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _deadlineController.text = date.toString().split(' ')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final deadline = DateTime.parse(_deadlineController.text);

                await PeriodicNotificationService.scheduleDeadlineNotifications(
                  clientName: _clientController.text.isEmpty ? 'Клиент' : _clientController.text,
                  roomName: _roomController.text.isEmpty ? 'Комната' : _roomController.text,
                  clientDeadline: deadline,
                  seamstressDeadline: deadline,
                );

                NotificationService.success(context, '✅ Срок и уведомления установлены');
              },
              icon: const Icon(Icons.notifications),
              label: const Text('Установить срок и уведомления'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📦 ДОПОЛНИТЕЛЬНЫЕ ИЗДЕЛИЯ (${_additionalItems.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton.icon(
                  onPressed: _showAdditionalItemsDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Добавить'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 20),

            CuttingPreview(
              panels: _panels.toInt(),
              fabricMeters: _fabricMeters,
              cornice: _corniceController.text,
              coef: _coefController.text,
              topHem: _topHemController.text,
              bottomHem: _bottomHemController.text,
              leftHem: _leftHemController.text,
              rightHem: _rightHemController.text,
              error: _error,
            ),
            const SizedBox(height: 20),

            SewingCostSummary(
              sewingCostSeamstress: _sewingCostSeamstress,
              sewingCostMy: _sewingCostMy,
              clientPrice: _clientPrice,
              fabricCost: _fabricCostValue,
              linningCost: _linningCostValue,
              totalCost: _totalCost,
              myIncome: _sewingCostMy - _sewingCostSeamstress,
              isHidden: _hideSewingCosts,
              onToggle: () => setState(() => _hideSewingCosts = !_hideSewingCosts),
            ),
            const SizedBox(height: 20),

            const Text('ОПЦИИ ПОШИВА', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            CustomCheckbox(label: 'Высота свыше 3м', value: _is3m, onChanged: (v) => setState(() { _is3m = v!; _calculate(); })),
            CustomCheckbox(label: 'Сложная ткань', value: _isComplex, onChanged: (v) => setState(() { _isComplex = v!; _calculate(); })),
            CustomCheckbox(label: 'Ручная складка', value: _isHandFold, onChanged: (v) => setState(() { _isHandFold = v!; _calculate(); })),
            CustomCheckbox(label: 'Шторная лента', value: _isSeam, onChanged: (v) => setState(() { _isSeam = v!; _calculate(); })),
            CustomCheckbox(label: 'Подклад', value: _isLining, onChanged: (v) => setState(() { _isLining = v!; _calculate(); })),
            const Padding(padding: EdgeInsets.only(top: 12), child: Text('РИМСКИЕ ШТОРЫ', style: TextStyle(fontWeight: FontWeight.w500))),
            CustomCheckbox(label: 'Кольца', value: _isRings, onChanged: (v) => setState(() { _isRings = v!; _calculate(); })),
            if (_isRings) CustomInput(label: 'Кол-во', controller: _ringsController, isNumber: true),
            const SizedBox(height: 20),

            CustomDropdown(
              label: 'Статус',
              value: _status,
              items: _statuses,
              onChanged: (val) => setState(() => _status = val!),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _saveClient,
              icon: const Icon(Icons.save),
              label: Text(_editingRoom != null ? 'ОБНОВИТЬ' : 'СОХРАНИТЬ'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _generateTechTask,
              icon: const Icon(Icons.image),
              label: const Text('ТЕХНИЧЕСКОЕ ЗАДАНИЕ (JPG)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                final rooms = [
                  {
                    'name': _roomController.text,
                    'fabricMeters': _fabricMeters,
                    'clientPrice': _clientPrice,
                  }
                ];

                InvoiceGenerator.generateClientInvoice(
                  context: context,
                  clientName: _clientController.text,
                  clientPhone: _phoneController.text,
                  rooms: rooms,
                  totalAmount: _clientPrice,
                );
                NotificationService.success(context, '📄 Счёт создан');
              },
              icon: const Icon(Icons.receipt),
              label: const Text('СЧЁТ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.purple,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}