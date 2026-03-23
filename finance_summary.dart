import 'package:flutter/material.dart';

class FinanceSummary extends StatelessWidget {
  final double fabricCost;
  final double sewingCostSeamstress;
  final double sewingCostMy;
  final double profileCost;
  final double profileMarkup;
  final double clientPrice;
  final double totalCost;
  final double profit;

  const FinanceSummary({
    super.key,
    required this.fabricCost,
    required this.sewingCostSeamstress,
    required this.sewingCostMy,
    required this.profileCost,
    required this.profileMarkup,
    required this.clientPrice,
    required this.totalCost,
    required this.profit,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // ✅ СЕБЕСТОИМОСТЬ
      Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("📊 СЕБЕСТОИМОСТЬ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8B2346))),
              const SizedBox(height: 12),
              _buildRow("Ткань:", fabricCost),
              _buildRow("Пошив (швея):", sewingCostSeamstress),
              _buildRow("Пошив (мой):", sewingCostMy),
              _buildRow("Профиль:", profileCost),
              _buildRow("Наценка профиль:", profileMarkup),
              const Divider(),
              _buildBoldRow("💰 ИТОГО:", totalCost, Colors.orange),
            ],
          ),
        ),
      ),

      const SizedBox(height: 16),

      // ✅ ДОХОДЫ
      Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("💵 ДОХОДЫ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8B2346))),
              const SizedBox(height: 12),
              _buildBoldRow("👤 Клиент платит:", clientPrice, Colors.green),
              const Divider(),
              _buildBoldRow(
                "✅ ПРИБЫЛЬ:",
                profit,
                profit >= 0 ? Colors.green : Colors.red,
                fontSize: 18,
              ),
              if (profit > 0) ...[
                const SizedBox(height: 8),
                Text(
                  "📈 Маржа: ${((profit / clientPrice) * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildRow(String label, double value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        Text("${value.toStringAsFixed(0)} руб", style: const TextStyle(fontSize: 14)),
      ],
    ),
  );

  Widget _buildBoldRow(String label, double value, Color color, {double fontSize = 16}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize)),
        Text(
          "${value.toStringAsFixed(0)} руб",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: color),
        ),
      ],
    ),
  );
}