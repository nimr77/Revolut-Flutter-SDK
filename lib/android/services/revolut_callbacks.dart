import '../models/revolut_pay_models.dart';

typedef BannerInteractionCallback =
    void Function(
      String bannerId,
      String interactionType,
      Map<String, dynamic> data,
    );
typedef ButtonClickCallback =
    void Function(String buttonId, String? orderToken);
typedef ConfigurationUpdateCallback =
    void Function(String configType, Map<String, dynamic> data);
typedef ControllerStateChangeCallback =
    void Function(String controllerId, String state, Map<String, dynamic> data);
typedef DebugLogCallback =
    void Function(String level, String message, Map<String, dynamic> data);
typedef DeepLinkCallback = void Function(String uri, Map<String, dynamic> data);
typedef LifecycleEventCallback =
    void Function(String event, Map<String, dynamic> data);
typedef NetworkStatusCallback =
    void Function(bool isOnline, Map<String, dynamic> data);

/// Callback types for Revolut Pay SDK events
typedef OrderCompletedCallback = void Function(OrderResultData result);
typedef OrderFailedCallback = void Function(OrderResultData result);
typedef PaymentStatusUpdateCallback =
    void Function(String status, Map<String, dynamic> data);
typedef PerformanceMetricCallback =
    void Function(
      String metricName,
      double value,
      String unit,
      Map<String, dynamic> data,
    );
typedef SessionEventCallback =
    void Function(
      String eventType,
      String sessionId,
      Map<String, dynamic> data,
    );
typedef UserInteractionCallback =
    void Function(
      String interactionType,
      String elementId,
      Map<String, dynamic> data,
    );
typedef UserPaymentAbandonedCallback = void Function(OrderResultData result);

/// Service class that manages all Revolut Pay SDK callbacks
class RevolutCallbacks {
  OrderCompletedCallback? onOrderCompleted;
  OrderFailedCallback? onOrderFailed;
  UserPaymentAbandonedCallback? onUserPaymentAbandoned;
  PaymentStatusUpdateCallback? onPaymentStatusUpdate;
  ButtonClickCallback? onButtonClick;
  ControllerStateChangeCallback? onControllerStateChange;
  BannerInteractionCallback? onBannerInteraction;
  LifecycleEventCallback? onLifecycleEvent;
  DeepLinkCallback? onDeepLinkReceived;
  NetworkStatusCallback? onNetworkStatusUpdate;
  ConfigurationUpdateCallback? onConfigurationUpdate;
  DebugLogCallback? onDebugLog;
  PerformanceMetricCallback? onPerformanceMetric;
  UserInteractionCallback? onUserInteraction;
  SessionEventCallback? onSessionEvent;

  /// Clears all callbacks
  void clearCallbacks() {
    onOrderCompleted = null;
    onOrderFailed = null;
    onUserPaymentAbandoned = null;
    onPaymentStatusUpdate = null;
    onButtonClick = null;
    onControllerStateChange = null;
    onBannerInteraction = null;
    onLifecycleEvent = null;
    onDeepLinkReceived = null;
    onNetworkStatusUpdate = null;
    onConfigurationUpdate = null;
    onDebugLog = null;
    onPerformanceMetric = null;
    onUserInteraction = null;
    onSessionEvent = null;
  }

  /// Handles banner interaction event from native side
  void handleBannerInteraction(Map<String, dynamic> data) {
    final bannerId = data['bannerId'] as String? ?? '';
    final interactionType = data['interactionType'] as String? ?? '';
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('bannerId');
    additionalData.remove('interactionType');
    onBannerInteraction?.call(bannerId, interactionType, additionalData);
  }

  /// Handles button click event from native side
  void handleButtonClick(Map<String, dynamic> data) {
    final buttonId = data['buttonId'] as String? ?? '';
    final orderToken = data['orderToken'] as String?;
    onButtonClick?.call(buttonId, orderToken);
  }

  /// Handles configuration update event from native side
  void handleConfigurationUpdate(Map<String, dynamic> data) {
    final configType = data['configType'] as String? ?? '';
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('configType');
    onConfigurationUpdate?.call(configType, additionalData);
  }

  /// Handles controller state change event from native side
  void handleControllerStateChange(Map<String, dynamic> data) {
    final controllerId = data['controllerId'] as String? ?? '';
    final state = data['state'] as String? ?? '';
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('controllerId');
    additionalData.remove('state');
    onControllerStateChange?.call(controllerId, state, additionalData);
  }

  /// Handles debug log event from native side
  void handleDebugLog(Map<String, dynamic> data) {
    final level = data['level'] as String? ?? '';
    final message = data['message'] as String? ?? '';
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('level');
    additionalData.remove('message');
    onDebugLog?.call(level, message, additionalData);
  }

  /// Handles deep link event from native side
  void handleDeepLinkEvent(Map<String, dynamic> data) {
    final uri = data['uri'] as String? ?? '';
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('uri');
    onDeepLinkReceived?.call(uri, additionalData);
  }

