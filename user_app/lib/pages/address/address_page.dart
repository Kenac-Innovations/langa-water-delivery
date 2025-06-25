import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/client_address/client_address_bloc.dart';
import 'package:langas_user/bloc/client_address/client_address_event.dart';
import 'package:langas_user/bloc/client_address/client_address_state.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/client_address_model.dart';
import 'package:langas_user/pages/address/add_address_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  int? get _clientId {
    final authState = context.read<AuthBloc>().state;
    return (authState is Authenticated) ? authState.user.userId : null;
  }

  @override
  void initState() {
    super.initState();
    _refreshAddresses();
  }

  void _refreshAddresses() {
    if (_clientId != null) {
      context.read<ClientAddressBloc>().add(FetchClientAddresses(_clientId!));
    }
  }

  void _setAsPreferred(int addressId) {
    if (_clientId != null) {
      context
          .read<ClientAddressBloc>()
          .add(SetDefaultClientAddress(_clientId!, addressId));
    }
  }

  void _deleteAddress(int addressId) {
    context.read<ClientAddressBloc>().add(DeleteClientAddress(addressId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: theme.primary,
        elevation: 1,
        foregroundColor: Colors.white,
        title: const Text('My Addresses',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        actions: [
          IconButton(
              onPressed: _refreshAddresses, icon: const Icon(Icons.refresh))
        ],
      ),
      body: BlocConsumer<ClientAddressBloc, ClientAddressState>(
        listener: (context, state) {
          if (state is ClientAddressOperationSuccess) {
            Fluttertoast.showToast(
                msg: state.message, backgroundColor: Colors.green);
            _refreshAddresses();
          }
          if (state is ClientAddressFailure) {
            Fluttertoast.showToast(
                msg: state.failure.message, backgroundColor: Colors.red);
          }
        },
        builder: (context, state) {
          if (state is ClientAddressLoading &&
              state is! ClientAddressLoadSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ClientAddressLoadSuccess) {
            if (state.addresses.isEmpty) {
              return _buildEmptyState(context);
            }
            final preferredAddress = state.addresses.firstWhere(
                (a) => a.isDefault,
                orElse: () => state.addresses.first);
            final otherAddresses =
                state.addresses.where((a) => !a.isDefault).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preferred',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildAddressListItem(preferredAddress, true, theme),
                  const SizedBox(height: 24),
                  const Text('Others',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (otherAddresses.isEmpty)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No other addresses saved."),
                    )),
                  ListView.separated(
                    itemCount: otherAddresses.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final address = otherAddresses[index];
                      return Dismissible(
                          key: ValueKey(address.entityId),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteAddress(address.entityId),
                          background: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                color: theme.error,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.delete, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          child: _buildAddressListItem(address, false, theme));
                    },
                  ),
                ],
              ),
            );
          }
          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddAddressPage()));
          if (result == true) {
            _refreshAddresses();
          }
        },
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No Saved Addresses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Your saved addresses will appear here."),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add New Address'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              backgroundColor: FlutterFlowTheme.of(context).primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddAddressPage()));
              if (result == true) {
                _refreshAddresses();
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildAddressListItem(
      ClientAddress address, bool isPreferred, FlutterFlowTheme theme) {
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
                    address.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.addressFormatted,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isPreferred)
              Icon(Icons.check_circle, color: theme.primary)
            else
              TextButton(
                onPressed: () => _setAsPreferred(address.entityId),
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
