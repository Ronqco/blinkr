class RateLimiter {
  final Map<String, DateTime> _lastCalls = {};
  final Duration cooldown;
  
  RateLimiter({required this.cooldown});
  
  bool canExecute(String key) {
    final lastCall = _lastCalls[key];
    if (lastCall == null) {
      _lastCalls[key] = DateTime.now();
      return true;
    }
    
    final timeSinceLastCall = DateTime.now().difference(lastCall);
    if (timeSinceLastCall >= cooldown) {
      _lastCalls[key] = DateTime.now();
      return true;
    }
    
    return false;
  }
  
  Duration timeUntilNextCall(String key) {
    final lastCall = _lastCalls[key];
    if (lastCall == null) return Duration.zero;
    
    final timeSinceLastCall = DateTime.now().difference(lastCall);
    final remaining = cooldown - timeSinceLastCall;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
