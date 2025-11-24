const double kDeliveryBaseFee = 12000;
const double kDeliveryIncludedKm = 2;
const double kDeliveryExtraFeePerKm = 2000;
const double kDeliveryMaxFee = 120000;
const double kDeliveryRoundTo = 1000;

/// Computes the delivery fee using the same rules as the backend.
/// [distanceKm] should be the real distance between store and customer.
/// You may override the per-km component for experiments, but it defaults
/// to the shared rate so the apps stay consistent with the server.
double calculateDeliveryFee(
  double distanceKm, {
  double? baseOverride,
  double? includedKmOverride,
  double? extraPerKmOverride,
  double? perKmOverride,
  double? roundToOverride,
}) {
  final distance = distanceKm.isFinite && distanceKm > 0 ? distanceKm : 0;
  final effectiveDistance = distance < 1 ? 1.0 : distance;
  final baseFee = (baseOverride ?? kDeliveryBaseFee).clamp(0, double.infinity);
  final includedKm =
      (includedKmOverride ?? kDeliveryIncludedKm).clamp(0, double.infinity);
  final extraPerKm =
      (extraPerKmOverride ?? perKmOverride ?? kDeliveryExtraFeePerKm)
          .clamp(0, double.infinity);
  final roundTo =
      (roundToOverride ?? kDeliveryRoundTo).clamp(0, double.infinity);

  final extraDistance =
      (effectiveDistance - includedKm).clamp(0, double.infinity);
  final rawFee = baseFee + extraDistance * extraPerKm;
  final cappedFee =
      kDeliveryMaxFee > 0 ? rawFee.clamp(0, kDeliveryMaxFee) : rawFee;

  if (roundTo > 0) {
    return (roundTo * (cappedFee / roundTo).round()).toDouble();
  }
  return cappedFee.roundToDouble();
}
