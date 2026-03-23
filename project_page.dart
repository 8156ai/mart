import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/room.dart';
import '../providers/client_provider.dart';
import '../../../pricing/domain/seamstress_prices.dart';
import '../../../pricing/domain/my_prices.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../../../shared/widgets/custom_checkbox.dart';
import '../widgets/cutting_preview.dart';
import '../widgets/finance_summary.dart';
import '../../../../shared/services/technical_task_generator.dart';
import '../../../../shared/services/invoice_generator.dart';
import '../../../../shared/services/validators.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../../shared/services/calculation_service.dart';
import '../../../../shared/services/periodic_notification_service.dart';
import 'archive_page.dart';
import 'calendar_page.dart';
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
  bool _hideSeamstressData = false;

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
      sewingCostSeamstress: _sewingCostSeamstress,
      sewingCostMy: _sewingCostMy,
      additionalItems: _additionalItems,
    );

    setState(() {
      _error = result.error;
      _fabricMeters = result.fabricMeters;
      _linningMeters = result.linningMeters;
      _fabricCostValue = result.fabricCostValue;
      _linningCostValue = result.linningCostValue;
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
      _corniceController.text = specs['cornice'].toString();
      _heightController.text = specs['height'].toString();
      _coefController.text = specs['coef'].toString();
      _topHemController.text = specs['topHem'].toString();
      _bottomHemController.text = specs['bottomHem'].toString();
      _leftHemController.text = specs['leftHem'].toString();
      _rightHemController.text = specs['rightHem'].toString();
      _fabricPriceController.text = specs['fabricPrice'].toString();
      _linningPriceController.text = specs['linningPrice'].toString();
      _profilePriceController.text = specs['profilePrice'].toString();
      _profileMarkupController.text = specs['profileMarkup'].toString();
      _panelsController.text = specs['panels'].toStringAsFixed(0);

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
      // ❌ УБРАТЬ deadline
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
            tooltip: 'Доходы',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💵 МОИ ДОХОДЫ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B2346))),
                      const SizedBox(height: 20),
                      _buildIncomeRow('Клиент платит', _clientPrice, Colors.green),
                      _buildIncomeRow('Себестоимость', _totalCost, Colors.orange),
                      const Divider(),
                      _buildIncomeRow('ПРИБЫЛЬ', _profit, _profit >= 0 ? Colors.green : Colors.red, bold: true),
                      if (_clientPrice > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Маржа: ${((_profit / _clientPrice) * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Новый',
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
            tooltip: 'Календарь сделок',
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
                Expanded(child: CustomInput(label: 'Лево', controller: _leftHemController, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: CustomInput(label: 'Право', controller: _rightHemController, isNumber: true)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('ТКАНИ И РАСЧЕТЫ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            CustomInput(label: 'Цена основной ткани руб м', controller: _fabricPriceController, isNumber: true),
            CustomInput(label: 'Цена подкладочной ткани руб м', controller: _linningPriceController, isNumber: true),
            Row(
              children: [
                Expanded(child: CustomInput(label: 'Полотен', controller: _panelsController, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: CustomInput(label: 'Профиль руб/м', controller: _profilePriceController, isNumber: true)),
              ],
            ),
            CustomInput(label: 'Наценка профиль руб', controller: _profileMarkupController, isNumber: true),
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

                NotificationService.success(context, '✅ Срок и напоминания установлены');
              },
              icon: const Icon(Icons.notifications),
              label: const Text('Установить срок и напоминания'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 20),
            const Text('ДОП ИЗДЕЛИЯ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ..._additionalItems.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: item['name'] ?? ''),
                      decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                      onChanged: (val) {
                        _additionalItems[idx]['name'] = val;
                        _calculate();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: TextEditingController(text: (item['price'] ?? 0).toString()),
                      decoration: const InputDecoration(labelText: 'Цена', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        _additionalItems[idx]['price'] = double.tryParse(val) ?? 0;
                        _calculate();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _additionalItems.removeAt(idx);
                        _calculate();
                      });
                      NotificationService.success(context, '🗑️ Позиция удалена');
                    },
                  ),
                ],
              );
            }),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _additionalItems.add({'name': '', 'price': 0});
                  _calculate();
                });
                NotificationService.success(context, '✅ Новая позиция добавлена');
              },
              icon: const Icon(Icons.add),
              label: const Text('Добавить'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🙈 Скрыть данные', style: TextStyle(fontWeight: FontWeight.w500)),
                    Switch(
                      value: _hideSeamstressData,
                      onChanged: (val) => setState(() => _hideSeamstressData = val),
                      activeColor: const Color(0xFF8B2346),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!_hideSeamstressData) ...[
              const Text('ОПЦИИ ПОШИВА', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              CustomCheckbox(label: 'Высота над 3м', value: _is3m, onChanged: (v) => setState(() { _is3m = v!; _calculate(); })),
              CustomCheckbox(label: 'Сложная ткань', value: _isComplex, onChanged: (v) => setState(() { _isComplex = v!; _calculate(); })),
              CustomCheckbox(label: 'Ручная складка', value: _isHandFold, onChanged: (v) => setState(() { _isHandFold = v!; _calculate(); })),
              CustomCheckbox(label: 'Шторная лента', value: _isSeam, onChanged: (v) => setState(() { _isSeam = v!; _calculate(); })),
              CustomCheckbox(label: 'Подклад', value: _isLining, onChanged: (v) => setState(() { _isLining = v!; _calculate(); })),
              const Padding(padding: EdgeInsets.only(top: 12), child: Text('РИМСКИЕ', style: TextStyle(fontWeight: FontWeight.w500))),
              CustomCheckbox(label: 'Кольца', value: _isRings, onChanged: (v) => setState(() { _isRings = v!; _calculate(); })),
              if (_isRings) CustomInput(label: 'Кол-во', controller: _ringsController, isNumber: true),
              const SizedBox(height: 20),
            ],
            CustomDropdown(
              label: 'Статус',
              value: _status,
              items: _statuses,
              onChanged: (val) => setState(() => _status = val!),
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
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ткань основная:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('${_fabricCostValue.toStringAsFixed(0)} руб', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ткань подкладочная:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('${_linningCostValue.toStringAsFixed(0)} руб', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ЦЕНА КЛИЕНТА:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${_clientPrice.toStringAsFixed(0)} руб', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
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
                NotificationService.success(context, '📄 Счет создан');
              },
              icon: const Icon(Icons.receipt),
              label: const Text('СЧЕТ'),
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