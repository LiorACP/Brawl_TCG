import 'package:flutter/material.dart';

class StoreProfile {
  final String name;
  final String address;
  final int foundedYear;
  final bool verified;

  String get subtitle => '$address · Desde $foundedYear';

  const StoreProfile({
    required this.name,
    required this.address,
    required this.foundedYear,
    this.verified = false,
  });
}

class StoreStats {
  final double rating;
  final int followers;
  final int tournaments;

  String get ratingLabel => rating.toStringAsFixed(1);

  const StoreStats({
    required this.rating,
    required this.followers,
    required this.tournaments,
  });
}

class StoreAdminSection {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const StoreAdminSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class StoreReview {
  final String authorName;
  final int stars;
  final String body;

  String get starsLabel => '★' * stars;

  const StoreReview({
    required this.authorName,
    required this.stars,
    required this.body,
  });
}
