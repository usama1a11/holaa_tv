import 'package:flutter/material.dart';
import 'package:holaa_tv/web_view_screen.dart';
import 'package:upi_pay/upi_pay.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final UpiPay _upiPay = UpiPay();
  String? _selectedAmount;
  bool _isLoading = false;

  // Plan data
  final List<Map<String, dynamic>> _plans = [
    {
      'currentPrice': '42',
      'originalPrice': '70',
      'discount': '40% off',
      'duration': '1 week',
      'durationDisplay': 'week',
    },
    {
      'currentPrice': '149',
      'originalPrice': '300',
      'discount': '50.33% off',
      'duration': '1 month',
      'durationDisplay': 'month',
    },
    {
      'currentPrice': '799',
      'originalPrice': '2000',
      'discount': '60.05% off',
      'duration': '1 year',
      'durationDisplay': 'year',
    },
  ];

  Future<void> _startPayment(BuildContext context) async {
    if (_selectedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a plan first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apps = await _upiPay.getInstalledUpiApplications(
        statusType: UpiApplicationDiscoveryAppStatusType.all,
      );

      if (apps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No UPI apps found!')),
        );
        return;
      }

      final transactionRef = DateTime.now().millisecondsSinceEpoch.toString();
      final app = apps.first;

      final txnResponse = await _upiPay.initiateTransaction(
        amount: _selectedAmount!,
        app: app.upiApplication,
        receiverName: 'Your Company Name',
        receiverUpiAddress: 'yourupi@bank',
        transactionRef: transactionRef,
        transactionNote: 'Subscription Payment',
      );

      if (txnResponse.status == UpiTransactionStatus.success) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>WebViewScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Failed: ${txnResponse.status}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                decoration: const BoxDecoration(color: Colors.black),
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
                        'Subscribe Now',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.01),
                      Text(
                        '& Start Streaming',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.06,
                          color: Colors.amberAccent,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.03),

                      // Features Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text('Key Features',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold, color: Colors.black)),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Icon(Icons.circle, color: Colors.black, size: 8),
                                ),
                                SizedBox(width: 8),
                                Expanded( // Takes remaining space and allows text to wrap
                                  child: Text(
                                    'Movies, Shows, Web series, documentaries, short movies etc',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis, // Handles overflow if text exceeds 2 lines
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.circle, color: Colors.black, size: 8),
                                SizedBox(width: 8),
                                Text('Ad-free movies & shows'),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.circle, color: Colors.black, size: 8),
                                SizedBox(width: 8),
                                Text('Connect up to 5 devices'),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Icon(Icons.circle, color: Colors.black, size: 8),
                                ),
                                SizedBox(width: 8),
                                Expanded( // Takes remaining space and allows text to wrap
                                  child: Text(
                                    'Get a bright & full HD resolution of up to 1080',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis, // Handles overflow if text exceeds 2 lines
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.04),

                      // Plans with Radio Buttons
                      Column(
                        children: _plans.map((plan) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: constraints.maxHeight * 0.02),
                            child: _buildPlanCard(
                              constraints,
                              plan['currentPrice'],
                              plan['originalPrice'],
                              plan['discount'],
                              plan['durationDisplay'],
                              plan['duration'],
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.02),

                      // Payment Button
                      Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(5),
                      ),
                     child: Row(
                      children: [
                      Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage("images/phonepe2.jpg")),
                      ),
                      ),
                    const SizedBox(width: 12),
                   const Expanded(
child: Row(
  children: [
    Text(
    'Pay Via\nPhonepe',
    style: TextStyle(fontWeight: FontWeight.bold),
    ),
    Expanded(
      child: Icon(
        Icons.arrow_drop_down_outlined,
      ),
    ),
  ],
),
),
const SizedBox(width: 8),
ElevatedButton(
onPressed: (){
  _startPayment(context);
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.amber,
padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(5),
),
),
child: const Text('PROCEED',style: TextStyle(color: Colors.black),),
),
],
),
),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildPlanCard(
      BoxConstraints constraints,
      String currentPrice,
      String originalPrice,
      String discount,
      String durationDisplay,
      String duration,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = currentPrice;
        });
        // Show notification for selected plan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected ₹$currentPrice Plan'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.amber,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedAmount == currentPrice ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Radio Button
            Radio<String>(
              value: currentPrice,
              groupValue: _selectedAmount,
              onChanged: (value) {
                setState(() {
                  _selectedAmount = value;
                });
                // Show notification when radio button is selected
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected ₹$currentPrice Plan'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.black,
                  ),
                );
              },
              activeColor: Colors.black,
            ),

            // Plan Duration
            Center(
              child: Text(
                durationDisplay,
                style: TextStyle(
                  fontSize: constraints.maxWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(width: 20),

            // Plan Details
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "₹$currentPrice",
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 7.0, left: 5.0),
                        child: Text(
                          '₹$originalPrice',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.035,
                            color: Colors.black,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Discount Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 17,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                        topRight: Radius.circular(13),
                        bottomRight: Radius.circular(13),
                      ),
                    ),
                    child: Text(
                      discount,
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.035,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
