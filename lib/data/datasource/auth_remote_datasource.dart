import 'package:dartz/dartz.dart';
import 'package:flutter_pos_mpl/core/constants/variables.dart';
import 'package:flutter_pos_mpl/data/datasource/auth_local_datasource.dart';
import 'package:flutter_pos_mpl/data/models/response/auth_response_model.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/api/login'),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return Right(AuthResponseModel.fromJson(response.body));
      } else {
        try {
          final errorMap = jsonDecode(response.body);
          return Left(errorMap['message'] ?? 'Login failed (${response.statusCode})');
        } catch (_) {
          return Left(response.body);
        }
      }
    } catch (e) {
      return Left('Gagal terhubung ke server API (${Variables.baseUrl}): $e');
    }
  }

  Future<Either<String, String>> logout() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      if (authData == null) {
        return Left('User belum login');
      }
      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/api/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authData.token}',
        },
      );
      if (response.statusCode == 200) {
        return Right(response.body);
      } else {
        return Left(response.body);
      }
    } catch (e) {
      return Left('Gagal logout: $e');
    }
  }
}
