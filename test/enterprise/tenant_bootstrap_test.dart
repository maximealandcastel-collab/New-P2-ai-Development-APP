import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
Map<String,dynamic> tenant(String id)=>{'schemaVersion':1,'id':id,'name':'Gym $id','timezone':'UTC','primaryColor':'#112233','secondaryColor':'#223344','accentColor':'#334455','logoUrl':'https://example.com/$id.png'};
void main(){
 test('bootstrap supplies branding and facility; switch and logout erase old data',()async{
  String? selected='a';
  final service=EnterpriseService(baseUrl:'https://api.test',token:()=>'session',client:MockClient((request)async{
   if(request.method=='PUT')selected=jsonDecode(request.body)['tenantId'];
   return http.Response(jsonEncode({'success':true,'data':{'context':selected==null?null:{'tenant':tenant(selected!), 'roles':['owner'],'capabilities':['flagship']},'facility':selected==null?null:{'facilityId':'$selected-main','equipment':[selected]},'entitlement':{'state':selected==null?'no_tenant':'active'}}}),200);
  }));
  await service.restore();expect(service.active.value!.tenant.logoUrl,'https://example.com/a.png');expect(service.active.value!.isAdmin,isTrue);
  final pending=service.switchTenant('b');expect(service.active.value,isNull);expect(service.bootstrapData.value,isEmpty);await pending;
  expect(service.active.value!.tenant.id,'b');expect(service.bootstrapData.value['facility']['equipment'],['b']);
  service.clear();expect(service.active.value,isNull);expect(service.bootstrapData.value,isEmpty);
 });
 test('revoked or expired bootstrap never restores gym branding or facility',()async{
  for(final state in ['revoked','expired']){
   final service=EnterpriseService(baseUrl:'https://api.test',token:()=>'session',client:MockClient((_)async=>http.Response(jsonEncode({'success':true,'data':{'context':null,'facility':null,'entitlement':{'state':state}}}),200)));
   await service.restore();expect(service.active.value,isNull);expect(service.bootstrapData.value['entitlement']['state'],state);expect(service.bootstrapData.value['facility'],isNull);
  }
 });
}
