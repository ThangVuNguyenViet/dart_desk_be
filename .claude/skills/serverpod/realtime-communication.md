# Serverpod Real-Time Communication Reference

## Overview

Serverpod provides WebSocket-enabled Dart streams for real-time communication between server and clients. This enables live data updates, chat applications, notifications, and any feature requiring immediate bidirectional communication.

## Core Concepts

### Streams
Dart streams allow continuous data flow from server to clients.

### WebSockets
Persistent connections that enable real-time bidirectional communication.

### Messages
Structured data sent between server and clients in real-time.

## Setting Up Real-Time Endpoints

### Basic Stream Endpoint

```dart
class RealtimeEndpoint extends Endpoint {
  Stream<String> streamMessages(Session session) async* {
    // Yield messages over time
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(seconds: 1));
      yield 'Message $i';
    }
  }
}
```

### Stream with Custom Objects

```dart
class NotificationEndpoint extends Endpoint {
  Stream<Notification> streamNotifications(
    Session session,
    int userId,
  ) async* {
    // Listen to database changes or message queue
    await for (final notification in _getNotificationStream(userId)) {
      yield notification;
    }
  }

  Stream<Notification> _getNotificationStream(int userId) async* {
    // Implementation: poll database, listen to message queue, etc.
  }
}
```

## Client-Side Usage

### Subscribing to Streams

```dart
// In Flutter client
final stream = client.realtime.streamMessages();

stream.listen((message) {
  print('Received: $message');
});
```

### Handling Stream Events

```dart
StreamSubscription? subscription;

void startListening() {
  subscription = client.notification.streamNotifications(userId).listen(
    (notification) {
      // Handle new notification
      showNotification(notification);
    },
    onError: (error) {
      // Handle errors
      print('Stream error: $error');
    },
    onDone: () {
      // Stream completed
      print('Stream closed');
    },
  );
}

void stopListening() {
  subscription?.cancel();
}
```

## Server-to-Client Messages

### Broadcasting Messages

```dart
class ChatEndpoint extends Endpoint {
  Future<void> sendMessage(
    Session session,
    String roomId,
    String message,
  ) async {
    // Store message in database
    final chatMessage = ChatMessage(
      roomId: roomId,
      userId: session.userId!,
      text: message,
      timestamp: DateTime.now(),
    );
    await ChatMessage.db.insertRow(session, chatMessage);

    // Broadcast to all connected clients in room
    await session.messages.postMessage(
      'chat_room_$roomId',
      chatMessage.toJson(),
    );
  }
}
```

### Targeted Messages

```dart
Future<void> sendPrivateNotification(
  Session session,
  int targetUserId,
  String message,
) async {
  // Send to specific user
  await session.messages.postMessage(
    'user_$targetUserId',
    {'message': message, 'timestamp': DateTime.now()},
  );
}
```

## Message Channels

### Creating Channels

```dart
class ChannelEndpoint extends Endpoint {
  Stream<ChannelMessage> joinChannel(
    Session session,
    String channelName,
  ) async* {
    // Subscribe to channel
    final channel = session.messages.getStream('channel_$channelName');

    await for (final message in channel) {
      yield ChannelMessage.fromJson(message);
    }
  }
}
```

### Publishing to Channels

```dart
Future<void> publishToChannel(
  Session session,
  String channelName,
  Map<String, dynamic> data,
) async {
  await session.messages.postMessage(
    'channel_$channelName',
    data,
  );
}
```

## Real-Time Patterns

### Live Updates Pattern

```dart
class LiveDataEndpoint extends Endpoint {
  Stream<List<Recipe>> watchRecipes(Session session) async* {
    // Initial data
    yield await Recipe.db.find(session);

    // Listen for updates
    final updateStream = session.messages.getStream('recipe_updates');

    await for (final _ in updateStream) {
      // Re-fetch and yield updated data
      yield await Recipe.db.find(session);
    }
  }

  Future<Recipe> createRecipe(Session session, Recipe recipe) async {
    final created = await Recipe.db.insertRow(session, recipe);

    // Notify all watchers
    await session.messages.postMessage('recipe_updates', {});

    return created;
  }
}
```

### Chat Room Pattern

```dart
class ChatRoomEndpoint extends Endpoint {
  Stream<ChatMessage> streamMessages(
    Session session,
    String roomId,
  ) async* {
    if (!session.isUserSignedIn) {
      throw Exception('Authentication required');
    }

    // Send existing messages
    final history = await ChatMessage.db.find(
      session,
      where: (t) => t.roomId.equals(roomId),
      orderBy: (t) => t.timestamp,
      limit: 50,
    );

    for (final message in history) {
      yield message;
    }

    // Stream new messages
    final stream = session.messages.getStream('chat_room_$roomId');

    await for (final data in stream) {
      yield ChatMessage.fromJson(data);
    }
  }

  Future<void> postMessage(
    Session session,
    String roomId,
    String text,
  ) async {
    final message = ChatMessage(
      roomId: roomId,
      userId: session.userId!,
      text: text,
      timestamp: DateTime.now(),
    );

    await ChatMessage.db.insertRow(session, message);
    await session.messages.postMessage(
      'chat_room_$roomId',
      message.toJson(),
    );
  }
}
```

### Live Dashboard Pattern

```dart
class DashboardEndpoint extends Endpoint {
  Stream<DashboardStats> streamStats(Session session) async* {
    while (true) {
      // Compute current statistics
      final stats = await _computeStats(session);
      yield stats;

      // Wait before next update
      await Future.delayed(Duration(seconds: 5));
    }
  }

  Future<DashboardStats> _computeStats(Session session) async {
    final userCount = await User.db.count(session);
    final activeUsers = await User.db.count(
      session,
      where: (t) => t.lastActive.isAfter(
        DateTime.now().subtract(Duration(minutes: 5)),
      ),
    );

    return DashboardStats(
      totalUsers: userCount,
      activeUsers: activeUsers,
      timestamp: DateTime.now(),
    );
  }
}
```

