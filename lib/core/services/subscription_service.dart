import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String premiumMonthlyId = 'blinkr_premium_monthly';
  static const double premiumPrice = 2.99;

  Future<void> initialize() async {
    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw Exception('In-app purchases not available');
    }

    // Listen to purchase updates
    _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        // Handle error
      },
    );
  }

  Future<List<ProductDetails>> getProducts() async {
    final response = await _inAppPurchase.queryProductDetails({premiumMonthlyId});
    
    if (response.notFoundIDs.isNotEmpty) {
      throw Exception('Products not found');
    }

    return response.productDetails;
  }

  Future<void> purchasePremium(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Verify purchase with backend
        await _verifyPurchase(purchase);
        
        // Complete purchase
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        // Handle error
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Update user subscription in database
    await _supabase.from('user_subscriptions').upsert({
      'user_id': user.id,
      'subscription_type': 'premium',
      'status': 'active',
      'started_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'purchase_token': purchase.purchaseID,
    });
  }

  Future<bool> isPremiumUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final response = await _supabase
        .from('user_subscriptions')
        .select()
        .eq('user_id', user.id)
        .eq('status', 'active')
        .maybeSingle();

    if (response == null) return false;

    final expiresAt = DateTime.parse(response['expires_at'] as String);
    return expiresAt.isAfter(DateTime.now());
  }

  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }
}
