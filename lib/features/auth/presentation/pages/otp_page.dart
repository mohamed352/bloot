import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _timerSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpComplete = _controllers.every((c) => c.text.isNotEmpty);

    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
              const SizedBox(height: 16),
              // Lock icon in rounded square
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ColorManager.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorManager.darkBorderSoft,
                  ),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 36,
                  color: ColorManager.primary,
                ),
              ),
              const SizedBox(height: 24),
              // Title: Verify Your Phone
              Text(
                'verify_your_phone'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle with bold phone
              Text.rich(
                TextSpan(
                  text: 'enter_the_4_digit_code_sent_to'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorManager.darkTextSecondary.withValues(alpha: 0.8),
                  ),
                  children: const [
                    TextSpan(
                      text: ' +966 5X XXX XXXX',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ColorManager.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // OTP inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.darkTextPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: ColorManager.darkSectionGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: ColorManager.darkBorderSoft,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: ColorManager.info,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) => _onOtpChanged(index, value),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
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
                            "${'resend_code_in'.tr()} 00:$_timerSeconds",
                            style: const TextStyle(
                              color: ColorManager.darkTextMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : TextButton(
                        onPressed: () {
                          setState(() => _timerSeconds = 30);
                          _startTimer();
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
                onPressed: otpComplete
                    ? () => context.pushNamed(RouteNames.completeProfile)
                    : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
