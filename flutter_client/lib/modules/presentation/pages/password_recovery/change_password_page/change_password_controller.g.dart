// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ChangePasswordController on _ChangePasswordControllerBase, Store {
  Computed<bool>? _$hasMinLengthComputed;

  @override
  bool get hasMinLength => (_$hasMinLengthComputed ??= Computed<bool>(
    () => super.hasMinLength,
    name: '_ChangePasswordControllerBase.hasMinLength',
  )).value;
  Computed<bool>? _$hasUpperAndLowerComputed;

  @override
  bool get hasUpperAndLower => (_$hasUpperAndLowerComputed ??= Computed<bool>(
    () => super.hasUpperAndLower,
    name: '_ChangePasswordControllerBase.hasUpperAndLower',
  )).value;
  Computed<bool>? _$hasNumberOrSymbolComputed;

  @override
  bool get hasNumberOrSymbol => (_$hasNumberOrSymbolComputed ??= Computed<bool>(
    () => super.hasNumberOrSymbol,
    name: '_ChangePasswordControllerBase.hasNumberOrSymbol',
  )).value;
  Computed<bool>? _$passwordsMatchComputed;

  @override
  bool get passwordsMatch => (_$passwordsMatchComputed ??= Computed<bool>(
    () => super.passwordsMatch,
    name: '_ChangePasswordControllerBase.passwordsMatch',
  )).value;
  Computed<bool>? _$isFormValidComputed;

  @override
  bool get isFormValid => (_$isFormValidComputed ??= Computed<bool>(
    () => super.isFormValid,
    name: '_ChangePasswordControllerBase.isFormValid',
  )).value;

  late final _$passwordAtom = Atom(
    name: '_ChangePasswordControllerBase.password',
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

  late final _$confirmPasswordAtom = Atom(
    name: '_ChangePasswordControllerBase.confirmPassword',
    context: context,
  );

  @override
  String get confirmPassword {
    _$confirmPasswordAtom.reportRead();
    return super.confirmPassword;
  }

  @override
  set confirmPassword(String value) {
    _$confirmPasswordAtom.reportWrite(value, super.confirmPassword, () {
      super.confirmPassword = value;
    });
  }

  late final _$obscurePasswordAtom = Atom(
    name: '_ChangePasswordControllerBase.obscurePassword',
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

  late final _$obscureConfirmPasswordAtom = Atom(
    name: '_ChangePasswordControllerBase.obscureConfirmPassword',
    context: context,
  );

  @override
  bool get obscureConfirmPassword {
    _$obscureConfirmPasswordAtom.reportRead();
    return super.obscureConfirmPassword;
  }

  @override
  set obscureConfirmPassword(bool value) {
    _$obscureConfirmPasswordAtom.reportWrite(
      value,
      super.obscureConfirmPassword,
      () {
        super.obscureConfirmPassword = value;
      },
    );
  }

  late final _$_ChangePasswordControllerBaseActionController = ActionController(
    name: '_ChangePasswordControllerBase',
    context: context,
  );

  @override
  void setPassword(String value) {
    final _$actionInfo = _$_ChangePasswordControllerBaseActionController
        .startAction(name: '_ChangePasswordControllerBase.setPassword');
    try {
      return super.setPassword(value);
    } finally {
      _$_ChangePasswordControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setConfirmPassword(String value) {
    final _$actionInfo = _$_ChangePasswordControllerBaseActionController
        .startAction(name: '_ChangePasswordControllerBase.setConfirmPassword');
    try {
      return super.setConfirmPassword(value);
    } finally {
      _$_ChangePasswordControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleObscurePassword() {
    final _$actionInfo = _$_ChangePasswordControllerBaseActionController
        .startAction(
          name: '_ChangePasswordControllerBase.toggleObscurePassword',
        );
    try {
      return super.toggleObscurePassword();
    } finally {
      _$_ChangePasswordControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleObscureConfirmPassword() {
    final _$actionInfo = _$_ChangePasswordControllerBaseActionController
        .startAction(
          name: '_ChangePasswordControllerBase.toggleObscureConfirmPassword',
        );
    try {
      return super.toggleObscureConfirmPassword();
    } finally {
      _$_ChangePasswordControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
password: ${password},
confirmPassword: ${confirmPassword},
obscurePassword: ${obscurePassword},
obscureConfirmPassword: ${obscureConfirmPassword},
hasMinLength: ${hasMinLength},
hasUpperAndLower: ${hasUpperAndLower},
hasNumberOrSymbol: ${hasNumberOrSymbol},
passwordsMatch: ${passwordsMatch},
isFormValid: ${isFormValid}
    ''';
  }
}
