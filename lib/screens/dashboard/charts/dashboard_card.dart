import 'package:flutter/material.dart';

/// Generic card structure with variable height
class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double? chartHeight; // Nullable, let's child be as big as it wants

  const DashboardCard({Key? key, required this.title, required this.child, this.chartHeight = 250}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: chartHeight == null ? child : SizedBox(height: chartHeight, child: child),
          ),
        ],
      ),
    );
  }
}
