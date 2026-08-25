enum MaintenanceFamily {
  engine,
  transmission,
  brakes,
  suspensionAndSteering,
  electrical,
  airConditioning,
  cooling,
  exhaust,
  tiresAndWheels,
  bodywork,
  general,
}

enum MaintenanceSubcategory {
  // Motor
  oilChange(MaintenanceFamily.engine),
  oilFilter(MaintenanceFamily.engine),
  airFilter(MaintenanceFamily.engine),
  fuelFilter(MaintenanceFamily.engine),
  sparkPlugs(MaintenanceFamily.engine),
  ignitionCables(MaintenanceFamily.engine),
  timingBelt(MaintenanceFamily.engine),
  accessoryBelt(MaintenanceFamily.engine),
  engineMounts(MaintenanceFamily.engine),
  gaskets(MaintenanceFamily.engine),
  turbo(MaintenanceFamily.engine),
  valveAdjustment(MaintenanceFamily.engine),

  // Transmissão / câmbio
  transmissionFluid(MaintenanceFamily.transmission),
  clutch(MaintenanceFamily.transmission),
  clutchCable(MaintenanceFamily.transmission),
  cvJoint(MaintenanceFamily.transmission),
  driveshaft(MaintenanceFamily.transmission),
  differentialFluid(MaintenanceFamily.transmission),

  // Freios
  brakePads(MaintenanceFamily.brakes),
  brakeDiscs(MaintenanceFamily.brakes),
  brakeDrums(MaintenanceFamily.brakes),
  brakeShoes(MaintenanceFamily.brakes),
  brakeFluid(MaintenanceFamily.brakes),
  brakeCalipers(MaintenanceFamily.brakes),
  handbrakeCable(MaintenanceFamily.brakes),
  absSensor(MaintenanceFamily.brakes),

  // Suspensão e direção
  shockAbsorbers(MaintenanceFamily.suspensionAndSteering),
  springs(MaintenanceFamily.suspensionAndSteering),
  stabilizerLink(MaintenanceFamily.suspensionAndSteering),
  controlArm(MaintenanceFamily.suspensionAndSteering),
  wheelBearing(MaintenanceFamily.suspensionAndSteering),
  steeringRack(MaintenanceFamily.suspensionAndSteering),
  powerSteeringFluid(MaintenanceFamily.suspensionAndSteering),
  tieRodEnd(MaintenanceFamily.suspensionAndSteering),

  // Elétrica
  battery(MaintenanceFamily.electrical),
  alternator(MaintenanceFamily.electrical),
  starterMotor(MaintenanceFamily.electrical),
  lights(MaintenanceFamily.electrical),
  fuses(MaintenanceFamily.electrical),
  wiring(MaintenanceFamily.electrical),
  sensors(MaintenanceFamily.electrical),

  // Ar-condicionado
  acRefrigerantRecharge(MaintenanceFamily.airConditioning),
  cabinFilter(MaintenanceFamily.airConditioning),
  acCompressor(MaintenanceFamily.airConditioning),
  acCondenser(MaintenanceFamily.airConditioning),

  // Arrefecimento
  coolant(MaintenanceFamily.cooling),
  radiator(MaintenanceFamily.cooling),
  waterPump(MaintenanceFamily.cooling),
  thermostat(MaintenanceFamily.cooling),
  coolantHoses(MaintenanceFamily.cooling),
  radiatorFan(MaintenanceFamily.cooling),

  // Escapamento
  muffler(MaintenanceFamily.exhaust),
  catalyticConverter(MaintenanceFamily.exhaust),
  oxygenSensor(MaintenanceFamily.exhaust),

  // Pneus e rodas
  tireReplacement(MaintenanceFamily.tiresAndWheels),
  tireRepair(MaintenanceFamily.tiresAndWheels),
  wheelAlignment(MaintenanceFamily.tiresAndWheels),
  wheelBalancing(MaintenanceFamily.tiresAndWheels),
  rimRepair(MaintenanceFamily.tiresAndWheels),

  // Carroceria
  paint(MaintenanceFamily.bodywork),
  bodyRepair(MaintenanceFamily.bodywork),
  windshield(MaintenanceFamily.bodywork),
  wipers(MaintenanceFamily.bodywork),
  mirrors(MaintenanceFamily.bodywork),

  // Geral
  labor(MaintenanceFamily.general),
  fullInspection(MaintenanceFamily.general),
  diagnostic(MaintenanceFamily.general),
  other(MaintenanceFamily.general);

  final MaintenanceFamily family;
  const MaintenanceSubcategory(this.family);
}
