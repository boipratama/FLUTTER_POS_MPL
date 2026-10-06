import 'package:dartz/dartz.dart';
import 'package:flutter_pos_mpl/core/constants/variables.dart';
import 'package:flutter_pos_mpl/data/models/request/product_request_model.dart';
import 'package:flutter_pos_mpl/data/models/response/add_product_response_model.dart';
import 'package:flutter_pos_mpl/data/models/response/product_response_model.dart';
import 'package:http/http.dart' as http;
import 'auth_local_datasource.dart';

class ProductRemoteDatasource {
  Future<Either<String, ProductResponseModel>> getProducts() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      if (authData == null) {
        return left('User belum login');
      }
      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/products'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authData.token}',
        },
      );

      if (response.statusCode == 200) {
        return right(ProductResponseModel.fromJson(response.body));
      } else {
        return left(response.body);
      }
    } catch (e) {
      return left('Gagal mengambil data produk: $e');
    }
  }

  Future<Either<String, AddProductResponseModel>> addProduct(
    ProductRequestModel productRequestModel,
  ) async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      if (authData == null) {
        return left('User belum login');
      }
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData.token}',
      };
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Variables.baseUrl}/api/products'),
      );
      request.fields.addAll(productRequestModel.toMap());
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          productRequestModel.image.path,
        ),
      );

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final String body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return right(AddProductResponseModel.fromJson(body));
      } else {
        return left(body);
      }
    } catch (e) {
      return left('Gagal menambah produk: $e');
    }
  }
}
