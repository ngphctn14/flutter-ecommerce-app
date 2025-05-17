class AddressDTO {
  final String province;
  final String provinceCode;
  final String district;
  final String districtCode;

  AddressDTO({
    required this.province,
    required this.provinceCode,
    required this.district,
    required this.districtCode, required String specificAddress, required wardCode, required ward,
  });

  Map<String, dynamic> toJson() => {
    'province': province,
    'provinceCode': provinceCode,
    'district': district,
    'districtCode': districtCode,
  };
}
