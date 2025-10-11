import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import 'package:google_fonts/google_fonts.dart';

/// Show paywall as a modal bottom sheet
Future<bool?> showPaywallModal(
  BuildContext context, {
  bool isFromLogin = false,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: !isFromLogin,
    enableDrag: !isFromLogin,
    builder: (context) => PaywallModal(isFromLogin: isFromLogin),
  );
}

class PaywallScreen extends StatefulWidget {
  final bool isFromLogin;

  const PaywallScreen({super.key, this.isFromLogin = false});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class PaywallModal extends StatefulWidget {
  final bool isFromLogin;

  const PaywallModal({super.key, this.isFromLogin = false});

  @override
  State<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isPurchasing = false;
  Package? _selectedPackage;
  String? _errorMessage;
  bool _showFeatures = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadOfferings();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_showFeatures) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showFeatures = !_showFeatures;
    });
  }

  Future<void> _loadOfferings() async {
    try {
      debugPrint('🔥 Loading RevenueCat offerings...');

      // Check if SDK is configured
      bool isConfigured = await Purchases.isConfigured;
      debugPrint('📊 Initial SDK configured status: $isConfigured');

      int retries = 0;
      while (retries < 20 && !await Purchases.isConfigured) {
        debugPrint('⏳ Waiting for SDK... retry $retries/20');
        await Future.delayed(Duration(milliseconds: 500));
        retries++;
      }

      isConfigured = await Purchases.isConfigured;
      debugPrint('📊 Final SDK configured status after retries: $isConfigured');

      if (!isConfigured) {
        debugPrint('❌ RevenueCat SDK not configured after $retries retries');
        setState(() {
          _errorMessage =
              'RevenueCat SDK not initialized. Please restart the app.';
          _isLoading = false;
        });
        return;
      }

      debugPrint('✅ RevenueCat SDK is configured, fetching offerings...');
      final offerings = await Purchases.getOfferings();
      debugPrint('📦 Offerings loaded: ${offerings.all.keys}');
      debugPrint('📦 Current offering: ${offerings.current?.identifier}');
      debugPrint(
        '📦 Available packages: ${offerings.current?.availablePackages.length}',
      );

      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        setState(() {
          _selectedPackage = offerings.current!.availablePackages.first;
          _isLoading = false;
        });
        debugPrint('✅ Found package: ${_selectedPackage!.identifier}');
      } else {
        setState(() {
          _errorMessage = 'No subscription plans available at the moment.';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading offerings: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _errorMessage =
            'Unable to load subscription options. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePackage() async {
    if (_selectedPackage == null) return;

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    try {
      debugPrint(
        '🔄 Starting purchase for package: ${_selectedPackage!.identifier}',
      );
      final customerInfo = await Purchases.purchasePackage(_selectedPackage!);

      debugPrint('✅ Purchase completed! Checking entitlements...');
      debugPrint(
        '📦 All entitlements: ${customerInfo.entitlements.all.keys.toList()}',
      );

      final proEntitlement = customerInfo.entitlements.all['Upasthit Pro'];
      debugPrint('🎯 Upasthit Pro entitlement: ${proEntitlement?.identifier}');
      debugPrint('✔️  Is Active: ${proEntitlement?.isActive}');
      debugPrint('📅 Expiration: ${proEntitlement?.expirationDate}');

      if (customerInfo.entitlements.all['Upasthit Pro']?.isActive == true) {
        debugPrint('🎉 PREMIUM UNLOCKED! Updating subscription provider...');
        if (!mounted) return;
        final subscriptionProvider = context.read<SubscriptionProvider>();
        await subscriptionProvider.checkSubscriptionStatus();
        debugPrint(
          '✅ Subscription provider updated. Premium status: ${subscriptionProvider.isPremium}',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Welcome to Upasthit Pro!'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.isFromLogin) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pop(context, true);
        }
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        setState(() {
          _errorMessage = 'Purchase failed: ${e.message}';
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            if (widget.isFromLogin) {
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              Navigator.pop(context, false);
            }
          },
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF67C9F5)),
                    SizedBox(height: 16),
                    Text(
                      'Loading subscription options...',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon and title in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/golden.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 50,
                              ),
                        ),
                        // SizedBox(width: 12),
                        Text(
                          'Get Upasthit Pro',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Our most advanced features, for our\nmost dedicated users.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 30),
                    if (_selectedPackage != null) _buildFlipCard(),
                    SizedBox(height: 20),
                    if (_selectedPackage != null) _buildPricingCard(),
                    SizedBox(height: 20),
                    if (_errorMessage != null) _buildErrorMessage(),
                    if (_errorMessage != null) SizedBox(height: 16),
                    if (_selectedPackage != null) _buildContinueButton(),
                    // SizedBox(height: 16),
                    // _buildRestoreButton(),
                    SizedBox(height: 24),
                    _buildTerms(),
                  ],
                ),
              ),
    );
  }

  Widget _buildFlipCard() {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * 3.14159; // π radians
        final isFront = angle < 1.5708; // π/2 radians

        return GestureDetector(
          onTap: _toggleCard,
          child: Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
            child:
                isFront
                    ? _buildSamosaCard()
                    : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildFeaturesCard(),
                    ),
          ),
        );
      },
    );
  }

  Widget _buildSamosaCard() {
    return Container(
      width: double.infinity,
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color.fromARGB(255, 255, 255, 255), width: 3),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Samosa image - full size with white background
                Container(
                  width: 200,
                  height: 200,
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/samosaa.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 16),
                // Minimal white box with essential text
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '₹12/month',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6F00),
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Less than 1 samosa',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Tap to see features hint
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFFFF9800), width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Color(0xFFFF6F00), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tap to see features',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6F00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    final features = [
      {
        'icon': Icons.calendar_today,
        'title': 'Date-wise attendance',
        'subtitle': 'Track attendance history day by day',
      },
      {
        'icon': Icons.auto_stories,
        'title': 'Subject cards',
        'subtitle': 'Visual breakdown of each subject',
      },
      {
        'icon': Icons.calculate,
        'title': 'Smart bunk calculator',
        'subtitle': 'Know how many classes you can miss',
      },
      {
        'icon': Icons.psychology,
        'title': 'AI bunk predictor',
        'subtitle': 'Predict attendance after bunks',
      },
      {
        'icon': Icons.insights,
        'title': 'Analytics & insights',
        'subtitle': 'Charts and actionable stats',
      },
    ];

    return Container(
      width: double.infinity,
      height: 420,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFF0D47A1), width: 3),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1565C0).withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Premium Features',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Features list
                Expanded(
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: features.length,
                    itemBuilder: (context, index) {
                      final feature = features[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                feature['icon'] as IconData,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    feature['title'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    feature['subtitle'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Tap to flip back hint
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flip, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Tap to flip back',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    final product = _selectedPackage!.storeProduct;
    final price = product.priceString;

    // Check if product has introductory price (free trial)
    // Note: You'll need to configure this in RevenueCat/App Store Connect
    final hasFreeTrial = product.introductoryPrice != null;

    // 🐛 DEBUG: Print trial information
    debugPrint('🔍 === FREE TRIAL DEBUG ===');
    debugPrint('Product ID: ${product.identifier}');
    debugPrint('Has Introductory Price: $hasFreeTrial');
    debugPrint('Introductory Price: ${product.introductoryPrice}');
    if (hasFreeTrial) {
      debugPrint('Trial Price: ${product.introductoryPrice?.price}');
      debugPrint('Trial Period: ${product.introductoryPrice?.period}');
      debugPrint('Trial Cycles: ${product.introductoryPrice?.cycles}');
    }
    debugPrint('========================');

    return Column(
      children: [
        // Fun Value Comparison Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFFF9800), width: 2),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF9800).withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text('🍴', style: TextStyle(fontSize: 28)),
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
        SizedBox(height: 10),
        // Main Pricing Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasFreeTrial) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.card_giftcard,
                                  size: 14,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '21 DAYS FREE TRIAL',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                        if (hasFreeTrial) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.card_giftcard,
                                  size: 14,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '21 DAYS FREE TRIAL',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                        Text(
                          'Monthly Subscription',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        if (hasFreeTrial) ...[
                          Text(
                            'First 21 days FREE',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Then $price/month',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Cancel anytime during trial',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ] else ...[
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'Billed as $price/mo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final product = _selectedPackage!.storeProduct;
    final hasFreeTrial = product.introductoryPrice != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isPurchasing ? null : _purchasePackage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(1, 125, 202, 1).withOpacity(1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isPurchasing
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  hasFreeTrial ? 'Start 7-Day Free Trial' : 'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  // Widget _buildRestoreButton() {
  //   return TextButton(
  //     onPressed: _isPurchasing ? null : _restorePurchases,
  //     child: Text(
  //       'Restore Purchases',
  //       style: GoogleFonts.poppins(
  //         color: Color(0xFF67C9F5),
  //         fontSize: 15,
  //         fontWeight: FontWeight.w500,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTerms() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.',
        style: TextStyle(fontSize: 11, color: Colors.black38, height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Modal version of the paywall
class _PaywallModalState extends State<PaywallModal>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isPurchasing = false;
  Package? _selectedPackage;
  String? _errorMessage;
  bool _showFeatures = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadOfferings();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_showFeatures) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showFeatures = !_showFeatures;
    });
  }

  Future<void> _loadOfferings() async {
    try {
      debugPrint('🔥 Loading RevenueCat offerings...');

      bool isConfigured = await Purchases.isConfigured;
      debugPrint('📊 Initial SDK configured status: $isConfigured');

      int retries = 0;
      while (retries < 20 && !await Purchases.isConfigured) {
        debugPrint('⏳ Waiting for SDK... retry $retries/20');
        await Future.delayed(Duration(milliseconds: 500));
        retries++;
      }

      isConfigured = await Purchases.isConfigured;
      debugPrint('📊 Final SDK configured status after retries: $isConfigured');

      if (!isConfigured) {
        debugPrint('❌ RevenueCat SDK not configured after $retries retries');
        setState(() {
          _errorMessage =
              'RevenueCat SDK not initialized. Please restart the app.';
          _isLoading = false;
        });
        return;
      }

      debugPrint('✅ RevenueCat SDK is configured, fetching offerings...');
      final offerings = await Purchases.getOfferings();
      debugPrint('📦 Offerings loaded: ${offerings.all.keys}');
      debugPrint('📦 Current offering: ${offerings.current?.identifier}');
      debugPrint(
        '📦 Available packages: ${offerings.current?.availablePackages.length}',
      );

      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        setState(() {
          _selectedPackage = offerings.current!.availablePackages.first;
          _isLoading = false;
        });
        debugPrint('✅ Found package: ${_selectedPackage!.identifier}');
      } else {
        setState(() {
          _errorMessage = 'No subscription plans available at the moment.';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading offerings: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _errorMessage =
            'Unable to load subscription options. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePackage() async {
    if (_selectedPackage == null) return;

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    try {
      debugPrint(
        '🔄 Starting purchase for package: ${_selectedPackage!.identifier}',
      );
      final customerInfo = await Purchases.purchasePackage(_selectedPackage!);

      debugPrint('✅ Purchase completed! Checking entitlements...');
      debugPrint(
        '📦 All entitlements: ${customerInfo.entitlements.all.keys.toList()}',
      );

      final proEntitlement = customerInfo.entitlements.all['Upasthit Pro'];
      debugPrint('🎯 Upasthit Pro entitlement: ${proEntitlement?.identifier}');
      debugPrint('✔️  Is Active: ${proEntitlement?.isActive}');
      debugPrint('📅 Expiration: ${proEntitlement?.expirationDate}');

      if (customerInfo.entitlements.all['Upasthit Pro']?.isActive == true) {
        debugPrint('🎉 PREMIUM UNLOCKED! Updating subscription provider...');
        if (!mounted) return;
        final subscriptionProvider = context.read<SubscriptionProvider>();
        await subscriptionProvider.checkSubscriptionStatus();
        debugPrint(
          '✅ Subscription provider updated. Premium status: ${subscriptionProvider.isPremium}',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Welcome to Upasthit Pro!'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.isFromLogin) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pop(context, true);
        }
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        setState(() {
          _errorMessage = 'Purchase failed: ${e.message}';
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

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
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              if (!widget.isFromLogin)
                Container(
                  margin: EdgeInsets.only(top: 8), // reduced from 12 to 8
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 8,
                    top: 4,
                  ), // reduced from 8 to 4
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.black54),
                    onPressed: () {
                      if (widget.isFromLogin) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        Navigator.pop(context, false);
                      }
                    },
                  ),
                ),
              ),
              // Content
              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF67C9F5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading subscription options...',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 0, // removed top padding
                          ),
                          children: [
                            // Removed SizedBox(height: 8),
                            // Icon and title in a row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/golden.png',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Get Upasthit Pro',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Our most advanced features, for our\nmost dedicated users.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 28),
                            if (_selectedPackage != null) _buildFlipCard(),
                            SizedBox(height: 20),
                            if (_selectedPackage != null) _buildPricingCard(),
                            SizedBox(height: 20),
                            if (_errorMessage != null) _buildErrorMessage(),
                            if (_errorMessage != null) SizedBox(height: 16),
                            if (_selectedPackage != null)
                              _buildContinueButton(),
                            SizedBox(height: 20),
                            _buildTerms(),
                            SizedBox(height: 24),
                          ],
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFlipCard() {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * 3.14159; // π radians
        final isFront = angle < 1.5708; // π/2 radians

        return GestureDetector(
          onTap: _toggleCard,
          child: Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
            child:
                isFront
                    ? _buildSamosaCard()
                    : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildFeaturesCard(),
                    ),
          ),
        );
      },
    );
  }

  Widget _buildSamosaCard() {
    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black54, width: 3),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
            blurRadius: 16,
            offset: Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Samosa image - full size with white background
                Image.asset('assets/images/samosaa.png'),

                // Price comparison
                Column(
                  children: [
                    Text(
                      'Just at the cost of a samosa!',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '(helps us maintain the app & servers)',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                    ),
                  ],
                ),

                // Minimal white box with essential text
                SizedBox(height: 10),
                // Tap to see features hint
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Color(0xFFFF6F00), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Tap to see features',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6F00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    final features = [
      {
        'icon': Icons.calendar_today,
        'title': 'Date-wise attendance',
        'subtitle': 'Track history day by day',
      },
      {
        'icon': Icons.auto_stories,
        'title': 'Subject cards',
        'subtitle': 'Visual breakdown',
      },
      {
        'icon': Icons.calculate,
        'title': 'Smart bunk calculator',
        'subtitle': 'Know safe bunks',
      },
      {
        'icon': Icons.psychology,
        'title': 'AI bunk predictor',
        'subtitle': 'Predict attendance',
      },
      {
        'icon': Icons.insights,
        'title': 'Analytics & insights',
        'subtitle': 'Charts and stats',
      },
    ];

    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF0D47A1), width: 3),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 24),
                SizedBox(width: 10),
                Text(
                  'Premium Features',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            // Features list
            Expanded(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feature['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                feature['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Tap to flip back hint
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flip, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Tap to flip back',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildPricingCard() {
    final product = _selectedPackage!.storeProduct;
    final price = product.priceString;

    // Check if product has introductory price (free trial)
    final hasFreeTrial = product.introductoryPrice != null;

    // 🐛 DEBUG: Print trial information
    debugPrint('🔍 === FREE TRIAL DEBUG (Modal) ===');
    debugPrint('Product ID: ${product.identifier}');
    debugPrint('Has Introductory Price: $hasFreeTrial');
    debugPrint('Introductory Price: ${product.introductoryPrice}');
    if (hasFreeTrial) {
      debugPrint('Trial Price: ${product.introductoryPrice?.price}');
      debugPrint('Trial Period: ${product.introductoryPrice?.period}');
      debugPrint('Trial Cycles: ${product.introductoryPrice?.cycles}');
    }
    debugPrint('================================');

    return Column(
      children: [
        // Fun Value Comparison Card
        SizedBox(height: 12),
        // Main Pricing Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasFreeTrial) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.card_giftcard,
                                  size: 12,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  '7 DAYS FREE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                        Text(
                          'Monthly Subscription',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (hasFreeTrial) ...[
                          Text(
                            'First 21 days FREE',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Then $price/month',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Cancel anytime',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                        ] else ...[
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'Billed as $price/mo',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final product = _selectedPackage!.storeProduct;
    final hasFreeTrial = product.introductoryPrice != null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isPurchasing ? null : _purchasePackage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(1, 125, 202, 1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isPurchasing
                ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  hasFreeTrial ? 'Start 7-Day Free Trial' : 'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildTerms() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.',
        style: TextStyle(fontSize: 10, color: Colors.black38, height: 1.4),
        textAlign: TextAlign.center,
      ),
    );
  }
}
