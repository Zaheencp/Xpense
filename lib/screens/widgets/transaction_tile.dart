import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final String description;
  final double amount;
  final String date;
  final bool isExpense;
  final String? location;

  const TransactionTile({
    super.key,
    required this.description,
    required this.amount,
    required this.date,
    this.isExpense = true,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = isExpense ? Colors.red[400] : Colors.green[400];

    // Format the date
    final dateTime = DateTime.tryParse(date);
    final formattedDate = dateTime != null
        ? DateFormat('MMM d, y • hh:mm a').format(dateTime)
        : date;

    // Format amount without currency symbol and with proper sign
    final formattedAmount =
        '${isExpense ? '-' : '+'}${amount.abs().toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading icon
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: amountColor?.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                color: amountColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: amountColor?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                '\$$formattedAmount',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
