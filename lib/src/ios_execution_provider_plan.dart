class IosExecutionProviderPlan {
  const IosExecutionProviderPlan({
    required this.directives,
    this.invalidProvider,
  });

  final List<IosExecutionProviderDirective> directives;
  final String? invalidProvider;
}

enum IosExecutionProviderDirective {
  cpuDefault,
  cpuUseArenaDisabled,
  coreML,
  xnnpack,
}

IosExecutionProviderPlan buildIosExecutionProviderPlan({
  List<String>? providers,
  bool? useArena,
}) {
  final directives = <IosExecutionProviderDirective>[];
  var sawCpu = false;

  final list = providers;
  if (list != null && list.isNotEmpty) {
    for (final provider in list) {
      switch (provider) {
        case 'CPU':
          if (!sawCpu) {
            directives.add(
              useArena == false
                  ? IosExecutionProviderDirective.cpuUseArenaDisabled
                  : IosExecutionProviderDirective.cpuDefault,
            );
            sawCpu = true;
          }
        case 'CORE_ML':
          directives.add(IosExecutionProviderDirective.coreML);
        case 'XNNPACK':
          directives.add(IosExecutionProviderDirective.xnnpack);
        default:
          return IosExecutionProviderPlan(
            directives: directives,
            invalidProvider: provider,
          );
      }
    }
  } else if (useArena == false) {
    directives.add(IosExecutionProviderDirective.cpuUseArenaDisabled);
  }

  return IosExecutionProviderPlan(directives: directives);
}
