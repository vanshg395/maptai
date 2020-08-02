import 'package:flutter/material.dart';
import 'package:maptai_shopping/screens/place_order_screen.dart';
import 'package:maptai_shopping/screens/product_details_screen.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_card.dart';
import '../providers/cart.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
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
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      spreadRadius: 2,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Disclaimer',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'All the prices are converted to Euro (€).',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ...Provider.of<Cart>(context).items.map(
                (e) {
                  return GestureDetector(
                    child: CartCard(
                      e.name,
                      e.description,
                      e.price,
                      e.quantity.toString(),
                      e.productId,
                      refresh,
                      e.image,
                      e.anotherId,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              ProductDetailsScreen(e.productId, e.name, ''),
                        ),
                      );
                    },
                  );
                },
              ).toList(),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          Provider.of<Cart>(context, listen: false).numberOfCartItems > 0
              ? GestureDetector(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 70,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Place Sample Order',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => PlaceOrderScreen(
                            Provider.of<Cart>(context, listen: false)
                                .items[0]
                                .cartId),
                      ),
                    );
                  },
                )
              : null,
    );
  }
}
