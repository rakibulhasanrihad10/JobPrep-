import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'mock_supabase_http_client.dart';

/// Mock GoTrue client providing a static authenticated user.
class MockGoTrueClient extends Fake implements supabase.GoTrueClient {
  MockGoTrueClient(this._user);
  final supabase.User? _user;

  final StreamController<supabase.AuthState> _syncController =
      StreamController<supabase.AuthState>.broadcast();

  @override
  supabase.User? get currentUser => _user;

  @override
  Stream<supabase.AuthState> get onAuthStateChangeSync =>
      _syncController.stream;

  @override
  Stream<supabase.AuthState> get onAuthStateChange => _syncController.stream;

  @override
  supabase.Session? get currentSession => _user != null
      ? supabase.Session(
          accessToken: 'mock-access-token',
          tokenType: 'bearer',
          user: _user,
        )
      : null;
}

/// SupabaseClient configured with in-memory HTTP transport and
/// authenticated user.
class MockSupabaseClient extends supabase.SupabaseClient {
  MockSupabaseClient({
    required MockSupabaseHttpClient mockHttpClient,
    String userId = 'mock-user-1111',
  })  : _mockAuth = MockGoTrueClient(
          supabase.User(
            id: userId,
            appMetadata: const {},
            userMetadata: const {},
            aud: 'authenticated',
            email: 'test@example.com',
            createdAt: '2026-01-01T00:00:00Z',
          ),
        ),
        super(
          'https://mock.supabase.co',
          'mock-anon-key',
          httpClient: mockHttpClient,
        );

  final MockGoTrueClient _mockAuth;

  @override
  supabase.GoTrueClient get auth => _mockAuth;
}
