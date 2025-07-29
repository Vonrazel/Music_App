import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hive_service.dart';
import 'user_profile_service.dart';

class User {
  final String username;
  final String password;
  final DateTime createdAt;

  User({
    required this.username,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HiveService _hiveService = HiveService();
  UserProfileService? _userProfileService;
  
  UserProfileService get _userProfileServiceInstance {
    _userProfileService ??= UserProfileService();
    return _userProfileService!;
  }
  User? _currentUser;
  bool _isInitialized = false;

  // Stream controller for authentication state changes
  final ValueNotifier<bool> _isAuthenticatedNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isAuthenticatedNotifier => _isAuthenticatedNotifier;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  // Initialize the auth service
  Future<void> initialize() async {
    try {
      await _hiveService.initialize();
      
      // Check if user is already logged in
      final currentUserData = _hiveService.box.get('currentUser');
      if (currentUserData != null) {
        _currentUser = User.fromJson(Map<String, dynamic>.from(currentUserData));
        _isAuthenticatedNotifier.value = true;
        print('✅ User already logged in: ${_currentUser!.username}');
      } else {
        // Create demo account if no users exist
        final users = _getUsers();
        if (users.isEmpty) {
          await _createDemoAccount();
        }
      }
      
      _isInitialized = true;
      print('✅ AuthService initialized successfully');
    } catch (e) {
      print('❌ Error initializing AuthService: $e');
      rethrow;
    }
  }

  // Create a demo account for testing
  Future<void> _createDemoAccount() async {
    try {
      final demoUser = User(
        username: 'demo',
        password: 'demo123',
        createdAt: DateTime.now(),
      );

      final users = [demoUser];
      await _saveUsers(users);
      print('✅ Demo account created: demo/demo123');
    } catch (e) {
      print('❌ Error creating demo account: $e');
    }
  }

  // Sign up a new user
  Future<bool> signUp(String username, String password) async {
    try {
      // Validate input
      if (username.trim().isEmpty || password.trim().isEmpty) {
        throw Exception('Username and password cannot be empty');
      }

      if (username.length < 3) {
        throw Exception('Username must be at least 3 characters long');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      // Check if username already exists
      final users = _getUsers();
      if (users.any((user) => user.username.toLowerCase() == username.toLowerCase())) {
        throw Exception('Username already exists');
      }

      // Create new user
      final newUser = User(
        username: username.trim(),
        password: password, // In a real app, this should be hashed
        createdAt: DateTime.now(),
      );

      // Save user to storage
      users.add(newUser);
      await _saveUsers(users);

      print('✅ User signed up successfully: ${newUser.username}');
      return true;
    } catch (e) {
      print('❌ Error signing up: $e');
      rethrow;
    }
  }

  // Sign in existing user
  Future<bool> signIn(String username, String password) async {
    try {
      // Validate input
      if (username.trim().isEmpty || password.trim().isEmpty) {
        throw Exception('Username and password cannot be empty');
      }

      // Find user
      final users = _getUsers();
      final user = users.firstWhere(
        (user) => user.username.toLowerCase() == username.toLowerCase() && user.password == password,
        orElse: () => throw Exception('Invalid username or password'),
      );

      // Log in the user
      await _loginUser(user);

      print('✅ User signed in successfully: ${user.username}');
      return true;
    } catch (e) {
      print('❌ Error signing in: $e');
      rethrow;
    }
  }

  // Log out user
  Future<void> signOut() async {
    try {
      _currentUser = null;
      await _hiveService.box.delete('currentUser');
      _isAuthenticatedNotifier.value = false;
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  // Helper method to log in a user
  Future<void> _loginUser(User user) async {
    _currentUser = user;
    await _hiveService.box.put('currentUser', user.toJson());
    _isAuthenticatedNotifier.value = true;
  }

  // Get all users from storage
  List<User> _getUsers() {
    try {
      final usersData = _hiveService.box.get('users', defaultValue: []);
      return (usersData as List).map((data) => User.fromJson(Map<String, dynamic>.from(data))).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Save users to storage
  Future<void> _saveUsers(List<User> users) async {
    try {
      final usersData = users.map((user) => user.toJson()).toList();
      await _hiveService.box.put('users', usersData);
    } catch (e) {
      print('Error saving users: $e');
      rethrow;
    }
  }

  // Dispose resources
  void dispose() {
    _isAuthenticatedNotifier.dispose();
  }
} 