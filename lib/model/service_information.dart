class ServiceInformation {
  bool active = false;
  List<String> logs = [];
  List<int> processIds = [];

  ServiceInformation copyWith(
      {bool? active, List<String>? logs, List<int>? processIds}) {
    return ServiceInformation()
      ..active = active ?? this.active
      ..logs = logs ?? this.logs
      ..processIds = processIds ?? this.processIds;
  }
}
