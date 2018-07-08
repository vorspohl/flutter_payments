DateTime addMonths(DateTime val, [int months = 1]) {
  if (val == null) {
    return null;
  }

  return DateTime(
    val.year + months ~/ 12,
    val.month + (months.abs() % 12) * (months < 0 ? -1 : 1),
    val.day,
  );
}

DateTime addWeeks(DateTime val, [int weeks = 1]) => val.add(Duration(days: weeks * 7));

DateTime addYears(DateTime val, [int years = 1]) => val.add(Duration(days: years * 365));
