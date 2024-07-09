class GetLocationParams {
  const GetLocationParams({
    this.fields,
    this.lang,
    this.callback,
    this.query,
  });

  final String? fields;
  final String? lang;
  final String? callback;
  final Map<String, String>? query;
}
