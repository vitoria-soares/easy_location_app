abstract interface class SerializerInterface<T> {
  Map<String, dynamic> toMap(T object);
  T fromMap(Map<String, dynamic> map);
}
