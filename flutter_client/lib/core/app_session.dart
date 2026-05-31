// feito por ???

class AppSession {
  AppSession._();

  static final AppSession instance = AppSession._();

  bool _isAccessGranted = false;

  bool get isAccessGranted => _isAccessGranted;

  void grantAccess() {
    _isAccessGranted = true;
  }

  void revokeAccess() {
    _isAccessGranted = false;
  }
}
