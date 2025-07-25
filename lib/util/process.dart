import 'dart:io';

class ProcessUtil {
  /// Retrieves the process IDs of the processes with the specified [name].
  ///
  /// This function runs the 'tasklist' command to list all running processes, and
  /// then filters the output to find the processes with the specified [name]. It
  /// returns a [Future] that completes with a list of integers representing the
  /// process IDs of the matching processes. If no processes with the specified
  /// [name] are found, an empty list is returned.
  ///
  /// The [name] parameter is a string representing the name of the processes to
  /// search for. It can be specified with or without a file path. If a file path
  /// is provided, the process names will be matched against the base name of
  /// the file path.
  Future<List<int>> getProcessIds(String name) async {
    final result = await Process.run('tasklist', [], runInShell: true);
    final lines = result.stdout.toString().split('\n');
    final serviceLines =
        lines.where((line) {
          return line.contains(name);
        }).toList();
    final List<int> processIds = [];
    if (serviceLines.isEmpty) return processIds;
    for (final line in serviceLines) {
      final formattedLine = line.replaceAll(RegExp(r'\s+'), ' ');
      final patterns = formattedLine.split(' ');
      processIds.add(int.parse(patterns[1]));
    }
    return processIds;
  }

  /// Retrieves the names of all running processes.
  ///
  /// This function runs the 'tasklist' command to list all running processes, and
  /// then extracts the names of the processes. It returns a [Future] that completes
  /// with a list of strings representing the names of the processes. If no processes
  /// are found, an empty list is returned.
  Future<List<String>> getProcessNames() async {
    final result = await Process.run('tasklist', [], runInShell: true);
    final lines = result.stdout.toString().split('\n');
    final List<String> names = [];
    for (final line in lines) {
      final formattedLine = line.replaceAll(RegExp(r'\s+'), ' ');
      final patterns = formattedLine.split(' ');
      names.add(patterns.first);
    }
    return names.toSet().toList();
  }

  /// Starts a new process with the specified [name] and optional [arguments].
  ///
  /// If the [name] parameter contains a file path, the process will be started
  /// in the directory specified by the file path, and the process name will be
  /// matched against the base name of the file path. Otherwise, the process will
  /// be started in the current directory.
  ///
  /// The [arguments] parameter is an optional list of string arguments to pass to
  /// the process. If not provided, an empty list will be used.
  ///
  /// The [detached] parameter determines whether to start the process as a detached
  /// process. When true, the process runs independently and automatically includes
  /// the /MIN parameter to start minimized. Defaults to false.
  ///
  /// Returns a [Future] that completes with a [Process] object representing the
  /// started process.
  Future<Process> start(
    String name, {
    List<String>? arguments,
    bool detached = false,
  }) async {
    var executable = name;
    var formattedArguments = arguments ?? [];
    var mode = ProcessStartMode.normal;
    String? workingDirectory;
    final patterns = name.split(r'\');
    if (patterns.length > 1) {
      executable = patterns.last;
      workingDirectory = patterns.take(patterns.length - 1).join(r'\');
    }
    if (detached) {
      // 使用Windows的start命令来确保最小化启动
      executable = 'start';
      formattedArguments = ['/MIN', name, ...formattedArguments];
      mode = ProcessStartMode.detached;
    }
    return await Process.start(
      executable,
      formattedArguments,
      mode: mode,
      runInShell: true,
      workingDirectory: workingDirectory,
    );
  }

  /// Stops a list of processes by their process IDs.
  ///
  /// The [ids] parameter is a list of integers representing the process IDs of
  /// the processes to stop.
  ///
  /// This function iterates over each process ID in the [ids] list and calls the
  /// `killPid` function from the `Process` class to terminate the corresponding
  /// process.
  ///
  /// This function does not return anything.
  void stop(List<int> ids) {
    for (var id in ids) {
      Process.killPid(id);
    }
  }
}
