import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final int id;
  final String name;
  final String? address;
  final String? phoneNumber;

  const Supplier({
    required this.id,
    required this.name,
    this.address,
    this.phoneNumber,
  });

  // A factory for creating a new supplier instance from a map.
  static Supplier fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'],
      phoneNumber: map['phone_number'],
    );
  }

  // A copyWith method to easily create a new instance with updated fields.
  Supplier copyWith({
    int? id,
    String? name,
    String? address,
    String? phoneNumber,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  List<Object?> get props => [id, name, address, phoneNumber];
}
