const baseUrl = 'http://122.163.121.176:3008';

class PostApiConnection {
  String login = '$baseUrl/api/user/login';
  String register = '$baseUrl/api/user/register';
  String logout = '$baseUrl/api/user/logout';
  String getAddressBook = '$baseUrl/api/user/get_address_book';
  String insertAddressBook = '$baseUrl/api/user/insert_address_book';
  String deleteAddressBook = '$baseUrl/api/user/delete_address_book';
}

class GetApiConnection {}