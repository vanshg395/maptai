import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maptai_shopping/screens/country_products_screen.dart';

class CountrySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: Text(
              'Country-wise Products',
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  CountrySelectorItem('assets/img/india.png', 'India'),
                  CountrySelectorItem(
                      'assets/img/bangladesh.png', 'Bangladesh'),
                  CountrySelectorItem('assets/img/nigeria.png', 'Nigeria'),
                  CountrySelectorItem('assets/img/iran.png', 'Other'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CountrySelectorItem extends StatelessWidget {
  final String imageUrl, countryName;

  CountrySelectorItem(this.imageUrl, this.countryName);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: 110,
        child: Column(
          children: <Widget>[
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                image: countryName == 'Other'
                    ? null
                    : DecorationImage(
                        image: AssetImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
              ),
              child: countryName == 'Other'
                  ? Icon(
                      Icons.map,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              countryName == 'Other' ? 'Others' : countryName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => CountryProductsScreen(countryName),
          ),
        );
      },
    );
  }
}
