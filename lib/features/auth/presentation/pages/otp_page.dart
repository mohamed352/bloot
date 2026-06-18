import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_state.dart';
import 'package:bloot/features/auth/presentation/widgets/otp_input_field.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const _otpLength = 6;
  String _otpCode = '';
  int _timerSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _maskPhoneNumber(String? phone) {
    if (phone == null || phone.length < 7) return '';
    final prefix = phone.substring(0, phone.length - 6);
    return '$prefix ••• ${phone.substring(phone.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final otpComplete = _otpCode.length == _otpLength;
    final phoneNumber = context.read<AuthCubit>().phoneNumber;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          authenticated: (_) => context.goNamed(RouteNames.home),
          profileRequired: () => context.pushNamed(RouteNames.completeProfile),
          error: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message.tr())));
          },
        );
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          appBar: AppBar(
            backgroundColor: const Color(0x00000000),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  // Lock icon in rounded square
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: ColorManager.darkSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: ColorManager.darkBorderSoft),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 36,
                      color: ColorManager.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Title: Verify Your Phone
                  Text(
                    'verify_your_phone'.tr(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Subtitle with bold phone
                  Text.rich(
                    TextSpan(
                      text: 'enter_the_6_digit_code_sent_to'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorManager.darkTextSecondary.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      children: [
                        TextSpan(
                          text: ' ${_maskPhoneNumber(phoneNumber)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: ColorManager.darkTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  // OTP inputs
                  OtpInputField(
                    length: _otpLength,
                    onChanged: (code) => setState(() => _otpCode = code),
                    onCompleted: (code) {
                      setState(() => _otpCode = code);
                      if (!isLoading) {
                        context.read<AuthCubit>().verifyOtp(code);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  // Resend timer with clock icon
                  Center(
                    child: _timerSeconds > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: ColorManager.darkTextMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'resend_code_in'.tr(
                                  namedArgs: {
                                    'seconds': _timerSeconds.toString().padLeft(
                                      2,
                                      '0',
                                    ),
                                  },
                                ),
                                style: const TextStyle(
                                  color: ColorManager.darkTextMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    setState(() => _timerSeconds = 30);
                                    _startTimer();
                                    context.read<AuthCubit>().resendOtp();
                                  },
                            child: Text(
                              'resend_code'.tr(),
                              style: const TextStyle(
                                color: ColorManager.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  ),
                  const Spacer(),
                  // Verify button with purple gradient
                  GradientButton(
                    text: 'verify'.tr(),
                    gradient: GradientButton.purpleGradient,
                    isLoading: isLoading,
                    onPressed: otpComplete && !isLoading
                        ? () => context.read<AuthCubit>().verifyOtp(_otpCode)
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
