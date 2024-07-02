import 'dart:math';

void main() {
  // Generate a random string of characters
  String randomString = generateRandomString(); // Change 10 to the desired length
  print('Random string: $randomString');
}

String generateRandomString() {
  Random random = Random();
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'; // Add any other characters you want
  
  // Generate a list of random characters of specified length
  Iterable<String> randomChars = Iterable.generate(
    10, 
    (_) => chars[random.nextInt(chars.length)]
  );
  
  return randomChars.join();
}
