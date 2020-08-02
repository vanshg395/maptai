import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:permission_handler/permission_handler.dart';

import './home_screen.dart';
import './search_screen.dart';
import './orders_screen.dart';
import './chat_screen.dart';
import './account_screen.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';
import '../providers/wishlist.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _requestCount = 0;
  int _selectedPageIndex = 0;
  PageController _pageController = PageController();
  List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    OrdersScreen(),
    ChatScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    getCartDetails();
    getWishlistDetails();
  }

  Future<void> initiateOneSignal() async {
    await Permission.notification.request();
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.init("4f605927-54bb-4834-9d8f-ee22591bece1", iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: false
    });
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      // will be called whenever a notification is received
      print('git it');
    });
  }

  Future<void> getCartDetails() async {
    if (Provider.of<Auth>(context, listen: false).isAuth) {
      setState(() {
        _requestCount++;
      });

      await Provider.of<Wishlist>(context, listen: false)
          .getItems(Provider.of<Auth>(context, listen: false).token);
      setState(() {
        _requestCount--;
      });
    }
  }

  Future<void> getWishlistDetails() async {
    if (Provider.of<Auth>(context, listen: false).isAuth) {
      setState(() {
        _requestCount++;
      });
      try {
        await Provider.of<Cart>(context, listen: false)
            .getItems(Provider.of<Auth>(context, listen: false).token);
      } catch (e) {
        print(e);
      }
      setState(() {
        _requestCount--;
      });
    }
    initiateOneSignal();
  }

  @override
  Widget build(BuildContext context) {
    return _requestCount > 0
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: PageView(
              controller: _pageController,
              children: _pages,
              onPageChanged: (value) {
                setState(() {
                  _selectedPageIndex = value;
                });
              },
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -4),
                    blurRadius: 5,
                    color: Colors.black.withOpacity(0.25),
                  ),
                ],
              ),
              child: SafeArea(
                child: TitledBottomNavigationBar(
                  enableShadow: false,
                  currentIndex: _selectedPageIndex,
                  onTap: (value) {
                    setState(() {
                      _selectedPageIndex = value;
                      _pageController.animateToPage(value,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.linear);
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                  items: [
                    TitledNavigationBarItem(
                      icon: Icons.home,
                      title: Text('Home'),
                    ),
                    TitledNavigationBarItem(
                      icon: Icons.search,
                      title: Text('Search'),
                    ),
                    TitledNavigationBarItem(
                      icon: Icons.shopping_basket,
                      title: Text('Orders'),
                    ),
                    TitledNavigationBarItem(
                      icon: Icons.chat,
                      title: Text('Chat'),
                    ),
                    TitledNavigationBarItem(
                      icon: Icons.account_circle,
                      title: Text('Account'),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
