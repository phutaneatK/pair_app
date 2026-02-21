enum DateFormatType {
  sT('ST', 'dd/MM/yyyy HH:mm'),
  sTT('STT', 'dd/MM/yyyy HH:mm:ss'),
  t('T', 'HH:mm:ss'),
  tt('TT', 'HH:mm'),
  dt('DT', 'dd MMM yyyy'),
  dtM('DTM', 'dd MMM yyyy, HH:mm'),
  dmy('DMY', 'dd-MM-yyyy'),
  mdy('MDY', 'MM-dd-yyyy'),
  ymd('YMD', 'yyyy-MM-dd'),
  ymdHMS('YMDHMS', 'yyyy-MM-dd HH:mm:ss');

  final String name;
  final String format;

  const DateFormatType(this.name, [this.format = '']);
}

String fdate(DateTime? value, {DateFormatType format = DateFormatType.sT}) {
  if (value == null) return '';

  try {
    final dt = value.toUtc().add(const Duration(hours: 7)); // เวลาไทย
    final pattern = format.format;

    final yearThai = dt.year + 543;

    final tokens = <String, String>{
      'yyyy': yearThai.toString(),
      'yy': yearThai.toString().substring(2),
      'MM': dt.month.toString().padLeft(2, '0'),
      'dd': dt.day.toString().padLeft(2, '0'),
      'HH': dt.hour.toString().padLeft(2, '0'),
      'mm': dt.minute.toString().padLeft(2, '0'),
      'ss': dt.second.toString().padLeft(2, '0'),
    };

    var result = pattern;

    // replace token ยาวก่อน ป้องกัน yyyy → yy พัง
    final sortedKeys = tokens.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final key in sortedKeys) {
      result = result.replaceAll(key, tokens[key]!);
    }

    return result;
  } catch (_) {
    return '';
  }
}

bool isEmpty(dynamic value) {
  if (value == null) return true;

  if (value is String) {
    final v = value.trim().toLowerCase();
    return v.isEmpty;
  }

  if (value is num) {
    return value == 0 || value.isNaN;
  }

  if (value is Iterable || value is Map) {
    return value.isEmpty;
  }

  if (value is DateTime) {
    return value.millisecondsSinceEpoch == 0;
  }

  return false;
}
