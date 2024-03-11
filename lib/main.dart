import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart'as http;
import 'package:fluttertoast/fluttertoast.dart';


void main() {
  runApp(MaterialApp(
    title: 'My App',
    home: MyHomePage(),
     // or TextDirection.rtl depending on your app's reading direction
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _razorpay = Razorpay();
  String apiKey = 'rzp_test_s2L4Y2WSPzWud2';
  String apiSecret = '3ZLThQy11C3HAm3fX7GRrrJC';

  Map<String, dynamic> paymentData = {
    'amount': 50000, // amount in paise (e.g., 1000 paise = Rs. 10)
    'currency': 'INR',
    'receipt': 'order_receipt',
    'payment_capture': '1',
  };

  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Payment Gateway Example',style: TextStyle(color: Colors.white),),
      ),
      body: Card(
        margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
        child: ListTile(
          title: const Text("Special Chum Chum",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 20),),
          subtitle: const Text('Special Bengali Sweet'),
          trailing: ElevatedButton(
            onPressed: () => initiatePayment(),
            child: const Text("Checkout"),
          ),
        ),
      ),

    );
  }



  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    // Here we get razorpay_payment_id razorpay_order_id razorpay_signature
    Fluttertoast.showToast(
        msg: "Payment successful. Transaction ID: ${response.paymentId}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    Fluttertoast.showToast(
        msg: "Payment failed. Reason: ${response.message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    Fluttertoast.showToast(
        msg: "External wallet selected: ${response.walletName}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }



  Future<void> initiatePayment() async {
    String apiUrl = 'https://api.razorpay.com/v1/orders';
    // Make the API request to create an order
    http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
      },
      body: jsonEncode(paymentData),
    );

    if (response.statusCode == 200) {
      // Parse the response to get the order ID
      var responseData = jsonDecode(response.body);
      String orderId = responseData['id'];

      // Set up the payment options
      var options = {
        'key': 'rzp_test_LI687ZNlRMMWdm',
        'amount': paymentData['amount'],
        'name': 'Sweet Corner',
        'order_id': orderId,
        'prefill': {'contact': '1234567890', 'email': 'test@example.com'},
        'external': {
          'wallets': ['paytm'] // optional, for adding support for wallets
        }
      };

      // Open the Razorpay payment form
      _razorpay.open(options);
    } else {
      // Handle error response
      debugPrint('Error creating order: ${response.body}');
    }
  }

}