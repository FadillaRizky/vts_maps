import 'package:flutter/material.dart';
import 'package:vts_maps/vessel_list.dart';

import 'home.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  void _onSidebarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildContentView() {
    switch (_selectedIndex) {
      case 0:
        return HomeWidget();
      case 1:
        return Vessel();
      case 2:
        return SettingsWidget();
      default:
        return Home();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Container(
          width: 250,
          color: Colors.blueGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Dashboard Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // SidebarItem(
              //   icon: Icons.home,
              //   title: 'Home',
              //   isSelected: true,
              //   ontap: () {
              //     _onSidebarItemTapped(0);
              //   },
              // ),
              // SidebarItem(
              //   icon: Icons.analytics,
              //   title: 'Vessel',
              //   ontap: () {
              //     _onSidebarItemTapped(1);
              //   },
              // ),
              // SidebarItem(
              //   icon: Icons.settings,
              //   title: 'Settings',
              //   ontap: () {
              //     _onSidebarItemTapped(2);
              //   },
              // ),
              DashboardMenu(
                selectedIndex: _selectedIndex,
                index: 0,
                title: 'Home',
                icon: Icons.home,
                ontap: () {
                  _onSidebarItemTapped(0);
                },
              ),
              DashboardMenu(
                  selectedIndex: _selectedIndex,
                  index: 1,
                  title: 'Vessel',
                  icon: Icons.local_shipping_outlined,
                  ontap: () {
                    _onSidebarItemTapped(1);
                  }),
              DashboardMenu(
                  selectedIndex: _selectedIndex,
                  index: 2,
                  title: 'Setting',
                  icon: Icons.settings,
                  ontap: () {
                    _onSidebarItemTapped(2);
                  }),
            ],
          ),
        ),
        Expanded(
          child: buildContentView(),
        )
      ]),
    );
  }
}

class DashboardMenu extends StatelessWidget {
  const DashboardMenu({
    super.key,
    required int selectedIndex,
    required this.index,
    required this.title,
    required this.icon,
    required this.ontap,
  }) : _selectedIndex = selectedIndex;

  final int _selectedIndex;
  final int index;
  final String title;
  final IconData icon;
  final VoidCallback ontap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? Colors.white : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? Colors.white : Colors.grey,
        ),
      ),
      onTap: ontap,
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback ontap;

  SidebarItem(
      {required this.icon,
      required this.title,
      this.isSelected = false,
      required this.ontap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
      onTap: ontap,
    );
  }
}

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Content'),
    );
  }
}

class AnalyticsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Analytics Content'),
    );
  }
}

class SettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Settings Content'),
    );
  }
}
