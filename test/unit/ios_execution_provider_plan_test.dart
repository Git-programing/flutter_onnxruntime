import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_onnxruntime/src/ios_execution_provider_plan.dart';

void main() {
  group('buildIosExecutionProviderPlan', () {
    test('null or true useArena keeps default CPU behavior', () {
      final nullPlan = buildIosExecutionProviderPlan(
        providers: const <String>['CPU', 'CORE_ML'],
        useArena: null,
      );
      final truePlan = buildIosExecutionProviderPlan(
        providers: const <String>['CPU', 'CORE_ML'],
        useArena: true,
      );

      expect(nullPlan.directives, const <IosExecutionProviderDirective>[
        IosExecutionProviderDirective.cpuDefault,
        IosExecutionProviderDirective.coreML,
      ]);
      expect(truePlan.directives, nullPlan.directives);
      expect(nullPlan.invalidProvider, isNull);
      expect(truePlan.invalidProvider, isNull);
    });

    test('false useArena appends CPU with use_arena=0 once', () {
      final withProviders = buildIosExecutionProviderPlan(
        providers: const <String>['CPU', 'XNNPACK'],
        useArena: false,
      );
      final withoutProviders = buildIosExecutionProviderPlan(useArena: false);

      expect(withProviders.directives, const <IosExecutionProviderDirective>[
        IosExecutionProviderDirective.cpuUseArenaDisabled,
        IosExecutionProviderDirective.xnnpack,
      ]);
      expect(withoutProviders.directives, const <IosExecutionProviderDirective>[
        IosExecutionProviderDirective.cpuUseArenaDisabled,
      ]);
    });

    test('providers containing CPU do not duplicate CPU append', () {
      final plan = buildIosExecutionProviderPlan(
        providers: const <String>['CORE_ML', 'CPU', 'CPU', 'XNNPACK'],
        useArena: false,
      );

      expect(plan.directives, const <IosExecutionProviderDirective>[
        IosExecutionProviderDirective.coreML,
        IosExecutionProviderDirective.cpuUseArenaDisabled,
        IosExecutionProviderDirective.xnnpack,
      ]);
    });

    test('CoreML and XNNPACK directives stay unchanged', () {
      final plan = buildIosExecutionProviderPlan(
        providers: const <String>['CORE_ML', 'XNNPACK'],
        useArena: false,
      );

      expect(plan.directives, const <IosExecutionProviderDirective>[
        IosExecutionProviderDirective.coreML,
        IosExecutionProviderDirective.xnnpack,
      ]);
      expect(plan.invalidProvider, isNull);
    });

    test('invalid provider remains rejected', () {
      final plan = buildIosExecutionProviderPlan(
        providers: const <String>['CPU', 'CUDA'],
        useArena: false,
      );

      expect(plan.invalidProvider, 'CUDA');
      expect(plan.directives, const <IosExecutionProviderDirective>[
        IosExecutionProviderDirective.cpuUseArenaDisabled,
      ]);
    });
  });
}
