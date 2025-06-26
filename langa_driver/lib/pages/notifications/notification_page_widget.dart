import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/notification/notification_bloc_bloc.dart';
import 'package:langas_driver/bloc/notification/notification_bloc_event.dart';
import 'package:langas_driver/bloc/notification/notification_bloc_state.dart';
import 'package:langas_driver/dto/notification_dto.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_util.dart';
import 'package:langas_driver/models/notification_model.dart';
import 'package:langas_driver/utils/app_enums.dart' as app_enums;

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;
  final ScrollController _scrollController = ScrollController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthDriverAuthenticated) {
      _userId = authState.authData.driverProfile?.userId.toString() ??
          authState.authData.userID.toString();
      if (_userId != null) {
        context
            .read<NotificationBloc>()
            .add(FetchUserNotifications(userId: _userId!));
        context
            .read<NotificationBloc>()
            .add(FetchUnreadNotificationCount(userId: _userId!));
      }
    }

    _scrollController.addListener(_onScroll);
    _fadeController.forward();
  }

  void _onScroll() {
    if (_isBottom && _userId != null) {
      final notificationBloc = context.read<NotificationBloc>();
      final currentState = notificationBloc.state;
      if (currentState is NotificationListLoadSuccess &&
          !currentState.hasReachedMax) {
        notificationBloc.add(FetchMoreUserNotifications(userId: _userId!));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _markAsRead(NotificationModel notification) {
    if (!notification.read && _userId != null) {
      context.read<NotificationBloc>().add(
            UpdateNotificationStatusRequested(
              request: UpdateNotificationStatusRequest(
                notificationId: notification.id,
                read: true,
              ),
            ),
          );
    }
  }

  void _deleteNotification(String notificationId) {
    if (_userId != null) {
      context
          .read<NotificationBloc>()
          .add(DeleteNotificationRequested(notificationId: notificationId));
    }
  }

  void _markAllAsRead() {
    if (_userId != null) {
      context
          .read<NotificationBloc>()
          .add(MarkAllNotificationsAsReadRequested(userId: _userId!));
    }
  }

  Future<void> _refreshNotifications() async {
    if (_userId != null) {
      context
          .read<NotificationBloc>()
          .add(FetchUserNotifications(userId: _userId!, isRefresh: true));
      context
          .read<NotificationBloc>()
          .add(FetchUnreadNotificationCount(userId: _userId!));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: _buildAppBar(),
        body: SafeArea(
          top: true,
          child: FadeTransition(
            opacity: _fadeController,
            child: BlocConsumer<NotificationBloc, NotificationState>(
              listener: (context, state) {
                if (state is NotificationUpdateFailure ||
                    state is NotificationMarkAllReadFailure ||
                    state is NotificationDeleteFailure ||
                    state is NotificationListLoadFailure ||
                    state is NotificationUnreadCountLoadFailure) {
                  final failure = (state as dynamic).failure;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(failure.message ?? 'An error occurred'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state is NotificationDeleteSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _refreshNotifications();
                }
                if (state is NotificationUpdateSuccess ||
                    state is NotificationMarkAllReadSuccess) {
                  _refreshNotifications();
                }
              },
              builder: (context, state) {
                if (state is NotificationListLoading &&
                    state is! NotificationListLoadingNextPage) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is NotificationListLoadSuccess) {
                  if (state.notifications.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: _refreshNotifications,
                    child: _buildNotificationList(state),
                  );
                }
                if (state is NotificationListLoadFailure) {
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "Failed to load notifications: ${state.failure.message}"),
                      ElevatedButton(
                          onPressed: _refreshNotifications,
                          child: const Text("Retry"))
                    ],
                  ));
                }
                return _buildEmptyState();
              },
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: FlutterFlowTheme.of(context).primary,
      automaticallyImplyLeading: false,
      leading: FlutterFlowIconButton(
        borderColor: Colors.transparent,
        borderRadius: 30.0,
        borderWidth: 1.0,
        buttonSize: 60.0,
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: 32.0,
        ),
        onPressed: () async {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'Notifications',
        style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          onSelected: (value) {
            if (value == 'mark_all_read') {
              _markAllAsRead();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'mark_all_read',
              child: Text('Mark all as read'),
            ),
          ],
        ),
      ],
      centerTitle: true,
      elevation: 2.0,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade600,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'You\'ll see your notifications here when there are updates',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(NotificationListLoadSuccess state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      itemCount: state.hasReachedMax
          ? state.notifications.length
          : state.notifications.length + 1,
      itemBuilder: (context, index) {
        if (index >= state.notifications.length) {
          if (context.watch<NotificationBloc>().state
              is NotificationListLoadingNextPage) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator()));
          } else if (context.watch<NotificationBloc>().state
              is NotificationListNextPageError) {
            final errorState = context.watch<NotificationBloc>().state
                as NotificationListNextPageError;
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                        'Error loading more: ${errorState.failure.message}')));
          }
          return const SizedBox.shrink();
        }
        final notification = state.notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  IconData _getIconForNotificationType(app_enums.NotificationType type) {
    switch (type) {
      case app_enums.NotificationType.WARNING:
        return Icons.warning_amber_rounded;
      case app_enums.NotificationType.INFO:
        return Icons.info_outline;
      case app_enums.NotificationType.PROMOTIONAL:
        return Icons.local_offer_outlined;
      case app_enums.NotificationType.EXCEPTION:
        return Icons.error_outline;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getIconColorForNotificationType(
      app_enums.NotificationType type, BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    switch (type) {
      case app_enums.NotificationType.WARNING:
        return theme.warning;
      case app_enums.NotificationType.INFO:
        return theme.primary;
      case app_enums.NotificationType.PROMOTIONAL:
        return theme.success;
      case app_enums.NotificationType.EXCEPTION:
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    String timeText;
    final now = DateTime.now();
    if (notification.createdAt == null) {
      timeText = "Recently";
    } else {
      final difference = now.difference(notification.createdAt!);
      if (difference.inMinutes < 1) {
        timeText = 'Just now';
      } else if (difference.inMinutes < 60) {
        timeText = '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        timeText = '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        timeText = '${difference.inDays}d ago';
      } else {
        timeText = DateFormat('MMM d').format(notification.createdAt!);
      }
    }

    IconData iconData =
        _getIconForNotificationType(notification.notificationType);
    Color iconColor = _getIconColorForNotificationType(
        notification.notificationType, context);

    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification.id.toString());
      },
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: FlutterFlowTheme.of(context).secondaryBackground,
        elevation: notification.read ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: notification.read
                ? Colors.grey.shade300
                : FlutterFlowTheme.of(context).primary.withOpacity(0.7),
            width: notification.read ? 0.5 : 1.5,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: () {
            _markAsRead(notification);
            _showNotificationDetail(notification);
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                      fontFamily: 'Poppins',
                                      fontWeight: notification.read
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeText,
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                    fontFamily: 'Poppins',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Poppins',
                              color: notification.read
                                  ? FlutterFlowTheme.of(context).secondaryText
                                  : FlutterFlowTheme.of(context).primaryText,
                              fontSize: 13,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!notification.read)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(NotificationModel notification) {
    IconData iconData =
        _getIconForNotificationType(notification.notificationType);
    Color iconColor = _getIconColorForNotificationType(
        notification.notificationType, context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: FlutterFlowTheme.of(context)
                              .titleLarge
                              .override(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18),
                        ),
                        Text(
                          notification.createdAt != null
                              ? DateFormat('MMMM d, yyyy • hh:mm a')
                                  .format(notification.createdAt!)
                              : "Date N/A",
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                    fontSize: 14,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
