import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpense/controllers/firebasecontroller.dart';
import 'package:xpense/models/chartmodel.dart';
import 'package:xpense/models/categorymodel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Charts extends StatelessWidget {
  const Charts({super.key});

  void _showCategoryDetails(
      BuildContext context, ChartModel category, double totalAmount) {
    final percentage = totalAmount > 0
        ? (category.amount / totalAmount * 100).toStringAsFixed(1)
        : '0.0';
    final formattedAmount =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2)
            .format(category.amount);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category.category
                      .replaceAll(' (Expense)', '')
                      .replaceAll(' (Income)', '')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedAmount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey[700],
                ),
                Column(
                  children: [
                    Text(
                      'Percentage',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: category.amount / totalAmount,
                child: Container(
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('Expense & Income Chart',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
        body: Consumer<FirebaseController>(builder: (context, value, child) {
          final stream = value.fetchdatachart();
          if (stream == null) {
            return const Center(
              child: Text(
                'Please log in to view charts',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return Column(children: [
            Expanded(
                child: StreamBuilder<List<ChartModel>>(
                    stream: stream,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            snapshot.error.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      } else if (snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      }
                      // Separate expenses and incomes
                      Map<String, double> expenseCategories = {};
                      Map<String, double> incomeCategories = {};
                      double totalExpenses = 0.0;
                      double totalIncomes = 0.0;

                      List<ChartModel> chartmodel = snapshot.data!;
                      for (final chartModel in chartmodel) {
                        final categoryName = chartModel.category.toLowerCase();
                        // Check if it's an income category
                        final isIncome = Expensecategory.incomes.any(
                            (cat) => cat.name?.toLowerCase() == categoryName);

                        if (isIncome) {
                          final previous =
                              incomeCategories[chartModel.category] ?? 0;
                          incomeCategories[chartModel.category] =
                              previous + chartModel.amount;
                          totalIncomes += chartModel.amount;
                        } else {
                          final previous =
                              expenseCategories[chartModel.category] ?? 0;
                          expenseCategories[chartModel.category] =
                              previous + chartModel.amount;
                          totalExpenses += chartModel.amount;
                        }
                      }

                      // Calculate total amount for percentage calculation
                      double totalAmount = totalExpenses + totalIncomes;

                      // Color schemes - expenses in red/orange tones, incomes in green/blue tones
                      final Map<String, Color> expenseColorMap = {
                        'food': Colors.orange[400]!,
                        'transportation': Colors.blue[400]!,
                        'bills': Colors.red[400]!,
                        'home': Colors.teal[400]!,
                        'car': Colors.indigo[400]!,
                        'entertainment': Colors.purple[400]!,
                        'shopping': Colors.pink[400]!,
                        'clothing': Colors.brown[400]!,
                        'insurance': Colors.cyan[400]!,
                        'cigerette': Colors.grey[400]!,
                        'telephone': Colors.green[400]!,
                        'health': Colors.lightGreen[400]!,
                        'sports': Colors.amber[400]!,
                        'baby': Colors.deepOrange[400]!,
                        'pet': Colors.blueGrey[400]!,
                        'education': Colors.deepPurple[400]!,
                        'travel': Colors.lime[600]!,
                        'gift': Colors.redAccent[400]!,
                      };

                      final Map<String, Color> incomeColorMap = {
                        'salary': Colors.green[400]!,
                        'awards': Colors.lightGreen[600]!,
                        'grant': Colors.teal[400]!,
                        'sale': Colors.blue[400]!,
                        'refund': Colors.cyan[400]!,
                        'lottery': Colors.amber[400]!,
                        'coupens': Colors.lime[600]!,
                        'investment': Colors.indigo[400]!,
                      };

                      final List<Color> expenseFallbackPalette = [
                        Colors.red[300]!,
                        Colors.orange[300]!,
                        Colors.deepOrange[300]!,
                        Colors.pink[300]!,
                        Colors.redAccent[200]!,
                        Colors.orangeAccent[200]!,
                      ];

                      final List<Color> incomeFallbackPalette = [
                        Colors.green[300]!,
                        Colors.lightGreen[300]!,
                        Colors.teal[300]!,
                        Colors.cyan[300]!,
                        Colors.blue[300]!,
                        Colors.indigo[300]!,
                      ];

                      List<ChartModel> addedchart = [];

                      // Add expense categories with red/orange tones
                      int expenseColorIndex = 0;
                      expenseCategories.forEach((category, amount) {
                        final color = expenseColorMap[category.toLowerCase()] ??
                            expenseFallbackPalette[expenseColorIndex++ %
                                expenseFallbackPalette.length];
                        addedchart.add(
                            ChartModel('$category (Expense)', amount, color));
                      });

                      // Add income categories with green/blue tones
                      int incomeColorIndex = 0;
                      incomeCategories.forEach((category, amount) {
                        final color = incomeColorMap[category.toLowerCase()] ??
                            incomeFallbackPalette[incomeColorIndex++ %
                                incomeFallbackPalette.length];
                        addedchart.add(
                            ChartModel('$category (Income)', amount, color));
                      });

                      // Sort by amount (largest first) for better visualization
                      addedchart.sort((a, b) => b.amount.compareTo(a.amount));

                      return Padding(
                        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                        child: Column(
                          children: [
                            // Summary card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Total Expenses',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        NumberFormat.currency(
                                                symbol: '\$', decimalDigits: 2)
                                            .format(totalExpenses),
                                        style: TextStyle(
                                          color: Colors.red[300],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey[700],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Total Income',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        NumberFormat.currency(
                                                symbol: '\$', decimalDigits: 2)
                                            .format(totalIncomes),
                                        style: TextStyle(
                                          color: Colors.green[300],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey[700],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Net Balance',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        NumberFormat.currency(
                                                symbol: '\$', decimalDigits: 2)
                                            .format(
                                                totalIncomes - totalExpenses),
                                        style: TextStyle(
                                          color:
                                              (totalIncomes - totalExpenses) >=
                                                      0
                                                  ? Colors.green[300]
                                                  : Colors.red[300],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Type indicator
                            if (totalExpenses > 0 && totalIncomes > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.red[300],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Expenses',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 24),
                                    Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.green[300],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Income',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (totalExpenses > 0 && totalIncomes > 0)
                              const SizedBox(height: 16),
                            // Responsive chart
                            Expanded(
                              child: SfCircularChart(
                                backgroundColor: Colors.black,
                                legend: Legend(
                                  isVisible: true,
                                  position: isTablet
                                      ? LegendPosition.right
                                      : LegendPosition.bottom,
                                  overflowMode: LegendItemOverflowMode.wrap,
                                  textStyle: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  itemPadding: 8,
                                  iconHeight: 12,
                                  iconWidth: 12,
                                ),
                                tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  canShowMarker: true,
                                  header: '',
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                  color: Colors.grey[900]!,
                                ),
                                series: <CircularSeries<ChartModel, String>>[
                                  PieSeries<ChartModel, String>(
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible:
                                          !isTablet, // Hide labels on tablet to avoid clutter
                                      labelIntersectAction:
                                          LabelIntersectAction.shift,
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                      connectorLineSettings:
                                          ConnectorLineSettings(
                                        length: '10',
                                        color: Colors.white,
                                        width: 1.0,
                                      ),
                                    ),
                                    radius: isTablet ? '70%' : '75%',
                                    dataSource: addedchart,
                                    pointColorMapper: (ChartModel data, _) =>
                                        data.color,
                                    xValueMapper: (ChartModel data, _) =>
                                        data.category,
                                    yValueMapper: (ChartModel data, _) =>
                                        data.amount,
                                    dataLabelMapper: (ChartModel data, _) {
                                      final percentage =
                                          (data.amount / totalAmount * 100)
                                              .toStringAsFixed(1);
                                      // Extract category name without (Expense) or (Income) suffix
                                      final categoryName = data.category
                                          .replaceAll(' (Expense)', '')
                                          .replaceAll(' (Income)', '');
                                      return '$categoryName\n$percentage%';
                                    },
                                    enableTooltip: true,
                                    // Add tap interaction
                                    onPointTap: (ChartPointDetails details) {
                                      if (details.pointIndex != null) {
                                        final tappedCategory =
                                            addedchart[details.pointIndex!];
                                        _showCategoryDetails(context,
                                            tappedCategory, totalAmount);
                                      }
                                    },
                                    // Add selection for better UX
                                    selectionBehavior: SelectionBehavior(
                                      enable: true,
                                      selectedColor: Colors.white,
                                      selectedBorderColor: Colors.white,
                                      selectedBorderWidth: 3,
                                    ),
                                    animationDuration: 0,
                                    explode: true,
                                    explodeOffset: '5%',
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }))
          ]);
        }));
  }
}
