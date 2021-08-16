import 'package:log_keep/common/utilities/future_extensions.dart';
import 'package:log_keep/common/utilities/random.dart';

Future fakeDelay() async {
  await milliseconds(RandomUtilities.get(300, 600));
}