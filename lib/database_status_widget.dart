import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'food_item.dart';

class DatabaseStatusWidget extends StatefulWidget {
  @override
  _DatabaseStatusWidgetState createState() => _DatabaseStatusWidgetState();
}

class _DatabaseStatusWidgetState extends State<DatabaseStatusWidget> {
  bool _isConnected = false;
  bool _isLoading = false;
  String _statusMessage = 'Checking connection...';
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _checkDatabaseConnection();
  }

  Future<void> _checkDatabaseConnection() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking database connection...';
    });

    try {
      // Try to get items from database
      final items = await FirebaseService.getFoodItems();

      if (mounted) {
        setState(() {
          _isConnected = true;
          _isLoading = false;
          _totalItems = items.length;
          _statusMessage = 'Connected to Firebase Database';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isLoading = false;
          _statusMessage = 'Database connection failed: $e';
        });
      }
    }
  }

  Future<void> _testDatabaseOperations() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing database operations...';
    });

    try {
      // Test 1: Add a test item
      final testItem = FoodItem(
        name: 'Database Test Item',
        expiryDate: DateTime.now().add(Duration(days: 30)),
        location: 'Test Location',
      );

      await FirebaseService.addFoodItem(testItem);

      // Test 2: Retrieve items
      final items = await FirebaseService.getFoodItems();

      // Test 3: Get expiring soon items
      final expiringSoon = await FirebaseService.getExpiringSoonItems();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _totalItems = items.length;
          _statusMessage =
              '✅ All database operations successful!\n'
              '• Write: ✅\n'
              '• Read: ✅\n'
              '• Query: ✅\n'
              '• Total items: $_totalItems\n'
              '• Expiring soon: ${expiringSoon.length}';
        });
      }

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Database Test Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Database is fully functional!'),
              SizedBox(height: 16),
              Text('Operations tested:'),
              Text('• Add food items: ✅'),
              Text('• Read food items: ✅'),
              Text('• Query expiring items: ✅'),
              SizedBox(height: 8),
              Text('Total items in database: $_totalItems'),
              Text('Items expiring soon: ${expiringSoon.length}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = '❌ Database test failed: $e';
        });
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Database Test Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('❌ Database operations failed'),
              SizedBox(height: 8),
              Text('Error: $e'),
              SizedBox(height: 16),
              Text('Please check:'),
              Text('• Internet connection'),
              Text('• Firebase configuration'),
              Text('• Database rules'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Database Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_isLoading)
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(_statusMessage),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _isConnected
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_isConnected) ...[
                    SizedBox(height: 8),
                    Text(
                      'Total items: $_totalItems',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _checkDatabaseConnection,
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testDatabaseOperations,
                  icon: Icon(Icons.play_arrow),
                  label: Text('Test Operations'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
