import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:url_launcher/url_launcher.dart';
import 'otp_screen.dart';

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}
class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final TextEditingController controller = TextEditingController();
  String? phoneNumber;
  PhoneNumber? selectedCountry;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendOTP() async {
    if (phoneNumber == null || phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                verificationId: verificationId,
                phoneNumber: phoneNumber!,
                resendToken: resendToken,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() => _isLoading = false);
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  // Function to launch the URL

  void _launchURL() async {
    final Uri _url = Uri.parse("https://holaatv.com/in/terms-and-conditions.php");
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $_url';
    }
  }
  void _launchURL1() async {
    final Uri _url = Uri.parse("https://holaatv.com/in/privacy-policy.php");
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $_url';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
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
                          'Enter your',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.07,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01),
                        Text(
                          'Mobile Number',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellowAccent,
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.05),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            border: Border.all(color: Colors.grey[800]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number) {
                              setState(() {
                                phoneNumber = number.phoneNumber;
                                selectedCountry = number;
                              });
                            },
                            selectorConfig: const SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              showFlags: true,
                              useEmoji: true,
                              trailingSpace: false,
                            ),
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.onUserInteraction,
                            selectorTextStyle: TextStyle(
                              fontSize: constraints.maxWidth * 0.045,
                              color: Colors.white,
                            ),
                            textStyle: TextStyle(
                              fontSize: constraints.maxWidth * 0.05,
                              color: Colors.white,
                            ),
                            initialValue: PhoneNumber(isoCode: 'IN'),
                            textFieldController: controller,
                            formatInput: true,
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            inputDecoration: InputDecoration(
                              hintText: 'Phone Number',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: constraints.maxHeight * 0.02,
                              ),
                            ),
                          ),
                        ),
                        if (selectedCountry != null)
                          Padding(
                            padding: EdgeInsets.only(top: constraints.maxHeight * 0.02),
                            child: Text(
                              'Selected: ${selectedCountry!.dialCode} (${selectedCountry!.isoCode})',
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.035,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        SizedBox(height: constraints.maxHeight * 0.05),
                        ElevatedButton(
                          onPressed:_isLoading ? null : _sendOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              vertical: constraints.maxHeight * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            'GET OTP',
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.05),
                        Column(
                          children: [
                           Text(
                                'BY CONTINUING YOU AGREE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.035,
                                  color: Colors.grey[600],
                                ),
                              ),
                            SizedBox(height: constraints.maxHeight * 0.005),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'TO HOLAA TV ',
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth * 0.035,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _launchURL,
                                      child: Text(
                                        'TERMS AND CONDITIONS',
                                        style: TextStyle(
                                          fontSize: constraints.maxWidth * 0.035,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            SizedBox(height: constraints.maxHeight * 0.005),

                               Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ' AND ',
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth * 0.035,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _launchURL1,
                                      child: Text(
                                        'PRIVACY POLICY',
                                        style: TextStyle(
                                          fontSize: constraints.maxWidth * 0.035,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            SizedBox(height: constraints.maxHeight * 0.005),
                          ],
                        ),
                        SizedBox(height: constraints.maxHeight * 0.03),
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
