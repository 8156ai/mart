import 'package:flutter/material.dart';

class SewingCostSummary extends StatelessWidget {
  final double sewingCostSeamstress;
  final double sewingCostMy;
  final double clientPrice;
  final double fabricCost;
  final double linningCost;
  final double totalCost;
  final double myIncome;
  final bool isHidden;
  final VoidCallback onToggle;

  const SewingCostSummary({
    super.key,
    required this.sewingCostSeamstress,
    required this.sewingCostMy,
    required this.clientPrice,
    required this.fabricCost,
    required this.linningCost,
    required this.totalCost,
    required this.myIncome,
    required this.isHidden,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ ЗАГОЛОВОК С ПЕРЕКЛЮЧАТЕЛЕМ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🧵 СТОИМОСТЬ ПОШИВА',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF8B2346),
                  ),
                ),
                Row(
                  children: [
                    const Text('Скрыть', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Switch(
                      value: isHidden,
                      onChanged: (_) => onToggle(),
                      activeColor: const Color(0xFF8B2346),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ ТАБЛИЦА ПОШИВА (ВИДНА, ЕСЛИ НЕ СКРЫТА)
            if (!isHidden) ...[
              // СЕБЕСТОИМОСТЬ ПОШИВА ШВЕЯ
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👩‍🔧 СЕБЕСТОИМОСТЬ ПОШИВА ШВЕЯ:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Стоимость пошива',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        Text(
                          '${sewingCostSeamstress.toStringAsFixed(0)} руб',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // МОЯ ЦЕНА ПОШИВА
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👤 МОЯ ЦЕНА ПОШИВА:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Стоимость пошива',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        Text(
                          '${sewingCostMy.toStringAsFixed(0)} руб',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // МОЙ ДОХОД НА ПОШИВЕ
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💰 МОЙ ДОХОД НА ПОШИВЕ:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Разница (Я - Швея)',
                          style: TextStyle(fontSize: 13, color: Colors.green),
                        ),
                        Text(
                          '${myIncome.toStringAsFixed(0)} руб',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: myIncome >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ✅ СЕБЕСТОИМОСТЬ
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 СЕБЕСТОИМОСТЬ:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF8B2346),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ткань основная:',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${fabricCost.toStringAsFixed(0)} руб',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ткань подкладочная:',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${linningCost.toStringAsFixed(0)} руб',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ИТОГО:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${totalCost.toStringAsFixed(0)} руб',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(thickness: 2),
              const SizedBox(height: 12),
            ],

            // ✅ ЦЕНА ДЛЯ КЛИЕНТА (ВСЕГДА ВИДНА)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '💳 ЦЕНА ДЛЯ КЛИЕНТА:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ткань основная + подклад:',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        '${(fabricCost + linningCost).toStringAsFixed(0)} руб',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Пошив:',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        '${sewingCostMy.toStringAsFixed(0)} руб',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ВСЕГО:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${clientPrice.toStringAsFixed(0)} руб',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}