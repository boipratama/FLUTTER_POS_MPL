import 'package:bloc/bloc.dart';
import 'package:flutter_pos_mpl/data/datasource/product_local_datasource.dart';
import 'package:flutter_pos_mpl/data/datasource/product_remote_datasource.dart';
import 'package:flutter_pos_mpl/data/models/request/product_request_model.dart';
import 'package:flutter_pos_mpl/data/models/response/product_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'product_event.dart';
part 'product_state.dart';
part 'product_bloc.freezed.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource _productRemoteDatasource;
  List<Product> products = [];
  ProductBloc(this._productRemoteDatasource) : super(const _Initial()) {
    on<_Fetch>((event, emit) async {
      emit(const ProductState.loading());
      final response = await _productRemoteDatasource.getProducts();
      await response.fold(
        (l) async {
          final localProducts =
              await ProductLocalDatasource.instance.getAllProduct();
          if (localProducts.isNotEmpty) {
            products = localProducts;
            emit(ProductState.success(products));
          } else {
            emit(ProductState.error(l));
          }
        },
        (r) async {
          products = r.data;
          try {
            await ProductLocalDatasource.instance.removeAllProduct();
            await ProductLocalDatasource.instance.insertAllProduct(r.data);
          } catch (_) {}
          emit(ProductState.success(r.data));
        },
      );
    });

    on<_FetchLocal>((event, emit) async {
      emit(const ProductState.loading());
      final localPproducts =
          await ProductLocalDatasource.instance.getAllProduct();
      products = localPproducts;

      emit(ProductState.success(products));
    });

    on<_FetchByCategory>((event, emit) async {
      emit(const ProductState.loading());

      if (products.isEmpty) {
        final localProducts =
            await ProductLocalDatasource.instance.getAllProduct();
        if (localProducts.isNotEmpty) {
          products = localProducts;
        }
      }

      final cat = event.category.toLowerCase().trim();
      final newProducts = (cat == 'all' || cat.isEmpty)
          ? products
          : products.where((element) {
              final itemCat = element.category.toLowerCase().trim();
              if (cat == 'drink') {
                return itemCat == 'drink' || itemCat == 'minuman';
              } else if (cat == 'food') {
                return itemCat == 'food' || itemCat == 'makanan';
              } else if (cat == 'snack') {
                return itemCat == 'snack' || itemCat == 'cemilan';
              }
              return itemCat == cat;
            }).toList();

      emit(ProductState.success(newProducts));
    });

    on<_AddProduct>((event, emit) async {
      emit(const ProductState.loading());
      final requestData = ProductRequestModel(
        name: event.product.name,
        price: event.product.price,
        stock: event.product.stock,
        category: event.product.category,
        isBestSeller: event.product.isBestSeller ? 1 : 0,
        image: event.image,
      );
      final response = await _productRemoteDatasource.addProduct(
        requestData,
      );
      response.fold(
        (l) => emit(ProductState.error(l)),
        (r) {
          products.add(r.data);
          emit(ProductState.success(products));
        },
      );

      emit(ProductState.success(products));
    });
  }
}
