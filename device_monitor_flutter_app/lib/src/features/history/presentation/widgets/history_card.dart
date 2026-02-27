import 'package:device_monitor/src/config/resources/app_theme.dart';
import 'package:device_monitor/src/core/presentation/bloc/app_theme/bloc_app_theme.dart';
import 'package:device_monitor/src/core/utils/helpers/widget_helper.dart';
import 'package:device_monitor/src/features/home/presentation/widgets/modern_vital_card.dart';
import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryCard extends StatelessWidget{
  final VitalsEntity log;
  const HistoryCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    bool isDark = context.read<BlocAppTheme>().state.isDark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.getThermalColor(log.thermalStatus, isDark).withOpacity(0.2),
                  child: Icon(
                    Icons.monitor_heart,
                    color: AppTheme.getThermalColor(log.thermalStatus, isDark),
                  ),
                ),
                const SizedBox(width: 10,),
                Text(
                  log.timestamp==null? "N/A" :DateFormat('MMM dd, yyyy HH:mm').format(log.timestamp!),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: .8,
              children: [
                ModernVitalCard(
                  title: 'Thermal',
                  value: log.thermalStatus.toString(),
                  label: AppTheme.getThermalLabel(
                    log.thermalStatus,
                  ),
                  icon: Icons.thermostat_rounded,
                  color: AppTheme.getThermalColor(
                    log.thermalStatus,
                    isDark,
                  ),
                  percentage: (log.thermalStatus / 3 * 100).toInt(),
                  isDark: isDark,
                  borderRadius: 16,
                  labelFontSize: 10,
                ),
                ModernVitalCard(
                  title: 'Battery',
                  value: '${log.batteryLevel}',
                  label: '%',
                  icon: Icons.battery_charging_full_rounded,
                  color: WidgetHelper.getBatteryColor(log.batteryLevel),
                  percentage: log.batteryLevel,
                  isDark: isDark,
                  borderRadius: 16,
                ),
                ModernVitalCard(
                  title: 'Memory',
                  value: '${log.memoryUsage}',
                  label: '%',
                  icon: Icons.memory_rounded,
                  color: WidgetHelper.getMemoryColor(log.memoryUsage),
                  percentage: log.memoryUsage,
                  isDark: isDark,
                  borderRadius: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}