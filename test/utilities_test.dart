
import 'package:flutter_test/flutter_test.dart';
  group('decode and encode', () {
      assert(ByteUtils.bytesEqual(null, null) == true);
      assert(ByteUtils.bytesEqual(
          Uint8List.fromList([1, 2, 3]), Uint8List.fromList([1, 2])) ==
          false);
      assert(ByteUtils.bytesEqual(
          Uint8List.fromList([1, 2, 3]), Uint8List.fromList([1, 2, 4])) ==
          false);
      assert(ByteUtils.bytesEqual(
          Uint8List.fromList([1, 2, 3]), Uint8List.fromList([1, 2, 3])) ==
          true);
      assert(ByteUtils.bytesEqual(Uint8List.fromList([1, 2, 3]), null) == false);

      var bytes = Uint8List(0);
      assert(bytes.toHexString() == "");
      assert(Uint8List.fromList([]).toHexString() == "");
    });
  });
}
