enum FuelFamily {
  ethanol,
  gasoline,
  diesel,
  electric,
  gas,
}

enum FuelSubcategory {
  ethanolCommon(FuelFamily.ethanol),
  ethanolAdditized(FuelFamily.ethanol),
  gasolineCommon(FuelFamily.gasoline),
  gasolineAdditized(FuelFamily.gasoline),
  gasolinePremium(FuelFamily.gasoline),
  diesel(FuelFamily.diesel),
  energy(FuelFamily.electric);
  GNV(FuelFamily.gas);

  final FuelFamily family;
  const FuelSubcategory(this.family);
}
