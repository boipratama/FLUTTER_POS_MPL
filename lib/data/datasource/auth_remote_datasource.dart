import 'package:dartz/dartz.dart';
import 'package:flutter_pos_mpl/core/constants/variables.dart';
import 'package:flutter_pos_mpl/data/datasource/auth_local_datasource.dart';
import 'package:flutter_pos_mpl/data/models/response/auth_response_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse(
        '${Variables.baseUrl}/api/login',
      ), // Replace with your API endpoint
      // Replace with your API endpoint
      body: {'email': '$email', 'password': '$password'},
    );
    if (response.statusCode == 200) {
      return Right(AuthResponseModel.fromJson(response.body));
    } else {
      return Left(response.body);
    }
  }

  Future<Either<String, String>> logout() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/logout'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
      },
    );
    if (response.statusCode == 200) {
      return Right(response.body);
    } else {
      return Left(response.body);
    }
  }
}
