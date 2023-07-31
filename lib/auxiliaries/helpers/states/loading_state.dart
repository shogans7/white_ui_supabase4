abstract class LoadingState {
  const LoadingState();
}

class Loading extends LoadingState {
  const Loading();
}

class Loaded extends LoadingState {
  const Loaded();
}

class LoadingFailed extends LoadingState {
  final Exception exception;

  LoadingFailed(this.exception);
}
