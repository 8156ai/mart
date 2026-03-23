import 'package:flutter/material.dart';

class CuttingPreview extends StatelessWidget {
  final int panels;
  final double fabricMeters;
  final String cornice;
  final String coef;
  final String topHem;
  final String bottomHem;
  final String leftHem;
  final String rightHem;
  final String? error;

  const CuttingPreview({
    super.key,
    required this.panels,
    required this.fabricMeters,
    required this.cornice,
    required this.coef,
    required this.topHem,
    required this.bottomHem,
    required this.leftHem,
    required this.rightHem,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final corniceVal = double.tryParse(cornice) ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("✂️ РАСКРОЙ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF8B2346))),
          const SizedBox(height: 12),
          Text("📏 Полотен: $panels", style: const TextStyle(fontSize: 14)),
          Text("🧵 Ткань: ${fabricMeters.toStringAsFixed(2)} м", style: const TextStyle(fontSize: 14)),
          Text("↔️ Карниз: $cornice см × $coef", style: const TextStyle(fontSize: 14)),
          Text("📐 Длина готового изделия: ${corniceVal.toStringAsFixed(0)} см", 
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
          Text("⬆️ Верх: $topHem см | ⬇️ Низ: $bottomHem см", style: const TextStyle(fontSize: 14)),
          Text("◀️ Лево: $leftHem см | ▶️ Право: $rightHem см", style: const TextStyle(fontSize: 14)),
          if (error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}