// Data structure that holds the contact info of a user.
// Class fields:
// 1. String firstName
// 2. String lastName
// 3. String phoneNumber
// 4. String address
// 5. String city
// The class includes casting methods to/from Json, in order to work with the
// database.
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
