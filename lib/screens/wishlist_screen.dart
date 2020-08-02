import 'package:flutter/material.dart';
import 'package:maptai_shopping/providers/auth.dart';
import 'package:maptai_shopping/providers/wishlist.dart';
import 'package:maptai_shopping/screens/product_details_screen.dart';
import 'package:provider/provider.dart';

import '../providers/wishlist.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    print(Provider.of<Wishlist>(context, listen: false).items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wishlist',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              ...Provider.of<Wishlist>(context, listen: false)
                  .items
                  .map(
                    (e) => GestureDetector(
                      child: WishlistCard(
                        e.name,
                        e.description,
                        e.price,
                        e.productId,
                        refresh,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) =>
                                ProductDetailsScreen(e.productId, e.name, ''),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WishlistCard extends StatefulWidget {
  final String name;
  final String description;
  final String price;
  final String id;
  final Function refresh;

  WishlistCard(this.name, this.description, this.price, this.id, this.refresh);

  @override
  _WishlistCardState createState() => _WishlistCardState();
}

class _WishlistCardState extends State<WishlistCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              spreadRadius: 2,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(),
                    ),
                    Text(
                      widget.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 70,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 36,
                  color: _isLoading ? Colors.grey : Colors.red,
                ),
                onPressed: _isLoading
                    ? () {}
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await Provider.of<Wishlist>(context, listen: false)
                            .removeItem(
                                Provider.of<Auth>(context, listen: false).token,
                                widget.id,
                                widget.name);
                        setState(() {
                          _isLoading = false;
                        });
                        widget.refresh();
                      },
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ProductDetailsScreen(widget.id, widget.name, ''),
          ),
        );
      },
    );
  }
}
