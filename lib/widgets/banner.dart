import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerWidget extends StatefulWidget {
  final List<dynamic> _banner;

  BannerWidget(this._banner);

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  double _currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
                viewportFraction: 1,
                height: 250,
                autoPlay: true,
                enableInfiniteScroll: false,
                onPageChanged: (i, _) {
                  setState(() {
                    _currentCarouselIndex = i.toDouble();
                  });
                }),
            items: <Widget>[
              ...widget._banner.map(
                (pic) => Container(
                  height: 250,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: pic['image'],
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 20,
            child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: DotsIndicator(
                dotsCount: widget._banner.length,
                position: _currentCarouselIndex,
                decorator: DotsDecorator(
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
