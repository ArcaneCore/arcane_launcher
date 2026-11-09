import 'dart:async';
import 'dart:io';

class ProcessUtil {
  /// Processes started with [startHidden], kept referenced while they run.
  ///
  /// The launcher holds the write end of their stdin pipe, so the [Process]
  /// must stay alive for as long as the server should keep running: the
  /// worldserver shuts itself down when its stdin reaches EOF.
  final _hiddenProcesses = <Process>{};

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
  /// The child's stdout/stderr are piped to the returned [Process], so the
  /// caller is responsible for consuming them, otherwise the child can block
  /// once a pipe buffer fills up.
  ///
  /// Returns a [Future] that completes with a [Process] object representing the
  /// started process.
  Future<Process> start(String name, {List<String>? arguments}) async {
    final (executable, workingDirectory) = _split(name);
    return await Process.start(
      executable,
      arguments ?? [],
      mode: ProcessStartMode.normal,
      runInShell: true,
      workingDirectory: workingDirectory,
    );
  }

  /// Starts a new process in the background without opening a console window.
  ///
  /// This uses [ProcessStartMode.normal], which starts the child with
  /// `CREATE_NO_WINDOW` on Windows, so no window is shown (mysqld is started
  /// the same way). The child's stdout/stderr are drained so a server that logs
  /// heavily can never block on a full pipe, and the process is kept referenced
  /// so its stdin pipe stays open: the worldserver treats stdin EOF as a
  /// shutdown request.
  Future<Process> startHidden(String name, {List<String>? arguments}) async {
    final process = await start(name, arguments: arguments);
    _hiddenProcesses.add(process);
    unawaited(process.stdout.drain<void>().catchError((_) {}));
    unawaited(process.stderr.drain<void>().catchError((_) {}));
    unawaited(
      process.exitCode.whenComplete(() => _hiddenProcesses.remove(process)),
    );
    return process;
  }

  (String, String?) _split(String name) {
    final patterns = name.split(r'\');
    if (patterns.length == 1) return (name, null);
    return (patterns.last, patterns.take(patterns.length - 1).join(r'\'));
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
