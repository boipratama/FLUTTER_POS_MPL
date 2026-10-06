import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_mpl/core/constants/variables.dart';
import 'package:flutter_pos_mpl/core/extensions/int_ext.dart';
import 'package:flutter_pos_mpl/data/models/response/product_response_model.dart';
import 'package:flutter_pos_mpl/presentation/home/bloc/checkout/checkout_bloc.dart';
import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';

class ProductCard extends StatelessWidget {
  final Product data;
  final VoidCallback onCartButton;

  const ProductCard({
    super.key,
    required this.data,
    required this.onCartButton,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: AppColors.card),
              borderRadius: BorderRadius.circular(19),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.disabled.withOpacity(0.4),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                  child: data.image.isEmpty
                      ? const Icon(Icons.food_bank_outlined, size: 70)
                      : CachedNetworkImage(
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          imageUrl: (data.image.startsWith('http://') ||
                                  data.image.startsWith('https://'))
                              ? data.image
                              : '${Variables.imageBaseUrl}${data.image}',
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.food_bank_outlined, size: 70),
                        ),
                ),
              ),
              const SpaceHeight(8.0),
              Text(
                data.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                data.category,
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
              const SpaceHeight(4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      data.price.currencyFormatRp,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<CheckoutBloc>().add(
                        CheckoutEvent.addCheckout(data),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(9.0)),
                        color: AppColors.primary,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            return state.maybeWhen(
              orElse: () => const SizedBox(),
              success: (products, qty, price) {
                if (qty == 0) {
                  return const SizedBox();
                }
                return products.any((element) => element.product == data)
                    ? products
                                .firstWhere(
                                  (element) => element.product == data,
                                )
                                .quantity >
                            0
                        ? Positioned(
                          top: 6,
                          right: 6,
                          child: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              products
                                  .firstWhere(
                                    (element) => element.product == data,
                                  )
                                  .quantity
                                  .toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        : const SizedBox()
                    : const SizedBox();
              },
            );
          },
        ),
      ],
    );
  }
}
