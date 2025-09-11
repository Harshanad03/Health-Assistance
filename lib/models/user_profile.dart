class UserProfile {
  static final UserProfile _instance = UserProfile._internal();
  factory UserProfile() => _instance;
  UserProfile._internal();

  static UserProfile get instance => _instance;

  String _name = '';
  String _age = '';
  String _dob = '';
  String _sex = '';
  String _phone = '';
  String _pincode = '';
  String? _profilePicture;

  String get name => _name;
  String get age => _age;
  String get dob => _dob;
  String get sex => _sex;
  String get phone => _phone;
  String get pincode => _pincode;
  String? get profilePicture => _profilePicture;

  void update({
    String? name,
    String? age,
    String? dob,
    String? sex,
    String? phone,
    String? pincode,
    String? profilePicture,
  }) {
    if (name != null) _name = name;
    if (age != null) _age = age;
    if (dob != null) _dob = dob;
    if (sex != null) _sex = sex;
    if (phone != null) _phone = phone;
    if (pincode != null) _pincode = pincode;
    if (profilePicture != null) _profilePicture = profilePicture;
  }

  void clear() {
    _name = '';
    _age = '';
    _dob = '';
    _sex = '';
    _phone = '';
    _pincode = '';
    _profilePicture = null;
  }
}
