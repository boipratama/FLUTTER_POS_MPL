

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_mpl/core/extensions/build_context_ext.dart';
import 'package:flutter_pos_mpl/core/components/buttons.dart';
import 'package:flutter_pos_mpl/core/components/custom_dropdown.dart';
import 'package:flutter_pos_mpl/core/components/custom_text_field.dart';
import 'package:flutter_pos_mpl/core/components/image_picker_widget.dart';
import 'package:flutter_pos_mpl/core/components/spaces.dart';
import 'package:flutter_pos_mpl/core/extensions/string_ext.dart';
import 'package:flutter_pos_mpl/data/models/response/product_response_model.dart';
import 'package:flutter_pos_mpl/presentation/home/bloc/product/product_bloc.dart';
import 'package:flutter_pos_mpl/presentation/setting/models/category_model.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  TextEditingController? nameController;
  TextEditingController? priceController;
  TextEditingController? stockController;
  XFile? imageFile;

  bool isBestSeller = false;

  String? category;
  List<CategoryModel> categories = [
    CategoryModel(value: 'food', name: 'Food'),
    CategoryModel(value: 'drink', name: 'Drink'),
    CategoryModel(value: 'snack', name: 'Snack'),
  ];

  @override
  void initState() {
    nameController = TextEditingController();
    priceController = TextEditingController();
    stockController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController?.dispose();
    priceController?.dispose();
    stockController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk'), centerTitle: true),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: context.isTablet ? 600 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
        children: [
          CustomTextField(controller: nameController!, label: 'Nama Produk'),
          const SpaceHeight(20.0),
          CustomTextField(
            controller: priceController!,
            label: 'Harga Produk',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // final int priceValue = value.toIntegerFromText;
              // priceController.text = priceValue.currencyFormatRp;
              // priceController.selection = TextSelection.fromPosition(
              //     TextPosition(offset: priceController.text.length));
            },
          ),
          const SpaceHeight(20.0),
          ImagePickerWidget(
            label: 'Foto Produk',
            onChanged: (file) {
              if (file == null) {
                return;
              }
              imageFile = file;
            },
          ),
          const SpaceHeight(20.0),
          CustomTextField(
            controller: stockController!,
            label: 'Stok Produk',
            keyboardType: TextInputType.number,
          ),
          const SpaceHeight(5.0),
          Row(
            children: [
              Checkbox(
                value: isBestSeller,
                onChanged: (value) {
                  setState(() {
                    isBestSeller = value!;
                  });
                },
              ),
              const Text('Best Seller'),
            ],
          ),
          const SpaceHeight(5.0),
          CustomDropdown<CategoryModel>(
            value: categories.first,
            items: categories,
            label: 'Kategori',
            onChanged: (value) {
              category = value!.value;
            },
          ),
          const SpaceHeight(24.0),
          BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},
                success: (_) {
                  Navigator.pop(context);
                },
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return const Center(child: CircularProgressIndicator());
                },
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },
                success: (products) {
                  return Button.filled(
                    onPressed: () {
                      final String name = nameController!.text;
                      final int price = stockController!.text.toIntegerFromText;
                      final int stock = stockController!.text.toIntegerFromText;
                      final Product product = Product(
                        name: name,
                        price: price,
                        stock: stock,
                        category: category ?? categories.first.value,
                        isBestSeller: isBestSeller,
                        image: imageFile!.path,
                      );
                      context.read<ProductBloc>().add(
                        ProductEvent.addProduct(product, imageFile!),
                      );
                    },
                    label: 'Simpan',
                  );
                },
              );
            },
          ),
          Button.outlined(
            onPressed: () {
              Navigator.pop(context);
            },
            label: 'Batal',
          ),
          const SpaceHeight(30.0),
        ],
      ),
    ),
  ),
);
  }
}
