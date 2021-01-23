import 'package:googleapis/firestore/v1.dart';
import 'package:intl/intl.dart';

class ValueUtilities {
  static Value createFromString(String value) {
    Value result = new Value();
    result.stringValue = value;
    return result;
  }

  static Value createFromDateTime(DateTime value) {
    Value result = new Value();
    var timestampFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    result.timestampValue = timestampFormatter.format(value);
    return result;
  }
}