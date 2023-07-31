import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DroptimeRepository {
  final supabase = Supabase.instance.client;
  Future<DateTime?> getDroptime() async {
    DateTime? dropDateTime;
    String? dropDate = DateTime.now().toString();
    dropDate = dropDate.split(" ")[0];
    debugPrint("Getting droptime for date " + dropDate);
    String? dropTime;

    final data = await supabase.from('droptime').select('drop_time').eq('drop_date', dropDate);
    if (data != null && data.isNotEmpty) {
      dropTime = data.first['drop_time'];
      if (dropTime != null) {
        dropDateTime = datetimeFromStrings(dropDate, dropTime);
      }
    }

    return dropDateTime;
  }

  DateTime? datetimeFromStrings(String date, String time) {
    return DateTime.parse(date + " " + time + ".000");
  }
}
