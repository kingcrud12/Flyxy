void main() {
  try {
    [1, 2].sublist(0, 7);
  } catch (e) { print("Test 1: $e"); }
  try {
    List.filled(2, 0).insert(7, 1);
  } catch (e) { print("Test 2: $e"); }
  try {
    List.filled(2, 0).replaceRange(0, 7, [1]);
  } catch (e) { print("Test 3: $e"); }
  try {
    List.filled(2, 0).removeRange(0, 7);
  } catch (e) { print("Test 4: $e"); }
  try {
    "ab".substring(0, 7);
  } catch (e) { print("Test 5: $e"); }
  try {
    [1,2][7];
  } catch (e) { print("Test 6: $e"); }
}
