import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static const int _connectionTimeout = 60; // 60 seconds timeout
  static const int _retryInterval = 5; // Retry every 5 seconds
  static const int _lookupTimeout =
      10; // 10 seconds timeout for internet lookup
  static const String _testUrl = 'https://www.google.com';

  static Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      print('Current connectivity status: $connectivityResult');
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  static Future<void> waitForConnection() async {
    if (await checkConnectivity()) {
      print('Network connection already available');
      return;
    }

    print('Waiting for network connection...');
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < Duration(seconds: _connectionTimeout)) {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult != ConnectivityResult.none) {
          print(
              'Network connection restored after ${stopwatch.elapsed.inSeconds} seconds');
          // Verify internet connectivity
          if (await isInternetAvailable()) {
            return;
          } else {
            print('Network connected, but no internet access');
          }
        }
      } catch (e) {
        print('Error while waiting for connection: $e');
      }

      await Future.delayed(Duration(seconds: _retryInterval));
    }

    stopwatch.stop();
    throw TimeoutException(
        'Network connection not available after $_connectionTimeout seconds');
  }

  // Fixed: Changed return type to match Connectivity Plus package's current implementation
  static Stream<List<ConnectivityResult>> get connectivityStream {
    return Connectivity().onConnectivityChanged;
  }

  static Future<bool> isInternetAvailable() async {
    if (await checkConnectivity()) {
      try {
        if (kIsWeb) {
          // For web platform, try to fetch a small resource
          final response = await http
              .get(Uri.parse('$_testUrl/favicon.ico'))
              .timeout(Duration(seconds: _lookupTimeout));
          return response.statusCode == 200;
        } else {
          // For mobile platforms, use InternetAddress.lookup
          final result =
              await InternetAddress.lookup(_testUrl.replaceAll('https://', ''))
                  .timeout(Duration(seconds: _lookupTimeout));
          return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        }
      } on SocketException catch (e) {
        print('No internet connection available (SocketException): $e');
        return false;
      } on TimeoutException catch (e) {
        print('Internet lookup timed out: $e');
        return false;
      } catch (e) {
        print('Error checking internet connectivity: $e');
        return false;
      }
    }
    return false;
  }

  static Future<void> waitForInternet() async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < Duration(seconds: _connectionTimeout)) {
      if (await isInternetAvailable()) {
        print(
            'Internet connection available after ${stopwatch.elapsed.inSeconds} seconds');
        return;
      }
      await Future.delayed(Duration(seconds: _retryInterval));
    }

    stopwatch.stop();
    throw TimeoutException(
        'Internet connection not available after $_connectionTimeout seconds');
  }

  static Future<bool> testConnection(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: _lookupTimeout));
      return response.statusCode == 200;
    } catch (e) {
      print('Error testing connection to $url: $e');
      return false;
    }
  }
}
