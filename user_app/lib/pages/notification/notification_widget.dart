import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/notification/notification_bloc_bloc.dart';
import 'package:langas_user/bloc/notification/notification_bloc_event.dart';
import 'package:langas_user/bloc/notification/notification_bloc_state.dart';
import 'package:langas_user/dto/notifications_dto.dart';
import 'package:langas_user/models/notifications_model.dart';
import 'package:langas_user/models/user_model.dart';
import 'package:langas_user/util/apps_enums.dart' show NotificationType;

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;
  User? _currentUser;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isLastPage = false;
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollController.addListener(_onScroll);
    _fetchCurrentUserAndNotifications(isRefresh: true);
    _fadeController.forward();
  }

  void _fetchCurrentUserAndNotifications({bool isRefresh = false}) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUser = authState.user;
      if (_currentUser != null) {
        if (isRefresh) {
          _currentPage = 1;
          _isLastPage = false;
          _notifications = [];
        }
        context.read<NotificationBloc>().add(FetchNotifications(
            userId: _currentUser!.userId,
            pageNumber: _currentPage,
            pageSize: _pageSize));
        context
            .read<NotificationBloc>()
            .add(FetchUnreadNotificationCount(userId: _currentUser!.userId));
      }
    } else {
      Fluttertoast.showToast(msg: "User not authenticated!");
      if (mounted && context.canPop()) {
        context.pop();
      } else {
        context.goNamed('LoginScreen');
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        !_isLastPage) {
      if (_currentUser != null) {
        context.read<NotificationBloc>().add(FetchNotifications(
            userId: _currentUser!.userId,
            pageNumber: _currentPage + 1,
            pageSize: _pageSize));
      }
    }
  }

  void _handleMarkAsRead(NotificationModel notification) {
    if (!notification.read) {
      context.read<NotificationBloc>().add(UpdateNotificationStatusEvent(
          requestDto: UpdateNotificationStatusRequestDto(
              notificationId: notification.id, read: true)));
    }
  }

  void _handleDeleteNotification(int notificationId) {
    if (_currentUser != null) {
      context
          .read<NotificationBloc>()
          .add(DeleteNotificationByIdEvent(notificationId: notificationId));
    }
  }

  void _handleMarkAllAsRead() {
    if (_currentUser != null) {
      context
          .read<NotificationBloc>()
          .add(MarkAllNotificationsAsReadEvent(userId: _currentUser!.userId));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
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

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: true,
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationLoading && _notifications.isEmpty) {
              setState(() {
                _isLoading = true;
              });
            } else if (state is NotificationLoading &&
                _notifications.isNotEmpty) {
              setState(() {
                _isLoading = true;
              });
            } else {
              setState(() {
                _isLoading = false;
              });
            }

            if (state is NotificationsLoadSuccess) {
              final newNotifications = state.notifications.content;
              setState(() {
                _currentPage = state.notifications.pagination.pageNumber;
                _isLastPage = (_currentPage + 1) >=
                    state.notifications.pagination.totalPages;

                final uniqueNewNotifications = newNotifications
                    .where((newNotif) => !_notifications.any(
                        (existingNotif) => existingNotif.id == newNotif.id))
                    .toList();
                _notifications.addAll(uniqueNewNotifications);
              });
            } else if (state is NotificationUpdateSuccess) {
              final index = _notifications
                  .indexWhere((n) => n.id == state.notification.id);
              if (index != -1) {
                setState(() {
                  _notifications[index] = state.notification;
                });
              }
              if (_currentUser != null) {
                context.read<NotificationBloc>().add(
                    FetchUnreadNotificationCount(userId: _currentUser!.userId));
              }
            } else if (state is MarkAllReadSuccess) {
              Fluttertoast.showToast(
                  msg: state.message, backgroundColor: Colors.green);
              _fetchCurrentUserAndNotifications(isRefresh: true);
            } else if (state is NotificationDeleteSuccess) {
              Fluttertoast.showToast(
                  msg: state.message, backgroundColor: Colors.green);
              setState(() {
                _notifications
                    .removeWhere((n) => n.id == state.deletedNotificationId);
              });
              if (_currentUser != null) {
                context.read<NotificationBloc>().add(
                    FetchUnreadNotificationCount(userId: _currentUser!.userId));
              }
            } else if (state is UnreadCountSuccess) {
              setState(() {
                _unreadCount = state.count;
              });
            } else if (state is NotificationOperationFailure) {
              Fluttertoast.showToast(
                  msg: "Error: ${state.failure.message}",
                  backgroundColor: Colors.red);
            }
          },
          builder: (context, state) {
            return FadeTransition(
              opacity: _fadeController,
              child: _isLoading && _notifications.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                      color: FlutterFlowTheme.of(context).primary,
                    ))
                  : _notifications.isEmpty
                      ? _buildEmptyState()
                      : _buildNotificationList(),
            );
          },
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
          context.pop();
        },
      ),
      title: Text(
        'NOTIFICATIONS ($_unreadCount unread)',
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
              _handleMarkAllAsRead();
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

  Widget _buildNotificationList() {
    return RefreshIndicator(
      onRefresh: () async {
        _fetchCurrentUserAndNotifications(isRefresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        itemCount: _notifications.length + (_isLoading && !_isLastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  IconData _getIconForNotificationType(NotificationType type) {
    switch (type) {
      case NotificationType.INFO:
        return Icons.info_outline_rounded;
      case NotificationType.PROMOTIONAL:
        return Icons.local_offer_outlined;
      case NotificationType.WARNING:
        return Icons.warning_amber_rounded;
      case NotificationType.EXCEPTION:
        return Icons.error_outline_rounded;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getColorForNotificationType(
      NotificationType type, BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    switch (type) {
      case NotificationType.INFO:
        return theme.primary;
      case NotificationType.PROMOTIONAL:
        return theme.success;
      case NotificationType.WARNING:
        return theme.warning;
      case NotificationType.EXCEPTION:
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    String timeText;
    final now = DateTime.now();
    final difference = now.difference(notification.createdAt.toLocal());

    if (difference.inMinutes < 1) {
      timeText = 'Just now';
    } else if (difference.inMinutes < 60) {
      timeText = '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      timeText =
          '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      timeText =
          '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      timeText = DateFormat('MMM d').format(notification.createdAt.toLocal());
    }

    Color iconColor =
        _getColorForNotificationType(notification.notificationType, context);
    IconData iconData =
        _getIconForNotificationType(notification.notificationType);

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
        _handleDeleteNotification(notification.id);
      },
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: FlutterFlowTheme.of(context).secondaryBackground,
        elevation: notification.read ? 1 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: notification.read
                ? Colors.transparent
                : FlutterFlowTheme.of(context).primary.withOpacity(0.5),
            width: notification.read ? 0 : 1,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () {
            _handleMarkAsRead(notification);
            _showNotificationDetail(notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 20,
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
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: notification.read
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeText,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Poppins',
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!notification.read)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            shape: BoxShape.circle,
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
    Color iconColor =
        _getColorForNotificationType(notification.notificationType, context);
    IconData iconData =
        _getIconForNotificationType(notification.notificationType);

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
                          DateFormat('MMMM d, yyyy • h:mm a')
                              .format(notification.createdAt.toLocal()),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
}
