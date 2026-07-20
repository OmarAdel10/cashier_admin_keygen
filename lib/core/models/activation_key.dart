class ActivationKey {
  final String deviceId;
  final String signatureBase64;

  const ActivationKey({
    required this.deviceId,
    required this.signatureBase64,
  });

  String get formatted => 'Device ID: $deviceId\nActivation Key: $signatureBase64';
}
