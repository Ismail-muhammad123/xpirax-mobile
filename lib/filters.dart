import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

bool onTheSameDay({required DateTime dayOne, required DateTime dayTwo}) {
  return dayOne.day == dayTwo.day &&
      dayOne.month == dayTwo.month &&
      dayOne.year == dayTwo.year;
}

bool passedDateFilter(Timestamp date, DateTimeRange _sortDateRange) {
  DateTime dt = date.toDate();
  return (dt.isAfter(_sortDateRange.start) ||
          onTheSameDay(dayOne: dt, dayTwo: _sortDateRange.start)) &&
      (dt.isBefore(_sortDateRange.end) ||
          onTheSameDay(dayOne: dt, dayTwo: _sortDateRange.end));
}

bool performedByUser(String user, String name) {
  return user.toLowerCase() == 'all'
      ? true
      : user.toLowerCase() == name.toLowerCase();
}
