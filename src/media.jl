import HydraulicComponents

"""
    DOT4

DOT 4 brake fluid at 20 °C as a hydraulic medium: density 1045 kg/m³, bulk modulus 1.4 GPa and
dynamic viscosity 0.01045 Pa s (10e-6 m²/s kinematic; about 1800e-6 m²/s at -40 °C). It never
turns to gas. Pass it as a circuit's medium: `path medium::HydraulicComponents.Interfaces.AbstractMedium = VehicleComponents.DOT4`.
"""
const DOT4 = HydraulicComponents.IsothermalCompressible(bulk_modulus = 1.4e9, density = 1045.0, viscosity = 0.01045, let_gas = false)
