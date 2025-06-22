import 'package:bloc/bloc.dart';
import 'package:flutter_pos_mpl/data/datasource/product_remote_datasource.dart';
import 'package:flutter_pos_mpl/data/models/response/product_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_event.dart';
part 'product_state.dart';
part 'product_bloc.freezed.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource _productRemoteDatasource;
  List<Product> products = [];
  ProductBloc(
    this._productRemoteDatasource,
    ) : super(const _Initial()) {
    on<_Fetch>((event, emit) async{
      emit(const ProductState.loading());
      final response = await _productRemoteDatasource.getProducts();
      response.fold(
        (l) => emit(ProductState.error(l)),
        (r){
          products = r.data;
          emit(ProductState.success(r.data));}
      );
    });

    on<_FetchByCategory>((event, emit) async{
      emit(const ProductState.loading());
      final newProducts = event.category == 'all'
      ? products
      : products
      .where((element) => element.category == event.category)
      .toList();

      emit(ProductState.success(newProducts));
    });
      // TODO: implement event handler

  }
}
