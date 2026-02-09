import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _courseUpdates = true;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF142132),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive notifications via email'),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                  activeColor: const Color(0xFF25A0DC),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle:
                      const Text('Receive push notifications on your device'),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                  activeColor: const Color(0xFF25A0DC),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Course Updates'),
                  subtitle: const Text('Get notified about course updates'),
                  value: _courseUpdates,
                  onChanged: (value) {
                    setState(() {
                      _courseUpdates = value;
                    });
                  },
                  activeColor: const Color(0xFF25A0DC),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Promotional Offers'),
                  subtitle: const Text('Receive special offers and promotions'),
                  value: _promotions,
                  onChanged: (value) {
                    setState(() {
                      _promotions = value;
                    });
                  },
                  activeColor: const Color(0xFF25A0DC),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
