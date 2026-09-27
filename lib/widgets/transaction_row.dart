import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';

enum RowStatus { pending, saved, saving, redeeming, done }

class TransactionRow extends StatefulWidget {
  final Transaction transaction;
  final RowStatus status;
  final void Function(double amount) onSave;
  final VoidCallback onRedeem;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.status,
    required this.onSave,
    required this.onRedeem,
  });

  @override
  State<TransactionRow> createState() => _TransactionRowState();
}

class _TransactionRowState extends State<TransactionRow> {
  late final TextEditingController _amountCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.transaction.amount > 0
          ? widget.transaction.amount
              .toStringAsFixed(
                widget.transaction.amount.truncateToDouble() ==
                        widget.transaction.amount
                    ? 0
                    : 2,
              )
          : '',
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    final text = _amountCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Enter an amount');
      return;
    }
    final value = double.tryParse(text);
    if (value == null || value <= 0) {
      setState(() => _error = 'Enter a valid positive amount');
      return;
    }
    setState(() => _error = null);
    widget.onSave(value);
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = widget.status == RowStatus.saved ||
        widget.status == RowStatus.redeeming;
    final isBusy = widget.status == RowStatus.saving ||
        widget.status == RowStatus.redeeming;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSaved
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.transaction.rollNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isSaved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${widget.transaction.amount}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      enabled: !isBusy,
                      decoration: InputDecoration(
                        prefixText: '₹ ',
                        hintText: '0',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: _error,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  height: 44,
                  child: isSaved
                      ? ElevatedButton(
                          onPressed: isBusy ? null : widget.onRedeem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Redeem'),
                        )
                      : ElevatedButton(
                          onPressed: isBusy ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}