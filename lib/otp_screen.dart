import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:holaa_tv/description_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6, (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());
  int _countdown = 60;
  late Timer _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initSmsListener();
  }

  void _initSmsListener() {
    // For Android auto-fill
    _auth.setSettings(appVerificationDisabledForTesting: false);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SubscriptionScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _countdown = 60;
      _startTimer();
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        verificationFailed: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        },
        codeSent: (verificationId, forceResendingToken) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully')),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
        forceResendingToken: widget.resendToken,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage("images/ticon.jpeg"),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.04),
                        Text(
                          'Verify',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.07,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01),
                        Text(
                          'OTP',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellowAccent,
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.03),
                        Text(
                          'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.04,
                            color: Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            6,
                                (index) => SizedBox(
                              width: constraints.maxWidth * 0.12,
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _otpFocusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[900],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.length == 1 && index < 5) {
                                    FocusScope.of(context)
                                        .requestFocus(_otpFocusNodes[index + 1]);
                                  } else if (value.isEmpty && index > 0) {
                                    FocusScope.of(context)
                                        .requestFocus(_otpFocusNodes[index - 1]);
                                  }
                                  if (index == 5 && value.isNotEmpty) {
                                    _verifyOTP();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.05),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            padding: EdgeInsets.symmetric(
                              vertical: constraints.maxHeight * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            'VERIFY',
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.03),
                        TextButton(
                          onPressed: _countdown == 0 ? _resendCode : null,
                          child: Text(
                            'DIDN\'T RECEIVE CODE?',
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.035,
                              color: _countdown == 0 ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            _countdown > 0
                                ? 'Resend OTP in ${_countdown ~/ 60}:${(_countdown % 60).toString().padLeft(2, '0')}'
                                : '',
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.035,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

