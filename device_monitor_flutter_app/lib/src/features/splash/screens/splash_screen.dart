import 'package:device_monitor/src/config/resources/app_colors.dart';
import 'package:device_monitor/src/config/routes/routes.dart';
import 'package:device_monitor/src/core/enums/e_dialog_type.dart';
import 'package:device_monitor/src/core/utils/helpers/widget_helper.dart';
import 'package:device_monitor/src/core/widgets/buttons/basic_button.dart';
import 'package:device_monitor/src/features/device/presentation/bloc/bloc_device_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //check if device is registered or not to continue
      context.read<BlocDeviceMonitor>().add(EventCheckDeviceStatus());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<BlocDeviceMonitor, StateDeviceMonitor>(
        listenWhen: (previous, current) {
          // Only listen to specific state changes
          return current is StateDeviceMonitorDeviceRegistered ||
              current is StateDeviceMonitorRegistrationFailed;
        },
        listener: (context, state) {
          if (state is StateDeviceMonitorDeviceRegistered) {
            Fluttertoast.showToast(msg: state.message ?? 'Success');
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.homeScreen,
                  (route) => false,
            );
          }

          if (state is StateDeviceMonitorRegistrationFailed) {
            WidgetHelper.showAlertDialog(
              title: "Failed!",
              message: state.errorMessage,
              dialogType: EDialogType.error,
              positiveButton: BasicButton(
                buttonText: "Retry Now",
                onPressed: () {
                  context.read<BlocDeviceMonitor>().add(EventRegisterDevice());
                  Navigator.pop(context);
                },
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? AppColors.gradientDarkBackground : AppColors.gradientLightBackground,
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF10B981) : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.monitor_heart_rounded,
                            size: 64,
                            color: isDark ? Colors.white : const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // App Name
                        Text(
                          'Device Monitor',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF064E3B),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Tagline
                        Text(
                          'Track Your Device Health',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Loading indicator
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? const Color(0xFF34D399) : const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
