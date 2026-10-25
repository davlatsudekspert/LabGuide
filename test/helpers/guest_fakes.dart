import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/guest_entitlements.dart';
import 'package:labguide/core/entitlements/purchase_adapter.dart';

import 'billing_fakes.dart';

/// Mehmon xaridini qo'llaydigan soxta server.
class FakeGuestSource extends FakeEntitlementSource
    implements GuestBillingSource {
  FakeGuestSource({super.user, super.platform, this.policy});

  GuestPolicy? policy;
  final guestVerifies = <(List<PurchaseProof>, String, bool)>[];
  final refreshes = <(String, List<String>)>[];
  final links = <(String, List<String>)>[];
  EntitlementSnapshot? guestReply;
  EntitlementSnapshot? linkReply;

  @override
  GuestPolicy? get guestPolicy => policy;

  @override
  Future<EntitlementSnapshot> guestVerify(
    List<PurchaseProof> proofs, {
    required String deviceId,
    required bool restore,
  }) async {
    guestVerifies.add((proofs, deviceId, restore));
    return guestReply!;
  }

  @override
  Future<EntitlementSnapshot> guestRefresh({
    required String deviceId,
    required List<String> tokens,
  }) async {
    refreshes.add((deviceId, tokens));
    return guestReply!;
  }

  @override
  Future<EntitlementSnapshot> guestLink({
    required String deviceId,
    required List<String> tokens,
  }) async {
    links.add((deviceId, tokens));
    return linkReply!;
  }
}

