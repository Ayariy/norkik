class PrivacidadModel {
  String idPrivacidad;
  bool whatsapp;
  bool apodo;
  bool email;
  static const String collectionId = 'Privacidad';
  PrivacidadModel(
      {required this.idPrivacidad,
      required this.whatsapp,
      required this.apodo,
      required this.email});

  factory PrivacidadModel.fromFireStore(Map<String, dynamic> privacidad) {
    return PrivacidadModel(
        idPrivacidad: privacidad['idPrivacidad'],
        whatsapp: privacidad['WhatsApp'],
        apodo: privacidad['Email'],
        email: privacidad['Apodo']);
  }

  Map<String, dynamic> toMap() => {
        'Apodo': apodo,
        'Email': email,
        'WhatsApp': whatsapp,
      };

  factory PrivacidadModel.privacidadNoData() {
    return PrivacidadModel(
        idPrivacidad: 'no-id', whatsapp: true, apodo: true, email: true);
  }
}
