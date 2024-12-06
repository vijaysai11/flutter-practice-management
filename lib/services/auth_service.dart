import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

class MicrosoftAuthService {
  final String clientId = '368c05d1-99e6-493e-b1fe-feef083f659b';
  final String tenantId = '3033642d-6adf-4ac6-bbc5-511b42bc5f00';
  final String redirectUriMobile = 'msauth://com.example.first_project/callback';
  final String redirectUriWeb = 'http://localhost:59064/callback'; // Web redirect URI

  Future<String?> login() async {
    try {
      final redirectUri = kIsWeb ? redirectUriWeb : redirectUriMobile;

      // Step 1: Build the authentication URL
      final authorizationUrl =
          'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize'
          '?client_id=$clientId'
          '&response_type=code'
          '&redirect_uri=$redirectUri'
          '&response_mode=query'
          '&scope=User.Read';

      String result;
      if (kIsWeb) {
        result = await FlutterWebAuth.authenticate(
          url: authorizationUrl,
          callbackUrlScheme: "http",
        );
      } else {
        // Step 2: Open the authentication page for mobile
        result = await FlutterWebAuth.authenticate(
          url: authorizationUrl,
          callbackUrlScheme: "msauth",
        );
      }

      // Step 3: Extract the authorization code
      final code = Uri.parse(result).queryParameters['code'];

      if (code == null) {
        print('Login was canceled or failed');
        return null;
      }

      // Step 4: Exchange the authorization code for an access token
      final tokenUrl =
          'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'scope': 'User.Read',
          'code': code,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch access token: ${response.body}');
      }

      final tokenData = jsonDecode(response.body);
      return tokenData['access_token'];
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }
}
