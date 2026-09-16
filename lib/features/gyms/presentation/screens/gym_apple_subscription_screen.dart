import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import '../../data/services/enterprise_service.dart';

const gymAppleProductIds = {'p2p_gym_starter_monthly', 'p2p_gym_pro_monthly'};
class GymAppleSubscriptionScreen extends StatefulWidget {
  final String applicationId;
  const GymAppleSubscriptionScreen({super.key, required this.applicationId});
  @override
  State<GymAppleSubscriptionScreen> createState()=>_GymAppleSubscriptionState();
}
class _GymAppleSubscriptionState extends State<GymAppleSubscriptionScreen> {
  StreamSubscription<List<PurchaseDetails>>? subscription;
  ProductDetails? product;
  String? accountToken;
  String message='Loading App Store subscription…';
  bool busy=true;
  final verifying=<String>{};
  @override
  void initState(){super.initState();load();}
  void status(String text,{bool loading=false}){if(mounted)setState((){message=text;busy=loading;});}
  Future<void> load() async {
    status('Loading App Store subscription…',loading:true);
    try {
      if(kIsWeb||defaultTargetPlatform!=TargetPlatform.iOS)throw const EnterpriseException('Gym subscriptions are available through the iOS App Store.');
      if(!await InAppPurchase.instance.isAvailable())throw const EnterpriseException('The App Store is currently unavailable.');
      final prepared=await EnterpriseService.instance.request('/enterprise/gym-applications/${widget.applicationId}/apple/prepare',method:'POST');
      final id=prepared['productId'] as String;
      if(!gymAppleProductIds.contains(id))throw const EnterpriseException('Subscription configuration is unavailable.');
      accountToken=prepared['appAccountToken'] as String;
      subscription??=InAppPurchase.instance.purchaseStream.listen(onPurchases,onError:(_)=>status('Purchase connection interrupted. Retry or restore purchases.'));
      final details=await InAppPurchase.instance.queryProductDetails({id});
      if(details.error!=null||details.productDetails.isEmpty)throw const EnterpriseException('This gym subscription is not available in the App Store yet.');
      product=details.productDetails.singleWhere((p)=>p.id==id);
      status('Monthly gym software subscription. Ownership review and approval are required for activation.');
    }catch(e){status(e is EnterpriseException?e.message:'Could not load the Apple subscription. Please retry.');}
  }
  Future<void> buy() async {
    if(busy||product==null||accountToken==null)return;
    status('Waiting for Apple purchase confirmation…',loading:true);
    try{
      final started=await InAppPurchase.instance.buyNonConsumable(purchaseParam:PurchaseParam(productDetails:product!,applicationUserName:accountToken));
      if(!started)status('Apple did not start the purchase. Try again.');
    }catch(_){status('Purchase could not start. You can retry.');}
  }
  Future<void> restore() async {
    if(busy||accountToken==null)return;
    status('Checking previous Apple purchases…',loading:true);
    try{await InAppPurchase.instance.restorePurchases(applicationUserName:accountToken);status('Restore requested. Any matching subscription will be verified.');}
    catch(_){status('Restore failed. Please retry.');}
  }
  Future<void> onPurchases(List<PurchaseDetails> purchases) async {
    for(final purchase in purchases){
      if(!gymAppleProductIds.contains(purchase.productID))continue;
      if(purchase.status==PurchaseStatus.pending){status('Awaiting Apple approval…',loading:true);continue;}
      if(purchase.status==PurchaseStatus.canceled){status('Purchase canceled.');continue;}
      if(purchase.status==PurchaseStatus.error){status(purchase.error?.message??'Apple purchase failed.');continue;}
      final id=purchase.purchaseID;
      if(id==null||!verifying.add(id))continue;
      try{
        final result=await EnterpriseService.instance.request('/enterprise/gym-applications/${widget.applicationId}/apple/verify',method:'POST',body:{'purchaseId':id,'verificationData':purchase.verificationData.serverVerificationData});
        if(result['verified']!=true)throw const EnterpriseException('Apple verification is incomplete.');
        if(purchase.pendingCompletePurchase)await InAppPurchase.instance.completePurchase(purchase);
        status('Apple subscription verified. Gym activation still requires approval.');
      }catch(e){status(e is EnterpriseException?e.message:'Verification is pending. Use Restore purchases to retry; do not buy again.');}
      finally{verifying.remove(id);}
    }
  }
  @override
  void dispose(){subscription?.cancel();super.dispose();}
  @override
  Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Gym subscription')),body:ListView(padding:const EdgeInsets.all(24),children:[
    if(product!=null)...[Text(product!.title,style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:12),Text('${product!.price} per month')],
    const SizedBox(height:20),Text(message),const SizedBox(height:20),
    if(busy)const LinearProgressIndicator(),
    FilledButton(onPressed:busy||product==null?null:buy,child:const Text('Subscribe with Apple')),
    TextButton(onPressed:busy||accountToken==null?null:restore,child:const Text('Restore purchases')),
    if(product==null)TextButton(onPressed:busy?null:load,child:const Text('Retry')),
    const Text('Payment is charged to your Apple Account. The subscription renews monthly unless canceled at least 24 hours before the period ends. Manage or cancel in your Apple Account subscription settings.'),
    for(final item in const {'terms':'Terms of Use','privacy':'Privacy Policy'}.entries)
      TextButton(onPressed:()=>Get.toNamed(AppRoute.privacyPolicyScreen,arguments:{'title':item.value,'key':item.key,'consent':false}),child:Text(item.value)),
  ]));
}
