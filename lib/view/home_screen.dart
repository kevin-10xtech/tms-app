import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmsapp/utils/app_constant_strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  String url = AppConstantStrings.tmsProductionURL;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    allowsBackForwardNavigationGestures: true,
    iframeAllowFullscreen: true,
    useOnDownloadStart: true,
    isElementFullscreenEnabled: false,
    allowFileAccess: true,
    allowContentAccess: true,
    automaticallyAdjustsScrollIndicatorInsets: true,
    allowFileAccessFromFileURLs: true,
  );

  PullToRefreshController? pullToRefreshController;

  double progress = 0;

  // Future<bool?> checkPermission() async {
  //   Get.log('checkPermission');
  //   if (Platform.isAndroid) {
  //     final androidInfo = await DeviceInfoPlugin().androidInfo;
  //     if (androidInfo.version.sdkInt <= 32) {
  //       final storagePermission = await Permission.storage.request();
  //       if (storagePermission == PermissionStatus.granted) {
  //         return true;
  //       } else if (storagePermission == PermissionStatus.denied) {
  //         await openAppSettings();
  //         return false;
  //       } else if (storagePermission == PermissionStatus.permanentlyDenied) {
  //         await openAppSettings();
  //         return false;
  //       }
  //     } else {
  //       PermissionStatus imagePermission = await Permission.photos.request();
  //       // PermissionStatus videoPermission = await Permission.videos.request();
  //       // PermissionStatus audioPermission = await Permission.audio.request();

  //       // Get.log(imagePermission.toString());
  //       // Get.log(audioPermission.toString());

  //       // if (imagePermission == PermissionStatus.granted &&
  //       //     videoPermission == PermissionStatus.granted) {
  //       if (imagePermission == PermissionStatus.granted) {
  //         Get.log('1');
  //         return true;
  //       } else {
  //         await openAppSettings();
  //         return false;
  //       }
  //     }
  //   } else if (Platform.isIOS) {
  //     final storagePermission = await Permission.storage.request();
  //     Get.log(storagePermission.toString());
  //     if (storagePermission == PermissionStatus.granted) {
  //       return true;
  //     } else if (storagePermission == PermissionStatus.denied) {
  //       await openAppSettings();
  //       return false;
  //     } else if (storagePermission == PermissionStatus.permanentlyDenied) {
  //       await openAppSettings();
  //       return false;
  //     }
  //   } else {
  //     Get.log('4');
  //     return null;
  //   }
  //   Get.log('5');
  //   return null;
  // }

  Future<bool> checkPermission() async {
    Get.log('checkPermission');

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      // For Android 13+ (SDK 33 or above)
      if (androidInfo.version.sdkInt >= 33) {
        // Request all media-related permissions
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        final audio = await Permission.audio.request();

        if (photos.isGranted || videos.isGranted || audio.isGranted) {
          return true;
        } else {
          await openAppSettings();
          return false;
        }
      }

      // For Android 12 and below
      final storagePermission = await Permission.storage.request();
      if (storagePermission.isGranted) {
        return true;
      } else {
        await openAppSettings();
        return false;
      }
    }

    // iOS logic
    if (Platform.isIOS) {
      final storagePermission = await Permission.photosAddOnly.request();
      if (storagePermission.isGranted) {
        return true;
      } else {
        await openAppSettings();
        return false;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(url)),
          initialSettings: settings,
          // pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) {
            webViewController = controller;

            // webViewController!.addJavaScriptHandler(
            //   handlerName: 'Android',
            //   callback: (data) {
            //     Get.log('Android :: $data');
            //   },
            // );
            // JS → Flutter communication channel
            webViewController?.addJavaScriptHandler(
              handlerName: "onBlobData",
              callback: (args) async {
                if (args.isEmpty) return;
                final data = args[0]; // { filename, base64 }
                final filename = data['filename'] ?? "file";
                final base64 = data['base64'] ?? "";

                if (base64.isEmpty) {
                  Get.snackbar("Download Failed", "No data received from blob");
                  return;
                }

                try {
                  Uint8List bytes = base64Decode(base64);
                  var dir = await getDownloadsDirectory();
                  final file = File("${dir!.path}/$filename");
                  await file.writeAsBytes(bytes);
                  Get.snackbar("Download Complete", "Saved to ${file.path}");
                  // Get.log("✅ File saved: ${file.path}");
                } catch (e) {
                  Get.log("❌ Error saving blob: $e");
                  Get.snackbar("Download Failed", e.toString());
                }
              },
            );
          },
          onLoadStart: (controller, url) {
            setState(() {
              this.url = url.toString();
            });
          },
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            // var uri = navigationAction.request.url!;

            // Get.log('shouldOverrideUrlLoading :: $uri');

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) async {
            pullToRefreshController?.endRefreshing();
            // setState(() {
            //   this.url = url.toString();
            // });

            // await _checkAvailableChannels();
          },

          onReceivedError: (controller, request, error) {
            pullToRefreshController?.endRefreshing();
          },
          onProgressChanged: (controller, progress) {
            if (progress == 100) {
              pullToRefreshController?.endRefreshing();
            }
            setState(() {
              this.progress = progress / 100;
            });
          },
          onUpdateVisitedHistory: (controller, url, androidIsReload) {
            setState(() {
              this.url = url.toString();
            });
          },
          onConsoleMessage: (controller, consoleMessage) {
            Get.log('onConsoleMessage  :: ${consoleMessage.toJson()}');
          },
          onDownloadStartRequest: (controller, downloadStartRequest) async {
            Get.log('DOWNLOAD DETECTED: ${downloadStartRequest.toMap()}');

            var downloadUrl = downloadStartRequest.url.toString();
            var filename = downloadStartRequest.suggestedFilename ?? "file";

            // ✅ Use your permission checker
            bool hasPermission = await checkPermission();

            if (hasPermission) {
              if (downloadUrl.startsWith("blob:")) {
                await _handleBlobDownload(controller, filename);
              } else {
                await _downloadFileFromUrl(downloadUrl, filename);
              }
            } else {
              Get.snackbar(
                "Permission Denied",
                "Storage permission is required to download files",
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _downloadFileFromUrl(String url, String filename) async {
    try {
      Directory? dir;

      if (Platform.isAndroid) {
        // ✅ Try to use the public "Download" directory
        dir = Directory("/storage/emulated/0/Download");

        if (!await dir.exists()) {
          // ✅ Fallback to app’s scoped download folder if inaccessible
          dir = await getDownloadsDirectory();
        }
      } else {
        // ✅ iOS/macOS
        dir = await getDownloadsDirectory();
      }

      if (dir == null) {
        Get.snackbar("Download Failed", "Unable to access download directory");
        return;
      }

      final savePath = "${dir.path}/$filename";
      Get.log("📥 Downloading $url → $savePath");

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception(
          "Failed to download file (HTTP ${response.statusCode})",
        );
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      final file = File(savePath);
      await file.writeAsBytes(bytes);

      Get.snackbar("✅ Download Complete", "Saved to: ${file.path}");
      Get.log("✅ File saved successfully → ${file.path}");
    } catch (e, st) {
      Get.log("❌ Error downloading file: $e\n$st");
      Get.snackbar("Download Failed", e.toString());
    }
  }

  /// Handles regular downloads (non-blob)
  // Future<void> _downloadFileFromUrl(String url, String filename) async {
  //   try {
  //     var dir = await getDownloadsDirectory();
  //     String savePath = "${dir!.path}/$filename";

  //     Get.log("Downloading $url to $savePath");

  //     final client = HttpClient();
  //     final request = await client.getUrl(Uri.parse(url));
  //     final response = await request.close();

  //     final bytes = await consolidateHttpClientResponseBytes(response);
  //     final file = File(savePath);
  //     await file.writeAsBytes(bytes);

  //     Get.snackbar("Download Complete", "Saved to ${file.path}");
  //   } catch (e) {
  //     Get.log("Error downloading file: $e");
  //     Get.snackbar("Download Failed", e.toString());
  //   }
  // }

  /// Handles blob downloads via JavaScript bridge
  Future<void> _handleBlobDownload(
    InAppWebViewController controller,
    String filename,
  ) async {
    try {
      // Inject JS directly into the page to extract the blob
      final js =
          """
      (async function() {
        const blobUrl = '${await controller.getUrl()}';
        try {
          const response = await fetch(blobUrl);
          const blob = await response.blob();
          const reader = new FileReader();

          reader.onloadend = function() {
            const base64data = reader.result.split(',')[1];
            // Send base64 + filename to Flutter
            window.flutter_inappwebview.callHandler('onBlobData', {
              filename: '$filename',
              base64: base64data
            });
          };
          reader.readAsDataURL(blob);
        } catch (err) {
          window.flutter_inappwebview.callHandler('onBlobData', {
            filename: '$filename',
            base64: ''
          });
        }
      })();
    """;

      await controller.evaluateJavascript(source: js);
    } catch (e, st) {
      Get.log("❌ JS blob injection failed: $e\n$st");
      Get.snackbar("Download Failed", e.toString());
    }
  }
}