### Notification System Pattern

```dart
class NotificationService extends Endpoint {
  Stream<Notification> streamUserNotifications(Session session) async* {
    final userId = session.userId!;

    // Send unread notifications
    final unread = await Notification.db.find(
      session,
      where: (t) => t.userId.equals(userId) & !t.isRead,
    );

    for (final notification in unread) {
      yield notification;
    }

    // Stream new notifications
    final stream = session.messages.getStream('notifications_$userId');

    await for (final data in stream) {
      yield Notification.fromJson(data);
    }
  }

  Future<void> sendNotification(
    Session session,
    int targetUserId,
    String title,
    String body,
  ) async {
    final notification = Notification(
      userId: targetUserId,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await Notification.db.insertRow(session, notification);
    await session.messages.postMessage(
      'notifications_$targetUserId',
      notification.toJson(),
    );
  }
}
```

## Connection Management

### Client-Side Connection Handling

```dart
class RealtimeManager {
  StreamSubscription? _subscription;
  final Client _client;

  RealtimeManager(this._client);

  void connect(String channelId) {
    _subscription = _client.channel.joinChannel(channelId).listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDisconnect,
    );
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleMessage(ChannelMessage message) {
    // Process incoming message
  }

  void _handleError(error) {
    // Handle connection error
    // Attempt reconnection
    Future.delayed(Duration(seconds: 5), () {
      connect(channelId);
    });
  }

  void _handleDisconnect() {
    // Connection closed
    // Attempt reconnection
  }
}
```

### Automatic Reconnection

```dart
class ResilientStream {
  Stream<Message> connectWithRetry(
    Client client,
    String channelId,
  ) async* {
    while (true) {
      try {
        await for (final message in client.channel.joinChannel(channelId)) {
          yield message;
        }
      } catch (e) {
        // Connection lost, wait and retry
        await Future.delayed(Duration(seconds: 5));
      }
    }
  }
}
```

## Performance Considerations

### Throttling Updates

```dart
Stream<Data> streamThrottled(Session session) async* {
  Data? lastData;
  final minInterval = Duration(milliseconds: 100);

  await for (final data in _rawDataStream(session)) {
    final now = DateTime.now();

    if (lastData == null ||
        now.difference(lastData.timestamp) > minInterval) {
      yield data;
      lastData = data;
    }
  }
}
```

### Batching Messages

```dart
Stream<List<Message>> streamBatched(Session session) async* {
  final batch = <Message>[];
  final batchSize = 10;
  final maxWait = Duration(seconds: 1);
  DateTime? batchStart;

  await for (final message in _messageStream(session)) {
    batch.add(message);
    batchStart ??= DateTime.now();

    if (batch.length >= batchSize ||
        DateTime.now().difference(batchStart) > maxWait) {
      yield List.from(batch);
      batch.clear();
      batchStart = null;
    }
  }
}
```

## Security

### Authentication for Streams

```dart
Stream<SecureData> secureStream(Session session, String resourceId) async* {
  // Verify authentication
  if (!session.isUserSignedIn) {
    throw Exception('Authentication required');
  }

  // Verify authorization
  final hasAccess = await _checkAccess(session, resourceId);
  if (!hasAccess) {
    throw Exception('Unauthorized access');
  }

  // Stream data
  await for (final data in _dataStream(resourceId)) {
    yield data;
  }
}
```

### Rate Limiting

```dart
final _connectionCounts = <int, int>{};

Stream<Data> rateLimitedStream(Session session) async* {
  final userId = session.userId!;
  final currentCount = _connectionCounts[userId] ?? 0;

  if (currentCount >= 5) {
    throw Exception('Too many concurrent connections');
  }

  _connectionCounts[userId] = currentCount + 1;

  try {
    await for (final data in _dataStream(session)) {
      yield data;
    }
  } finally {
    _connectionCounts[userId] = (_connectionCounts[userId] ?? 1) - 1;
  }
}
```

## Best Practices

1. **Clean up streams** - Always cancel subscriptions when done
2. **Handle errors gracefully** - Implement error handling and recovery
3. **Implement reconnection** - Handle connection drops automatically
4. **Throttle updates** - Avoid overwhelming clients with too many messages
5. **Batch when appropriate** - Group related updates
6. **Authenticate streams** - Verify user access to stream data
7. **Rate limit connections** - Prevent abuse
8. **Monitor active connections** - Track and manage WebSocket connections
9. **Use compression** - For large data transfers
10. **Test under load** - Verify performance with many concurrent connections

## Debugging Real-Time Features

### Logging Stream Events

```dart
Stream<Data> debugStream(Session session) async* {
  session.log('Stream started');

  try {
    await for (final data in _dataStream(session)) {
      session.log('Yielding data: $data');
      yield data;
    }
  } catch (e) {
    session.log('Stream error: $e');
    rethrow;
  } finally {
    session.log('Stream closed');
  }
}
```

### Monitoring Active Streams

```dart
class StreamMonitor {
  static final _activeStreams = <String, int>{};

  static void registerStream(String type) {
    _activeStreams[type] = (_activeStreams[type] ?? 0) + 1;
  }

  static void unregisterStream(String type) {
    _activeStreams[type] = (_activeStreams[type] ?? 1) - 1;
  }

  static Map<String, int> getActiveStreams() => Map.from(_activeStreams);
}
```
