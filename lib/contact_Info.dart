class ContactInfo {
  String firstName;
  String lastName;
  String phoneNumber;
  String address;
  String city;

  // standard constructor
  ContactInfo(
      {required this.firstName,
      required this.lastName,
      required this.phoneNumber,
      required this.address,
      required this.city});

  // constructor from json mapped file
  ContactInfo.fromJason(Map jsonMap)
      : this(
            firstName: jsonMap['firstName'],
            lastName: jsonMap['lastName'],
            phoneNumber: jsonMap['phoneNumber'],
            address: jsonMap['address'],
            city: jsonMap['city']);

  // creates map in json structure of the class info
  Map<String, String> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city
    };
  }
}
