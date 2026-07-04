import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';


class NativeCallException implements Exception {
  NativeCallException(this.message);
  final String message;

  @override
  String toString() => message;
}

typedef _InvokeNative = Pointer<Utf8> Function(
    Pointer<Utf8> method, Pointer<Utf8> argsJson);
typedef _InvokeDart = Pointer<Utf8> Function(
    Pointer<Utf8> method, Pointer<Utf8> argsJson);

typedef _FreeCStringNative = Void Function(Pointer<Utf8>);
typedef _FreeCStringDart = void Function(Pointer<Utf8>);


class NativeBridge {
  NativeBridge._(this._invoke, this._freeCString);

  static NativeBridge? _instance;

  factory NativeBridge() {
    return _instance ??= NativeBridge._load();
  }

  final _InvokeDart _invoke;
  final _FreeCStringDart _freeCString;

  static NativeBridge _load() {
    final lib = DynamicLibrary.open('libarmforge.so');
    final invoke = lib.lookupFunction<_InvokeNative, _InvokeDart>('Invoke');
    final freeCString =
        lib.lookupFunction<_FreeCStringNative, _FreeCStringDart>('FreeCString');
    return NativeBridge._(invoke, freeCString);
  }

  dynamic call(String method, Map<String, dynamic> args) {
    final methodPtr = method.toNativeUtf8();
    final argsPtr = jsonEncode(args).toNativeUtf8();
    Pointer<Utf8> resultPtr = nullptr;
    try {
      resultPtr = _invoke(methodPtr, argsPtr);
      final raw = resultPtr.toDartString();
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      if (envelope['ok'] != true) {
        throw NativeCallException((envelope['error'] as String?) ?? 'unknown native error');
      }
      return envelope['data'];
    } finally {
      
      malloc.free(methodPtr);
      malloc.free(argsPtr);
      if (resultPtr != nullptr) _freeCString(resultPtr);
    }
  }
}
