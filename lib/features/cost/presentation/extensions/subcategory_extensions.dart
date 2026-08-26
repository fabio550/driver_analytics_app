import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/maintenance_subcategory.dart';

extension FuelSubcategoryLabel on FuelSubcategory {
  String get label {
    return switch (this) {
      FuelSubcategory.ethanolCommon => 'Etanol Comum',
      FuelSubcategory.ethanolAdditized => 'Etanol Aditivado',
      FuelSubcategory.gasolineCommon => 'Gasolina Comum',
      FuelSubcategory.gasolineAdditized => 'Gasolina Aditivada',
      FuelSubcategory.gasolinePremium => 'Gasolina Premium',
      FuelSubcategory.diesel => 'Diesel',
      FuelSubcategory.energy => 'Energia (elétrico)',
      FuelSubcategory.gnv => 'GNV',
    };
  }
}

extension ExpenseSubcategoryLabel on ExpenseSubcategory {
  String get label {
    return switch (this) {
      ExpenseSubcategory.parking => 'Estacionamento',
      ExpenseSubcategory.financing => 'Financiamento',
      ExpenseSubcategory.taxes => 'Impostos',
      ExpenseSubcategory.carWash => 'Lavagem',
      ExpenseSubcategory.fine => 'Multa',
      ExpenseSubcategory.toll => 'Pedágio',
      ExpenseSubcategory.insurance => 'Seguro',
      ExpenseSubcategory.other => 'Outros',
    };
  }
}

extension MaintenanceSubcategoryLabel on MaintenanceSubcategory {
  String get label {
    return switch (this) {
      // Motor
      MaintenanceSubcategory.oilChange => 'Troca de óleo',
      MaintenanceSubcategory.oilFilter => 'Filtro de óleo',
      MaintenanceSubcategory.airFilter => 'Filtro de ar',
      MaintenanceSubcategory.fuelFilter => 'Filtro de combustível',
      MaintenanceSubcategory.sparkPlugs => 'Velas',
      MaintenanceSubcategory.ignitionCables => 'Cabos de ignição',
      MaintenanceSubcategory.timingBelt => 'Correia dentada',
      MaintenanceSubcategory.accessoryBelt => 'Correia acessória',
      MaintenanceSubcategory.engineMounts => 'Coxins do motor',
      MaintenanceSubcategory.gaskets => 'Juntas',
      MaintenanceSubcategory.turbo => 'Turbina',
      MaintenanceSubcategory.valveAdjustment => 'Ajuste de válvulas',

      // Transmissão / câmbio
      MaintenanceSubcategory.transmissionFluid => 'Óleo do câmbio',
      MaintenanceSubcategory.clutch => 'Embreagem',
      MaintenanceSubcategory.clutchCable => 'Cabo de embreagem',
      MaintenanceSubcategory.cvJoint => 'Homocinética',
      MaintenanceSubcategory.driveshaft => 'Eixo de transmissão',
      MaintenanceSubcategory.differentialFluid => 'Óleo do diferencial',

      // Freios
      MaintenanceSubcategory.brakePads => 'Pastilhas de freio',
      MaintenanceSubcategory.brakeDiscs => 'Discos de freio',
      MaintenanceSubcategory.brakeDrums => 'Tambores de freio',
      MaintenanceSubcategory.brakeShoes => 'Lonas de freio',
      MaintenanceSubcategory.brakeFluid => 'Fluido de freio',
      MaintenanceSubcategory.brakeCalipers => 'Pinças de freio',
      MaintenanceSubcategory.handbrakeCable => 'Cabo do freio de mão',
      MaintenanceSubcategory.absSensor => 'Sensor do ABS',

      // Suspensão e direção
      MaintenanceSubcategory.shockAbsorbers => 'Amortecedores',
      MaintenanceSubcategory.springs => 'Molas',
      MaintenanceSubcategory.stabilizerLink => 'Bieleta',
      MaintenanceSubcategory.controlArm => 'Bandeja de suspensão',
      MaintenanceSubcategory.wheelBearing => 'Rolamento de roda',
      MaintenanceSubcategory.steeringRack => 'Caixa de direção',
      MaintenanceSubcategory.powerSteeringFluid =>
        'Fluido da direção hidráulica',
      MaintenanceSubcategory.tieRodEnd => 'Terminal de direção',

      // Elétrica
      MaintenanceSubcategory.battery => 'Bateria',
      MaintenanceSubcategory.alternator => 'Alternador',
      MaintenanceSubcategory.starterMotor => 'Motor de arranque',
      MaintenanceSubcategory.lights => 'Iluminação',
      MaintenanceSubcategory.fuses => 'Fusíveis',
      MaintenanceSubcategory.wiring => 'Fiação',
      MaintenanceSubcategory.sensors => 'Sensores',

      // Ar-condicionado
      MaintenanceSubcategory.acRefrigerantRecharge =>
        'Recarga de gás do ar-condicionado',
      MaintenanceSubcategory.cabinFilter => 'Filtro de cabine',
      MaintenanceSubcategory.acCompressor => 'Compressor do ar-condicionado',
      MaintenanceSubcategory.acCondenser => 'Condensador do ar-condicionado',

      // Arrefecimento
      MaintenanceSubcategory.coolant => 'Fluido de arrefecimento',
      MaintenanceSubcategory.radiator => 'Radiador',
      MaintenanceSubcategory.waterPump => 'Bomba d\'água',
      MaintenanceSubcategory.thermostat => 'Válvula termostática',
      MaintenanceSubcategory.coolantHoses => 'Mangueiras de arrefecimento',
      MaintenanceSubcategory.radiatorFan => 'Eletroventilador',

      // Escapamento
      MaintenanceSubcategory.muffler => 'Silencioso/Escapamento',
      MaintenanceSubcategory.catalyticConverter => 'Catalisador',
      MaintenanceSubcategory.oxygenSensor => 'Sonda lambda',

      // Pneus e rodas
      MaintenanceSubcategory.tireReplacement => 'Troca de pneu',
      MaintenanceSubcategory.tireRepair => 'Conserto de pneu',
      MaintenanceSubcategory.wheelAlignment => 'Alinhamento',
      MaintenanceSubcategory.wheelBalancing => 'Balanceamento',
      MaintenanceSubcategory.rimRepair => 'Reparo de roda',

      // Carroceria
      MaintenanceSubcategory.paint => 'Pintura',
      MaintenanceSubcategory.bodyRepair => 'Funilaria',
      MaintenanceSubcategory.windshield => 'Para-brisa',
      MaintenanceSubcategory.wipers => 'Palhetas',
      MaintenanceSubcategory.mirrors => 'Retrovisores',

      // Geral
      MaintenanceSubcategory.labor => 'Mão de obra',
      MaintenanceSubcategory.fullInspection => 'Revisão completa',
      MaintenanceSubcategory.diagnostic => 'Diagnóstico',
      MaintenanceSubcategory.other => 'Outros',
    };
  }
}
