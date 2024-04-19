class ServiceInformation {
  List<String> logs = [];
  List<int> processIds = [];
  ServiceStatus status = ServiceStatus.stopped;

  ServiceInformation copyWith({
    List<String>? logs,
    List<int>? processIds,
    ServiceStatus? status,
  }) {
    return ServiceInformation()
      ..logs = logs ?? this.logs
      ..processIds = processIds ?? this.processIds
      ..status = status ?? this.status;
  }
}

enum ServiceStatus { stopped, starting, running }
