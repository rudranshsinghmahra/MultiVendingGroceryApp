import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; // <- Add this

import '../controller/image_slider_controller.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({Key? key}) : super(key: key);

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final controller = Get.put(ImageSliderController());

    return GetBuilder<ImageSliderController>(
      init: ImageSliderController(),
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
                    onPageChanged: (int indexOfPage, carouselPageChangeReason) {
                      setState(() {
                        controller.currentPage = indexOfPage;
                      });
                    },
                  ),
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
              ),
            ],
          );
        } else {
          // Show shimmer placeholder while loading
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: size.width,
                    height: size.height * 0.23,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 18.0,
                        height: 9.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
