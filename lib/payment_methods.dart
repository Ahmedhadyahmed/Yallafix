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
              Color(0xFFFFF9F5),
              Color(0xFFFAF5F0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFFB923C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Color(0xFFFB923C),
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Methods',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage your payment options',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      _buildWalletCard(),
                      SizedBox(height: 28),
                      _buildPaymentMethodsList(),
                      SizedBox(height: 28),
                      _buildAddPaymentButton(),
                      SizedBox(height: 16),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFB923C),
            Color(0xFFFBBF24),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFB923C).withOpacity(0.25),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digital Wallet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your app balance',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'EGP ${walletBalance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Text(
              'Quick and secure payments within the app',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved Payment Methods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 14),
        ...paymentMethods.asMap().entries.map((entry) {
          int index = entry.key;
          PaymentMethod method = entry.value;
          return Column(
            children: [
              _buildPaymentMethodItem(method),
              if (index < paymentMethods.length - 1)
                SizedBox(height: 12),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFFED7AA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPaymentMethodIcon(method.type),
              color: Color(0xFFFB923C),
              size: 22,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (method.isDefault) ...[
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFEF3C7),
                          Color(0xFFFED7AA),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFED7AA).withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Color(0xFFFB923C),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
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
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFB923C),
            Color(0xFFFBBF24),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFB923C).withOpacity(0.3),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddPaymentMethodModal,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Add Payment Method',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
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
        SizedBox(height: 12),
        _buildPaymentTypeOption(
          PaymentMethodType.fawry,
          Icons.payment,
          'Fawry',
          'Pay with Fawry',
        ),
        SizedBox(height: 12),
        _buildPaymentTypeOption(
          PaymentMethodType.cash,
          Icons.money,
          'Cash',
          'Pay on delivery',
        ),
        SizedBox(height: 20),
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
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFFED7AA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Color(0xFFFB923C), size: 24),
            ),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
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
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedType = null;
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Color(0xFFFB923C), size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFFFB923C),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (selectedType == PaymentMethodType.card) ..._buildCardForm(),
          if (selectedType == PaymentMethodType.fawry) ..._buildFawryForm(),
          if (selectedType == PaymentMethodType.cash) ..._buildCashForm(),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFB923C),
                        Color(0xFFFBBF24),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _savePaymentMethod,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
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
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE5E7EB)),
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
                labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
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
                labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
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
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE5E7EB)),
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
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE5E7EB)),
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
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFFED7AA)),
        ),
        child: Text(
          'You can pay using Fawry at any nearby Fawry outlet or through the Fawry mobile app.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF92400E),
            fontWeight: FontWeight.w500,
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
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE5E7EB)),
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
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFFED7AA)),
        ),
        child: Text(
          'Cash payment will be collected upon delivery or at pickup location.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF92400E),
            fontWeight: FontWeight.w500,
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