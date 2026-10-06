import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_mpl/core/components/spaces.dart';
import 'package:flutter_pos_mpl/presentation/home/bloc/product/product_bloc.dart';
import 'package:flutter_pos_mpl/presentation/home/models/product_model.dart';
import 'package:flutter_pos_mpl/presentation/manage/widgets/menu_product_item.dart';
import 'package:flutter_pos_mpl/presentation/setting/pages/add_product_page.dart';

import 'package:flutter_pos_mpl/core/extensions/build_context_ext.dart';

class ManageProductPage extends StatefulWidget {
  const ManageProductPage({super.key});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  final List<ProductModel> products = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Produk'), centerTitle: true),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: context.isTablet ? 800 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Text(
                'Menu',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
              ),
              const SpaceHeight(20.0),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    orElse: () {
                      return const Center(child: CircularProgressIndicator());
                    },
                    success: (products) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder:
                            (context, index) => const SpaceHeight(20.0),
                        itemBuilder:
                            (context, index) =>
                                MenuProductItem(data: products[index]),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const AddProductPage();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
