import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:bloot/core/di/injection.config.dart';
import 'package:bloot/features/game/presentation/cubit/local_game_simulator.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true)
Future<void> configureDependencies() async {
  await getIt.init();
  // The simulator uses simple Duration defaults and is not auto-registered by
  // injectable (to avoid requiring arbitrary Duration bindings in GetIt).
  if (getIt.isRegistered<LocalGameSimulator>()) {
    getIt.unregister<LocalGameSimulator>();
  }
  getIt.registerFactory<LocalGameSimulator>(LocalGameSimulator.new);
}
