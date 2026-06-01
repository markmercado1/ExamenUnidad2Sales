class ProviderModel {
  final int id;
  final String nombre;
  final String ruc;
  final String telefono;
  final bool isSynced;
  final int? serverId;

  ProviderModel(
      this.id,
      this.nombre,
      this.ruc,
      this.telefono,
      this.isSynced,
      this.serverId,
      );

  factory ProviderModel.fromMap(
      Map<String, dynamic> map) {
    return ProviderModel(
      map['id'],
      map['nombre'].toString(),
      map['ruc'].toString(),
      map['telefono'].toString(),
      map['is_synced'] == 1,
      map['server_id'] as int?,
    );
  }

  factory ProviderModel.fromJson(
      Map<String, dynamic> json) {
    return ProviderModel(
      json['id'],
      json['nombre'].toString(),
      json['ruc'].toString(),
      json['telefono'].toString(),
      true,
      json['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'nombre': nombre,
      'ruc': ruc,
      'telefono': telefono,
      'is_synced': isSynced ? 1 : 0,
      'server_id': serverId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'ruc': ruc,
      'telefono': telefono,
    };
  }
}