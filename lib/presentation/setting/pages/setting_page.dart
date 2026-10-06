// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_mpl/core/assets/assets.gen.dart';
import 'package:flutter_pos_mpl/core/components/menu_button.dart';
import 'package:flutter_pos_mpl/core/components/spaces.dart';
import 'package:flutter_pos_mpl/core/constants/colors.dart';
import 'package:flutter_pos_mpl/core/extensions/build_context_ext.dart';
import 'package:flutter_pos_mpl/data/datasource/auth_local_datasource.dart';
import 'package:flutter_pos_mpl/data/datasource/product_local_datasource.dart';
import 'package:flutter_pos_mpl/presentation/auth/pages/login_page.dart';
import 'package:flutter_pos_mpl/presentation/home/bloc/product/product_bloc.dart';
import 'package:flutter_pos_mpl/presentation/setting/pages/manage_product_page.dart';

import '../../home/bloc/logout/logout_bloc.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: context.isTablet ? 700 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              MenuButton(
                iconPath: Assets.images.manageProduct.path,
                label: 'Kelola Produk',
                onPressed: () => context.push(const ManageProductPage()),
                isImage: true,
              ),
              const SpaceWidth(15.0),
              MenuButton(
                iconPath: Assets.images.managePrinter.path,
                label: 'Kelola Printer',
                onPressed: () {},
                //   context.push(const ManagePrinterPage()),
                isImage: true,
              ),
            ],
          ),
          const SpaceHeight(40),
          BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},
                success: (state) async {
                  await ProductLocalDatasource.instance.removeAllProduct();
                  await ProductLocalDatasource.instance.insertAllProduct(
                    state.products.toList(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.primary,
                      content: Text('Sync data success'),
                    ),
                  );
                },
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(
                        const ProductEvent.fetch(),
                      );
                    },
                    child: const Text('Sync Data'),
                  );
                },
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },
              );
            },
          ),
          const Divider(),
          BlocConsumer<LogoutBloc, LogoutState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},
                success: (_) {
                  AuthLocalDatasource().removeAuthData();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              );
            },
            builder: (context, state) {
              return ElevatedButton(
                onPressed: () {
                  context.read<LogoutBloc>().add(const LogoutEvent.logout());
                },
                child: const Text('Logout'),
              );
            },
          ),
          const Divider(),
        ],
      ),
    ),
  ),
);
  }
}
