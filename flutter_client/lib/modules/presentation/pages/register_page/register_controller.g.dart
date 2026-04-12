// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegisterController on _RegisterControllerBase, Store {
  Computed<bool>? _$hasMinLengthComputed;

  @override
  bool get hasMinLength => (_$hasMinLengthComputed ??= Computed<bool>(
    () => super.hasMinLength,
    name: '_RegisterControllerBase.hasMinLength',
  )).value;
  Computed<bool>? _$hasUpperAndLowerComputed;

  @override
  bool get hasUpperAndLower => (_$hasUpperAndLowerComputed ??= Computed<bool>(
    () => super.hasUpperAndLower,
    name: '_RegisterControllerBase.hasUpperAndLower',
  )).value;
  Computed<bool>? _$hasNumberOrSymbolComputed;

  @override
  bool get hasNumberOrSymbol => (_$hasNumberOrSymbolComputed ??= Computed<bool>(
    () => super.hasNumberOrSymbol,
    name: '_RegisterControllerBase.hasNumberOrSymbol',
  )).value;
  Computed<bool>? _$isFormValidComputed;

  @override
  bool get isFormValid => (_$isFormValidComputed ??= Computed<bool>(
    () => super.isFormValid,
    name: '_RegisterControllerBase.isFormValid',
  )).value;

  late final _$fullNameAtom = Atom(
    name: '_RegisterControllerBase.fullName',
    context: context,
  );

  @override
  String get fullName {
    _$fullNameAtom.reportRead();
    return super.fullName;
  }

  @override
  set fullName(String value) {
    _$fullNameAtom.reportWrite(value, super.fullName, () {
      super.fullName = value;
    });
  }

  late final _$phoneAtom = Atom(
    name: '_RegisterControllerBase.phone',
    context: context,
  );

  @override
  String get phone {
    _$phoneAtom.reportRead();
    return super.phone;
  }

  @override
  set phone(String value) {
    _$phoneAtom.reportWrite(value, super.phone, () {
      super.phone = value;
    });
  }

  late final _$emailAtom = Atom(
    name: '_RegisterControllerBase.email',
    context: context,
  );

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$passwordAtom = Atom(
    name: '_RegisterControllerBase.password',
    context: context,
  );

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  late final _$documentAtom = Atom(
    name: '_RegisterControllerBase.document',
    context: context,
  );

  @override
  String get document {
    _$documentAtom.reportRead();
    return super.document;
  }

  @override
  set document(String value) {
    _$documentAtom.reportWrite(value, super.document, () {
      super.document = value;
    });
  }

  late final _$obscurePasswordAtom = Atom(
    name: '_RegisterControllerBase.obscurePassword',
    context: context,
  );

  @override
  bool get obscurePassword {
    _$obscurePasswordAtom.reportRead();
    return super.obscurePassword;
  }

  @override
  set obscurePassword(bool value) {
    _$obscurePasswordAtom.reportWrite(value, super.obscurePassword, () {
      super.obscurePassword = value;
    });
  }

  late final _$_RegisterControllerBaseActionController = ActionController(
    name: '_RegisterControllerBase',
    context: context,
  );

  @override
  void setFullName(String value) {
    final _$actionInfo = _$_RegisterControllerBaseActionController.startAction(
      name: '_RegisterControllerBase.setFullName',
    );
    try {
      return super.setFullName(value);
    } finally {
      _$_RegisterControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPhone(String value) {
    final _$actionInfo = _$_RegisterControllerBaseActionController.startAction(
      name: '_RegisterControllerBase.setPhone',
    );
    try {
      return super.setPhone(value);
    } finally {
      _$_RegisterControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEmail(String value) {
    final _$actionInfo = _$_RegisterControllerBaseActionController.startAction(
      name: '_RegisterControllerBase.setEmail',
    );
    try {
      return super.setEmail(value);
    } finally {
      _$_RegisterControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPassword(String value) {
    final _$actionInfo = _$_RegisterControllerBaseActionController.startAction(
      name: '_RegisterControllerBase.setPassword',
    );
    try {
      return super.setPassword(value);
    } finally {
      _$_RegisterControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDocument(String value) {
    final _$actionInfo = _$_RegisterControllerBaseActionController.startAction(
      name: '_RegisterControllerBase.setDocument',
    );
    try {
      return super.setDocument(value);
    } finally {
      _$_RegisterControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleObscurePassword() {
    final _$actionInfo = _$_RegisterControllerBaseActionController.startAction(
      name: '_RegisterControllerBase.toggleObscurePassword',
    );
    try {
      return super.toggleObscurePassword();
    } finally {
      _$_RegisterControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
fullName: ${fullName},
phone: ${phone},
email: ${email},
password: ${password},
document: ${document},
obscurePassword: ${obscurePassword},
hasMinLength: ${hasMinLength},
hasUpperAndLower: ${hasUpperAndLower},
hasNumberOrSymbol: ${hasNumberOrSymbol},
isFormValid: ${isFormValid}
    ''';
  }
}