  /// Handles lifecycle event from native side
  void handleLifecycleEvent(Map<String, dynamic> data) {
    final event = data['event'] as String? ?? '';
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('event');
    onLifecycleEvent?.call(event, additionalData);
  }

  /// Handles network status update event from native side
  void handleNetworkStatusUpdate(Map<String, dynamic> data) {
    final isOnline = data['isOnline'] as bool? ?? false;
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('isOnline');
    onNetworkStatusUpdate?.call(isOnline, additionalData);
  }

  /// Handles order completed event from native side
  void handleOrderCompleted(Map<String, dynamic> data) {
    final result = OrderResultData.fromMap(data);
    onOrderCompleted?.call(result);
  }

  /// Handles order failed event from native side
  void handleOrderFailed(Map<String, dynamic> data) {
    final result = OrderResultData.fromMap(data);
    onOrderFailed?.call(result);
  }

  /// Handles payment status update event from native side
  void handlePaymentStatusUpdate(Map<String, dynamic> data) {
    final status = data['status'] as String? ?? '';
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('status');
    onPaymentStatusUpdate?.call(status, additionalData);
  }

  /// Handles performance metric event from native side
  void handlePerformanceMetric(Map<String, dynamic> data) {
    final metricName = data['metricName'] as String? ?? '';
    final value = (data['value'] as num?)?.toDouble() ?? 0.0;
    final unit = data['unit'] as String? ?? '';
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('metricName');
    additionalData.remove('value');
    additionalData.remove('unit');
    onPerformanceMetric?.call(metricName, value, unit, additionalData);
  }

  /// Handles session event from native side
  void handleSessionEvent(Map<String, dynamic> data) {
    final eventType = data['eventType'] as String? ?? '';
    final sessionId = data['sessionId'] as String? ?? '';
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('eventType');
    additionalData.remove('sessionId');
    onSessionEvent?.call(eventType, sessionId, additionalData);
  }

  /// Handles user interaction event from native side
  void handleUserInteraction(Map<String, dynamic> data) {
    final interactionType = data['interactionType'] as String? ?? '';
    final elementId = data['elementId'] as String? ?? '';
    final additionalData = Map<String, dynamic>.from(data);
    additionalData.remove('interactionType');
    additionalData.remove('elementId');
    onUserInteraction?.call(interactionType, elementId, additionalData);
  }

  /// Handles user payment abandoned event from native side
  void handleUserPaymentAbandoned(Map<String, dynamic> data) {
    final result = OrderResultData.fromMap(data);
    onUserPaymentAbandoned?.call(result);
  }

  /// Sets the banner interaction callback
  void setBannerInteractionCallback(BannerInteractionCallback callback) {
    onBannerInteraction = callback;
  }

  /// Sets the button click callback
  void setButtonClickCallback(ButtonClickCallback callback) {
    onButtonClick = callback;
  }

  /// Sets the configuration update callback
  void setConfigurationUpdateCallback(ConfigurationUpdateCallback callback) {
    onConfigurationUpdate = callback;
  }

  /// Sets the controller state change callback
  void setControllerStateChangeCallback(
    ControllerStateChangeCallback callback,
  ) {
    onControllerStateChange = callback;
  }

  /// Sets the debug log callback
  void setDebugLogCallback(DebugLogCallback callback) {
    onDebugLog = callback;
  }

  /// Sets the deep link callback
  void setDeepLinkCallback(DeepLinkCallback callback) {
    onDeepLinkReceived = callback;
  }

  /// Sets the lifecycle event callback
  void setLifecycleEventCallback(LifecycleEventCallback callback) {
    onLifecycleEvent = callback;
  }

  /// Sets the network status callback
  void setNetworkStatusCallback(NetworkStatusCallback callback) {
    onNetworkStatusUpdate = callback;
  }

  /// Sets the order completed callback
  void setOrderCompletedCallback(OrderCompletedCallback callback) {
    onOrderCompleted = callback;
  }

  /// Sets the order failed callback
  void setOrderFailedCallback(OrderFailedCallback callback) {
    onOrderFailed = callback;
  }

  /// Sets the payment status update callback
  void setPaymentStatusUpdateCallback(PaymentStatusUpdateCallback callback) {
    onPaymentStatusUpdate = callback;
  }

  /// Sets the performance metric callback
  void setPerformanceMetricCallback(PerformanceMetricCallback callback) {
    onPerformanceMetric = callback;
  }

  /// Sets the session event callback
  void setSessionEventCallback(SessionEventCallback callback) {
    onSessionEvent = callback;
  }

  /// Sets the user interaction callback
  void setUserInteractionCallback(UserInteractionCallback callback) {
    onUserInteraction = callback;
  }

  /// Sets the user payment abandoned callback
  void setUserPaymentAbandonedCallback(UserPaymentAbandonedCallback callback) {
    onUserPaymentAbandoned = callback;
  }
}
