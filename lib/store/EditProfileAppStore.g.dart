// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'EditProfileAppStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$EditProfileAppStore on EditProfileAppStoreBase, Store {
  final _$editProfileAtom = Atom(name: 'EditProfileAppStoreBase.editProfile');

  @override
  ObservableMap<String, dynamic> get editProfile {
    _$editProfileAtom.reportRead();
    return super.editProfile;
  }

  @override
  set editProfile(ObservableMap<String, dynamic> value) {
    _$editProfileAtom.reportWrite(value, super.editProfile, () {
      super.editProfile = value;
    });
  }

  final _$EditProfileAppStoreBaseActionController =
      ActionController(name: 'EditProfileAppStoreBase');

  @override
  void addData(Map<String, dynamic> data, {bool? isClear}) {
    final _$actionInfo = _$EditProfileAppStoreBaseActionController.startAction(
        name: 'EditProfileAppStoreBase.addData');
    try {
      return super.addData(data, isClear: isClear);
    } finally {
      _$EditProfileAppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeData() {
    final _$actionInfo = _$EditProfileAppStoreBaseActionController.startAction(
        name: 'EditProfileAppStoreBase.removeData');
    try {
      return super.removeData();
    } finally {
      _$EditProfileAppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
editProfile: ${editProfile}
    ''';
  }
}
