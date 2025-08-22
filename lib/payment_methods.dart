import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentMethodScreen extends StatefulWidget {
  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  double walletBalance = 150.00;
  List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: '1',
      type: PaymentMethodType.card,
      name: 'Visa ending in 1234',
      lastFour: '1234',
      isDefault: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF7ED), // orange-50
              Color(0xFFFEF3C7), // amber-50
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFB923C), // orange-400
                      Color(0xFFFBBF24), // amber-400
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Payment Methods',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsets.only(left: 40),
                      child: Text(
                        'Manage your payment options',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFFED7AA), // orange-100
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Digital Wallet Card
                      _buildWalletCard(),
                      SizedBox(height: 24),
                      // Payment Methods List
                      _buildPaymentMethodsList(),
                      SizedBox(height: 24),
                      // Add Payment Method Button
                      _buildAddPaymentButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: Color(0xFFFB923C),
            width: 4,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFB923C),
                          Color(0xFFFBBF24),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digital Wallet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'Your app balance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EGP ${walletBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFED7AA), // orange-100
                  Color(0xFFFEF3C7), // amber-100
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Use your wallet for quick and secure payments within the app',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF92400E), // orange-800
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 16),
          ...paymentMethods.map((method) => _buildPaymentMethodItem(method)).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFFED7AA), // orange-100
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPaymentMethodIcon(method.type),
              color: Color(0xFFDC2626),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (method.isDefault)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFFFED7AA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPaymentButton() {
    return Container(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _showAddPaymentMethodModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFB923C),
                Color(0xFFFBBF24),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddPaymentMethodModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPaymentMethodModal(
        onPaymentMethodAdded: (PaymentMethod method) {
          setState(() {
            paymentMethods.add(method);
          });
        },
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.fawry:
        return Icons.payment;
      case PaymentMethodType.cash:
        return Icons.money;
    }
  }
}

class AddPaymentMethodModal extends StatefulWidget {
  final Function(PaymentMethod) onPaymentMethodAdded;

  const AddPaymentMethodModal({Key? key, required this.onPaymentMethodAdded}) : super(key: key);

  @override
  _AddPaymentMethodModalState createState() => _AddPaymentMethodModalState();
}

class _AddPaymentMethodModalState extends State<AddPaymentMethodModal> {
  PaymentMethodType? selectedType;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _fawryNumberController = TextEditingController();
  final _cashAmountController = TextEditingController();

  bool _obscureCardNumber = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Payment Method',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: selectedType == null ? _buildPaymentTypeSelection() : _buildPaymentForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelection() {
    return Column(
      children: [
        _buildPaymentTypeOption(
          PaymentMethodType.card,
          Icons.credit_card,
          'Credit/Debit Card',
          'Visa, Mastercard, etc.',
        ),
        SizedBox(height: 16),
        _buildPaymentTypeOption(
          PaymentMethodType.fawry,
          Icons.payment,
          'Fawry',
          'Pay with Fawry',
        ),
        SizedBox(height: 16),
        _buildPaymentTypeOption(
          PaymentMethodType.cash,
          Icons.money,
          'Cash',
          'Pay on delivery',
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPaymentTypeOption(PaymentMethodType type, IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Back button
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedType = null;
                  });
                },
                icon: Icon(Icons.arrow_back, color: Color(0xFFDC2626)),
                label: Text(
                  'Back to payment methods',
                  style: TextStyle(color: Color(0xFFDC2626)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Form fields based on selected type
          if (selectedType == PaymentMethodType.card) ..._buildCardForm(),
          if (selectedType == PaymentMethodType.fawry) ..._buildFawryForm(),
          if (selectedType == PaymentMethodType.cash) ..._buildCashForm(),
          SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _savePaymentMethod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFB923C),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildCardForm() {
    return [
      TextFormField(
        controller: _cardNumberController,
        decoration: InputDecoration(
          labelText: 'Card Number',
          hintText: '1234 5678 9012 3456',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFFB923C), width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(_obscureCardNumber ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _obscureCardNumber = !_obscureCardNumber;
              });
            },
          ),
        ),
        obscureText: _obscureCardNumber,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CardNumberFormatter(),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter card number';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _expiryDateController,
              decoration: InputDecoration(
                labelText: 'Expiry Date',
                hintText: 'MM/YY',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFFB923C), width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ExpiryDateFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _cvvController,
              decoration: InputDecoration(
                labelText: 'CVV',
                hintText: '123',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFFB923C), width: 2),
                ),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _cardholderNameController,
        decoration: InputDecoration(
          labelText: 'Cardholder Name',
          hintText: 'John Doe',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFFB923C), width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter cardholder name';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildFawryForm() {
    return [
      TextFormField(
        controller: _fawryNumberController,
        decoration: InputDecoration(
          labelText: 'Fawry Number',
          hintText: 'Enter your Fawry number',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFFB923C), width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter Fawry number';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'You can pay using Fawry at any nearby Fawry outlet or through the Fawry mobile app.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF92400E),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildCashForm() {
    return [
      TextFormField(
        controller: _cashAmountController,
        decoration: InputDecoration(
          labelText: 'Cash Amount',
          hintText: '0.00',
          prefixText: 'EGP ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFFB923C), width: 2),
          ),
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter cash amount';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Cash payment will be collected upon delivery or at pickup location.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF92400E),
          ),
        ),
      ),
    ];
  }

  void _savePaymentMethod() {
    if (_formKey.currentState!.validate()) {
      PaymentMethod newMethod;

      switch (selectedType) {
        case PaymentMethodType.card:
          newMethod = PaymentMethod(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: PaymentMethodType.card,
            name: "${_cardholderNameController.text}'s Card ending in ${_cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4)}",
            lastFour: _cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4),
            isDefault: false,
          );
          break;
        case PaymentMethodType.fawry:
          newMethod = PaymentMethod(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: PaymentMethodType.fawry,
            name: "Fawry ${_fawryNumberController.text}",
            lastFour: _fawryNumberController.text.length >= 4 ? _fawryNumberController.text.substring(_fawryNumberController.text.length - 4) : _fawryNumberController.text,
            isDefault: false,
          );
          break;
        case PaymentMethodType.cash:
          newMethod = PaymentMethod(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: PaymentMethodType.cash,
            name: "Cash Payment EGP ${_cashAmountController.text}",
            lastFour: '',
            isDefault: false,
          );
          break;
        default:
          return;
      }

      widget.onPaymentMethodAdded(newMethod);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    _fawryNumberController.dispose();
    _cashAmountController.dispose();
    super.dispose();
  }
}

// Data Models
enum PaymentMethodType { card, fawry, cash }

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String name;
  final String lastFour;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.lastFour,
    required this.isDefault,
  });
}

// Input Formatters
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}