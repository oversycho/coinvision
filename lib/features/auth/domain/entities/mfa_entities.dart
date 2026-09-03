class MfaEnrollResult {
  final String factorId;
  final String qrCodeSvg; // SVG markup for the QR code
  final String secret; // manual-entry fallback secret
  const MfaEnrollResult({required this.factorId, required this.qrCodeSvg, required this.secret});
}

class MfaFactorInfo {
  final String id;
  final String status; // 'verified' | 'unverified'
  const MfaFactorInfo({required this.id, required this.status});
}
