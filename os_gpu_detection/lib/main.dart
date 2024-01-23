import "dart:io";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "dart:ffi" as dart_ffi;
import "package:window_manager/window_manager.dart";
import "package:logger/logger.dart";
import "package:flutter_window_close/flutter_window_close.dart";
import "package:path/path.dart" as path;
import "gpu_info.dart";

int gpuCount = 0;
List<String> gpuList = [];
var logger = Logger(
  printer: PrettyPrinter(),
);
const appName = "Data Compression and Encryption using GPGPU";
typedef RunGPUScriptFunc = dart_ffi.Void Function();
typedef RunGPUScript = void Function();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1000, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      fullScreen: false,
      windowButtonVisibility: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // // Linux GPU Detection
    // if (Platform.isLinux) {
    //   gpuInfoLibPath =
    //       path.join(Directory.current.path, "ffi_lib", "libGPUInfo.so");
    //   gpuInfoDynamicLib = DynamicLibrary.open(gpuInfoLibPath);
    //   final RunGPUScript runGPUScript = gpuInfoDynamicLib
    //       .lookup<NativeFunction<RunGPUScriptFunc>>("run_gpu_script")
    //       .asFunction();
    //   runGPUScript();
    // }

    if (Platform.isLinux) {
      var libraryPath =
          path.join(Directory.current.path, "ffi_lib", "libGPUInfo.so");
      final dynamicLib = dart_ffi.DynamicLibrary.open(libraryPath);
      final RunGPUScript runGPUScript = dynamicLib
          .lookup<dart_ffi.NativeFunction<RunGPUScriptFunc>>("run_gpu_script")
          .asFunction();
      runGPUScript();
    } else if (Platform.isMacOS) {
      var libraryPath =
          path.join(Directory.current.path, "ffi_lib", "libGPUInfo.dylib");
      final dynamicLib = dart_ffi.DynamicLibrary.open(libraryPath);
      final RunGPUScript runGPUScript = dynamicLib
          .lookup<dart_ffi.NativeFunction<RunGPUScriptFunc>>("run_gpu_script")
          .asFunction();
      runGPUScript();
    }
  }

  FlutterWindowClose.setWindowShouldCloseHandler(() async {
    appExit();
    return true;
  });

  gpuCount = getGPUDetails();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
    return MaterialApp(
        title: appName,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(appName),
            actions: <Widget>[
              TextButton(
                style: style,
                onPressed: () {
                  appExit();
                  exit(0);
                },
                child: const Text("Exit"),
              ),
            ],
          ),
          body: const HomeScreen(),
        ));
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(85.0),
      child: Column(
        children: [
          const Image(image: AssetImage("images/gpu.png")),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                fixedSize: const Size(180, 60),
                textStyle: const TextStyle(
                    fontFamily: "Cascadia Code",
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            label: const Text("Check GPU"),
            icon: Image.asset("images/search.png"),
            onPressed: () {
              showAlertDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

class GPUList extends StatelessWidget {
  const GPUList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
      ),
      body: Center(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < gpuList.length; i++)
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      gpuList.elementAt(i),
                      style: const TextStyle(
                        fontFamily: "Cascadia Code",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (gpuList[i].contains("NVIDIA"))
                      Image.asset(
                        'images/nvidia.png',
                        height: 150,
                        width: 150,
                      ),
                    if (gpuList[i].contains("NVIDIA"))
                      const SizedBox(height: 10),
                    if (gpuList[i].contains("NVIDIA"))
                      const Text(
                        "CUDA",
                        style: TextStyle(
                            fontFamily: "Cascadia Code",
                            fontSize: 20,
                            color: Color.fromARGB(255, 118, 185, 0),
                            fontWeight: FontWeight.w500),
                      ),
                    if (gpuList[i].contains("AMD"))
                      Image.asset(
                        'images/amd.png',
                        height: 150,
                        width: 150,
                      ),
                    if (gpuList[i].contains("AMD")) const SizedBox(height: 10),
                    if (gpuList[i].contains("AMD"))
                      const Text(
                        "OpenCL",
                        style: TextStyle(
                            fontFamily: "Cascadia Code",
                            fontSize: 20,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w500),
                      ),
                    if (gpuList[i].contains("Intel"))
                      Image.asset(
                        'images/intel.png',
                        height: 150,
                        width: 150,
                      ),
                    if (gpuList[i].contains("Intel"))
                      const SizedBox(height: 10),
                    if (gpuList[i].contains("Intel"))
                      const Text(
                        "OpenCL",
                        style: TextStyle(
                            fontFamily: "Cascadia Code",
                            fontSize: 20,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
              ),
            ),
        ],
      )),
    );
  }
}

showAlertDialog(BuildContext context) {
  Widget okButton = ElevatedButton(
    child: const Text("Ok"),
    onPressed: () {
      Navigator.of(context).pop();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const GPUList()));
    },
  );

  AlertDialog alert = AlertDialog(
    title: const Text("GPU Devices"),
    content: Text("We detected $gpuCount GPU(s) on your system"),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void appExit() {
  if (Platform.isLinux || Platform.isMacOS) {
    File("enum-gpu").deleteSync();
  }
}
