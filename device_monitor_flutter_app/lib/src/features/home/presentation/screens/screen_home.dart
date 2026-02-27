import 'package:device_monitor/src/config/resources/app_colors.dart';
import 'package:device_monitor/src/config/resources/app_theme.dart';
import 'package:device_monitor/src/config/routes/routes.dart';
import 'package:device_monitor/src/core/enums/e_loading.dart';
import 'package:device_monitor/src/core/presentation/bloc/app_theme/bloc_app_theme.dart';
import 'package:device_monitor/src/core/utils/helpers/calculation_helper.dart';
import 'package:device_monitor/src/core/utils/helpers/format_helper.dart';
import 'package:device_monitor/src/core/utils/helpers/widget_helper.dart';
import 'package:device_monitor/src/features/device/presentation/providers/provider_device_monitor.dart';
import 'package:device_monitor/src/features/home/presentation/widgets/app_drawer.dart';
import 'package:device_monitor/src/features/home/presentation/widgets/health_score_painter.dart';
import 'package:device_monitor/src/features/home/presentation/widgets/modern_vital_card.dart';
import 'package:device_monitor/src/features/vitals/presentation/providers/provider_vitals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for health indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation for refresh icon
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderVitals>().refreshVitals();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Device Monitor',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          BlocBuilder<BlocAppTheme, StateAppTheme>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isDark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => context.read<BlocAppTheme>().add(EventAppThemeToggle()),
                tooltip: 'Toggle Theme',
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? AppColors.gradientDarkBackground : AppColors.gradientLightBackground,
            ),
          ),
          child: Consumer<ProviderVitals>(
            builder: (context, provider, child) {
              return RefreshIndicator(
                onRefresh: () async {
                  _rotateController.forward(from: 0);
                  await provider.refreshVitals();
                },
                color: AppColors.primaryGreen,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Top spacing for AppBar
                    SliverToBoxAdapter(
                      child: SizedBox(height: 40.h),
                    ),

                    // Main Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Health Status Hero Section
                            _buildHealthStatusHero(provider, isDark),
                            const SizedBox(height: 32),

                            // Messages
                            if (provider.error != null || provider.successMessage != null) _buildMessageBanner(provider),

                            // Vitals Grid
                            if (provider.loading == ELoading.refreshing)
                              _buildLoadingState()
                            else if (provider.currentVitals != null)
                              _buildVitalsContent(provider, isDark, size)
                            else
                              _buildEmptyState(provider),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 120,
        child: Consumer<ProviderVitals>(builder: (_, vitalsProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Action Buttons
                _buildActionButtons(vitalsProvider, isDark),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHealthStatusHero(ProviderVitals provider, bool isDark) {
    final healthScore = CalculationHelper.calculateHealthScore(provider.currentVitals);
    final healthStatus = WidgetHelper.getHealthStatus(healthScore);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: provider.currentVitals != null ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF059669).withOpacity(0.2),
                        const Color(0xFF0D9488).withOpacity(0.1),
                      ]
                    : [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.primaryGreen.withOpacity(0.3) : AppColors.primaryGreen.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Health Score Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200.h,
                      height: 200.h,
                      child: CustomPaint(
                        painter: HealthScorePainter(
                          score: provider.currentVitals != null ? healthScore : 0,
                          color: WidgetHelper.getHealthColor(healthScore),
                          isDark: isDark,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 28.h,
                          color: WidgetHelper.getHealthColor(healthScore),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.currentVitals != null ? '${healthScore.toInt()}' : '--',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: WidgetHelper.getHealthColor(healthScore),
                          ),
                        ),
                        Text(
                          'Health Score',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: WidgetHelper.getHealthColor(healthScore).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: WidgetHelper.getHealthColor(healthScore).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        WidgetHelper.getHealthIcon(healthScore),
                        color: WidgetHelper.getHealthColor(healthScore),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        healthStatus,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: WidgetHelper.getHealthColor(healthScore),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Last Updated
                if (provider.currentVitals != null)
                  Text(
                    'Updated ${FormatHelper.getTimeAgo(provider.currentVitals?.timestamp)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVitalsContent(ProviderVitals provider, bool isDark, Size size) {
    return Column(
      children: [
        // Vitals Cards in Grid
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: [
            ModernVitalCard(
              title: 'Thermal',
              value: provider.currentVitals!.thermalStatus.toString(),
              label: AppTheme.getThermalLabel(
                provider.currentVitals!.thermalStatus,
              ),
              icon: Icons.thermostat_rounded,
              color: AppTheme.getThermalColor(
                provider.currentVitals!.thermalStatus,
                isDark,
              ),
              percentage: (provider.currentVitals!.thermalStatus / 3 * 100).toInt(),
              isDark: isDark,
            ),
            ModernVitalCard(
              title: 'Battery',
              value: '${provider.currentVitals!.batteryLevel}',
              label: '%',
              icon: Icons.battery_charging_full_rounded,
              color: WidgetHelper.getBatteryColor(provider.currentVitals!.batteryLevel),
              percentage: provider.currentVitals!.batteryLevel,
              isDark: isDark,
            ),
            ModernVitalCard(
              title: 'Memory',
              value: '${provider.currentVitals!.memoryUsage}',
              label: '%',
              icon: Icons.memory_rounded,
              color: WidgetHelper.getMemoryColor(provider.currentVitals!.memoryUsage),
              percentage: provider.currentVitals!.memoryUsage,
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                provider,
                isDark,
                "View\nAnalytics",
                () {
                  Navigator.pushNamed(
                    context,
                    Routes.analyticsScreen,
                    arguments: context.read<ProviderDeviceMonitor>().currentDevice?.deviceId,
                  );
                },
              ),
            ),
            SizedBox(
              width: 16.w,
            ),
            Expanded(
              child: _buildQuickActionCard(
                provider,
                isDark,
                "View\nHistory",
                () {
                  Navigator.pushNamed(
                    context,
                    Routes.historyScreen,
                    arguments: context.read<ProviderDeviceMonitor>().currentDevice?.deviceId,
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuickActionCard(
    ProviderVitals provider,
    bool isDark,
    String title,
    Function onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primaryGreen.withOpacity(0.2),
                  AppColors.secondaryTeal.withOpacity(0.1),
                ]
              : [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.secondaryTeal.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap.call();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: AppColors.primaryGreen,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryGreen.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ProviderVitals provider, bool isDark) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _rotateController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotateController.value * 2 * math.pi,
              child: GestureDetector(
                onTap: provider.loading == ELoading.refreshing
                    ? null
                    : () {
                  _rotateController.forward(from: 0);
                  provider.refreshVitals();
                },
                child: CircleAvatar(
                  child: Icon(
                    Icons.refresh_rounded,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryGreen,
                  AppColors.secondaryTeal,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => provider.saveVitals(),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (provider.loading == ELoading.submitButtonLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        const Icon(
                          Icons.cloud_upload_rounded,
                          color: Colors.white,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        provider.loading == ELoading.submitButtonLoading ? 'Logging...' : 'Log Status',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBanner(ProviderVitals provider) {
    final isError = provider.error != null;
    final message = isError ? provider.error! : provider.successMessage!;
    final color = isError ? AppColors.errorRed : AppColors.successGreen;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!isError)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: color,
              onPressed: () => provider.clearMessages(),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Reading sensors...'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ProviderVitals provider) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sensors_off,
              size: 64,
              color: AppColors.primaryGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No sensor data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap below to start monitoring',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.refreshVitals(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Monitoring'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

