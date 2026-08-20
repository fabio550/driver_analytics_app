class ValidationFailure<TField> {
  final TField field;
  final String message;

  const ValidationFailure({
    required this.field,
    required this.message,
  });
}