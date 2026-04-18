import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_system/core/animation/loading_animation_widget.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/features/dashboard/dashboard_controller.dart';

class DashboardLineChart extends StatefulWidget {
  const DashboardLineChart({super.key});

  @override
  State<DashboardLineChart> createState() => _DashboardLineChartState();
}

class _DashboardLineChartState extends State<DashboardLineChart>
    with SingleTickerProviderStateMixin {
  final DashboardController getXController = Get.find<DashboardController>();

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2000,
      ), // Thori slow rakhi hai check karne ke liye
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Jab data change ho, tab animation reset karke dobara chalao
    ever(getXController.chartValues, (_) {
      if (getXController.chartValues.isNotEmpty && mounted) {
        _animationController.forward(from: 0.0);
      }
    });

    // Initial check agar data pehle se para hai
    if (getXController.chartValues.isNotEmpty) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15.w, top: 5.h),
            child: CustomText(
              text: "Revenue Trend",
              color: AppColors.blackColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Obx(() {
                if (getXController.chartValues.isEmpty) {
                  return const Center(
                    child: LoadingAnimation(loadingColor: AppColors.blackColor),
                  );
                }

                double maxVal = getXController.chartValues
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble();
                if (maxVal == 0) maxVal = 100;
                double dynamicMaxY =
                    maxVal + (maxVal * 0.2); // Yaha se height change hogi
                double dynamicInterval = dynamicMaxY / 5;

                return AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return ClipRect(
                      clipper: ChartWidthClipper(_animation.value),
                      child: child,
                    );
                  },
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          fitInsideHorizontally:
                              true, // Tooltip left/right se bahar nahi jayega
                          fitInsideVertically: true,
                          getTooltipColor: (touchedSpot) =>
                              Colors.black.withOpacity(0.8),
                          tooltipBorderRadius: BorderRadius.circular(8.r),
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((barSpot) {
                              return LineTooltipItem(
                                'Revenue: ',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: barSpot.y.toString(),
                                    style: const TextStyle(
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                      ),
                      minX: 0,
                      maxX:
                          (getXController.chartLabels.length - 1).toDouble() +
                          0.3, // Yaha se Width change hogi
                      minY: 0,
                      maxY: dynamicMaxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: dynamicInterval,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.1),
                          strokeWidth: 1.r,
                          dashArray: [5, 5],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: dynamicInterval,
                            reservedSize: 32.w,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                meta: meta,
                                space: 5.w,
                                child: CustomText(
                                  text: value >= 1000
                                      ? '${(value / 1000).toStringAsFixed(1)}k'
                                      : value.toInt().toString(),
                                  fontSize: 9.sp,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 28.w,
                            getTitlesWidget: (value, meta) {
                              var months = getXController.chartLabels;
                              if (value.toInt() >= 0 &&
                                  value.toInt() < months.length) {
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 8.h,
                                  child: CustomText(
                                    text: months[value.toInt()],
                                    fontSize: 8.sp,
                                    color: Colors.grey,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: getXController.chartValues.asMap().entries.map(
                            (entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                entry.value.toDouble(),
                              );
                            },
                          ).toList(),
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: const Color(0xFF1A1C1E),
                          barWidth: 3.r,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                    duration: Duration.zero,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartWidthClipper extends CustomClipper<Rect> {
  final double widthFactor;
  ChartWidthClipper(this.widthFactor);
  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * widthFactor, size.height);
  @override
  bool shouldReclip(ChartWidthClipper oldClipper) =>
      oldClipper.widthFactor != widthFactor;
}
