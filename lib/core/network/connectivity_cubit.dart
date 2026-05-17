import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'connectivity_cubit.freezed.dart';

@freezed
abstract class ConnectivityState with _$ConnectivityState {
  const factory ConnectivityState({@Default(true) bool isConnected}) =
      _ConnectivityState;
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(const ConnectivityState()) {
    _init();
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void _init() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      emit(state.copyWith(isConnected: isConnected));
    });

    Connectivity().checkConnectivity().then((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      emit(state.copyWith(isConnected: isConnected));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
