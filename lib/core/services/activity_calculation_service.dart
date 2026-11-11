class ActivityCalculationService {
  const ActivityCalculationService();

  // Yaklaşık adım uzunluğu: boyun %41,5'i.
  double estimatedDistanceKm({required int steps, required double heightCm}) {
    if (steps <= 0 || heightCm <= 0) return 0;
    final stepLengthMeters = (heightCm / 100) * 0.415;
    return steps * stepLengthMeters / 1000;
  }

  // Yürümeye bağlı net/ek aktivite kalorisi; yaklaşık 0.5 kcal / kg / km.
  double estimatedActiveCalories({required double distanceKm, required double weightKg}) {
    if (distanceKm <= 0 || weightKg <= 0) return 0;
    return distanceKm * weightKg * 0.5;
  }

  // GPS mesafesi bulunan yürüyüş için aynı yöntem.
  double walkingCalories({required double distanceMeters, required double weightKg}) {
    return estimatedActiveCalories(
      distanceKm: distanceMeters / 1000,
      weightKg: weightKg,
    );
  }
}
