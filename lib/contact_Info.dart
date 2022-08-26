class ContactInfo {
  String firstName;
  String lastName;
  String phoneNumber;
  String address;

  // standard constructor
  ContactInfo(
      {required this.firstName,
      required this.lastName,
      required this.phoneNumber,
      required this.address});

  // constructor from json mapped file
  ContactInfo.fromJason(Map jsonMap)
      : this(
            firstName: jsonMap['firstName'],
            lastName: jsonMap['lastName'],
            phoneNumber: jsonMap['phoneNumber'],
            address: jsonMap['address']);

  // creates map in json structure of the class info
  Map<String, String> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': firstName,
      'address': lastName,
    };
  }
}
