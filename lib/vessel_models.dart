class DataModel {
  final String call_sign;
  final String flag;
  final String kelas;
  final String builder;
  final String year_built;

  DataModel({required this.call_sign, required this.flag, required this.kelas, required this.builder, required this.year_built,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      call_sign: json['call_sign'],
      flag: json['flag'],
      kelas: json['kelas'],
      builder: json['builder'],
      year_built: json['year_built'],
    );
  }
}