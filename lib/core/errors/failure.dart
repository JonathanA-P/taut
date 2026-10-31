class Failure {
  final String title;
  final String message;
  final String? actionLabel;
  final void Function()? onAction;

  const Failure({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  factory Failure.fromException(Object error) {
    return Failure(title: 'Terjadi Kendala', message: error.toString());
  }
}

