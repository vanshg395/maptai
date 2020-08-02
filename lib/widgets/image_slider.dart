import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:maptai_shopping/widgets/video_preview.dart';
import 'package:photo_view/photo_view.dart';

class ImageSlider extends StatefulWidget {
  final List<dynamic> images;
  final List<dynamic> videos;

  ImageSlider(this.images, this.videos);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  double _currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    return widget.images.length + widget.videos.length > 0
        ? Container(
            height: 250,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                CarouselSlider(
                  options: CarouselOptions(
                      viewportFraction: 1,
                      height: 250,
                      autoPlay: false,
                      enableInfiniteScroll: false,
                      onPageChanged: (i, _) {
                        setState(() {
                          _currentCarouselIndex = i.toDouble();
                        });
                      }),
                  items: <Widget>[
                    ...widget.images
                        .map(
                          (pic) => GestureDetector(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // image: DecorationImage(
                                //   image: CachedNetworkImageProvider(
                                //       pic['product_image']),
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                              child: PhotoView(
                                backgroundDecoration: BoxDecoration(
                                  color: Color(0x00000000),
                                ),
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: PhotoViewComputedScale.contained,
                                imageProvider:
                                    NetworkImage(pic['product_image']),
                              ),
                            ),
                            onTap: () async {
                              await showDialog(
                                context: context,
                                child: Dialog(
                                  child: Container(
                                    height: 300,
                                    child: PhotoView(
                                      backgroundDecoration: BoxDecoration(
                                        color: Color(0x00000000),
                                      ),
                                      minScale:
                                          PhotoViewComputedScale.contained,
                                      maxScale:
                                          PhotoViewComputedScale.contained,
                                      imageProvider: CachedNetworkImageProvider(
                                          pic['product_image']),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
                    ...widget.videos
                        .map(
                          (e) => VideoPreviewScreen(e['product_video']),
                        )
                        .toList(),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: DotsIndicator(
                      dotsCount: widget.images.length + widget.videos.length,
                      position: _currentCarouselIndex,
                      decorator: DotsDecorator(
                        activeColor: _currentCarouselIndex >=
                                widget.images.length
                            ? Theme.of(context).primaryColor.withOpacity(0.3)
                            : Theme.of(context).primaryColor,
                        color: _currentCarouselIndex >= widget.images.length
                            ? Colors.grey.withOpacity(0.3)
                            : Colors.grey,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        : SizedBox();
  }
}
