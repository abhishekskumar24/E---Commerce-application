
import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String customerName;
  final double orderTotal;

  const OrderConfirmationScreen({
    super.key,
    required this.customerName,
    required this.orderTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Thank you, $customerName!',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text('Your order total is'),
              const SizedBox(height: 5),
              Text(
                '\$${orderTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}