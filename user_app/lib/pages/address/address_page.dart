import 'package:flutter/material.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/pages/address/add_address_page.dart';

class AddressModel {
  final int id;
  final String nickname;
  final String fullAddress;
  bool isPreferred;

  AddressModel({
    required this.id,
    required this.nickname,
    required this.fullAddress,
    this.isPreferred = false,
  });
}

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final List<AddressModel> _addresses = [
    AddressModel(
        id: 1,
        nickname: 'Home',
        fullAddress: 'Apt 4B, Springfield, IL 62704',
        isPreferred: true),
    AddressModel(
        id: 2, nickname: 'Work', fullAddress: 'Unit 2C, Springfield, IL 62704'),
    AddressModel(
        id: 3,
        nickname: 'Vacation Home',
        fullAddress: 'Unit 2C, Springfield, IL 62704'),
  ];

  void _setAsPreferred(int addressId) {
    setState(() {
      for (var address in _addresses) {
        address.isPreferred = address.id == addressId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final preferredAddress = _addresses.firstWhere((addr) => addr.isPreferred,
        orElse: () => _addresses.first);
    final otherAddresses =
        _addresses.where((addr) => !addr.isPreferred).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: theme.primary,
        elevation: 1,
        foregroundColor: Colors.white,
        title: const Text('My Addresses',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferred',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildAddressListItem(preferredAddress, true, theme),
            const SizedBox(height: 24),
            const Text(
              'Others',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              itemCount: otherAddresses.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildAddressListItem(
                    otherAddresses[index], false, theme);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddAddressPage()));
        },
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAddressListItem(
      AddressModel address, bool isPreferred, FlutterFlowTheme theme) {
    return Card(
      elevation: 0,
      color:
          isPreferred ? theme.primary.withOpacity(0.05) : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPreferred
            ? BorderSide(color: theme.primary.withOpacity(0.3))
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPreferred
                    ? theme.primary.withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.home_outlined,
                  size: 24,
                  color: isPreferred ? theme.primary : Colors.black54),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.nickname,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (isPreferred)
              Icon(Icons.check_circle, color: theme.primary)
            else
              TextButton(
                onPressed: () => _setAsPreferred(address.id),
                child: Text(
                  'Set as Preferred',
                  style: TextStyle(
                      color: theme.primary, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
