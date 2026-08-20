class ValidationFailure<TField> {
  final TField field;
  final String message;
  final int? index;
  
  const ValidationFailure({
    required this.field,
    required this.message,
    this.index,
  });
}
