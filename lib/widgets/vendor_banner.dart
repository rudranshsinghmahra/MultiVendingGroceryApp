import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';  // <-- Add shimmer

import '../providers/vendorBannerController.dart';

class VendorBanner extends StatefulWidget {
  const VendorBanner({super.key});

  @override
  State<VendorBanner> createState() => _VendorBannerState();
}

class _VendorBannerState extends State<VendorBanner> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final controller = Get.put(VendorBannerController());
    return GetBuilder<VendorBannerController>(
      init: VendorBannerController(),
      builder: (value) {
        if (!value.isLoading) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: CarouselSlider.builder(
                  itemCount: controller.bannerData.length,
                  itemBuilder: (context, int index, int actualIndex) {
                    return SizedBox(
                      width: size.width,
                      child: Image.network(
                        controller.bannerData[index].image,
                        fit: BoxFit.fill,
                      ),
                    );
                  },
                  options: CarouselOptions(
                      viewportFraction: 1,
                      initialPage: 0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      height: size.height * 0.23,
                      onPageChanged:
                          (int indexOfPage, carouselPageChangeReason) {
                        setState(() {
                          controller.currentPage = indexOfPage;
                        });
                      }),
                ),
              ),
              DotsIndicator(
                dotsCount: controller.bannerData.length,
                position: controller.currentPage,
                decorator: DotsDecorator(
                  activeColor: Colors.deepPurpleAccent,
                  size: const Size.square(9.0),
                  activeSize: const Size(18.0, 9.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              )
            ],
          );
        } else {
          // Shimmer Effect for loading state
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: size.width,
                    height: size.height * 0.23,
                    color: Colors.white,
                  ),
                ),
              ),
              // Shimmer for DotsIndicator placeholder
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: size.width * 0.2,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
