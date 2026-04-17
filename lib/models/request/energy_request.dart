class EnergyMeterRequest {
  final String fromDate;
  final String toDate;

  EnergyMeterRequest({
    required this.fromDate,
    required this.toDate,
  });


  Map<String, dynamic> toJson() {
    return {
      'fromDate': fromDate,
      'toDate': toDate,
    };
  }

  @override
  String toString() => 'EnergyMeterRequest(fromDate: $fromDate, toDate: $toDate)';
}