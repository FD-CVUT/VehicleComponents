import HydraulicComponents

"""
    DOT4

DOT 4 brake fluid at 20 °C as a hydraulic medium: density 1045 kg/m³, bulk modulus 1.4 GPa and
dynamic viscosity 0.01045 Pa s (10e-6 m²/s kinematic; about 1800e-6 m²/s at -40 °C). It never
turns to gas.

The density holds at the medium's reference pressure, 100325 Pa absolute, the reference of
`HydraulicComponents.IsothermalCompressible`. The library's brake parts work in gauge pressure
above that reference, their parameter `p_amb`, and their ports carry `p_amb` plus gauge, since
hydraulic ports carry absolute pressure. A released circuit sits at `p_amb`. It is not the
atmosphere of the air side, 101325 Pa (`Gas.Port` has why); 1 kPa is 0.01 % of a 10 MPa apply. Pass it as a circuit's medium: `path medium::HydraulicComponents.Interfaces.AbstractMedium = VehicleComponents.DOT4`.
"""
const DOT4 = HydraulicComponents.IsothermalCompressible(bulk_modulus = 1.4e9, density = 1045.0, viscosity = 0.01045, let_gas = false)
