import random

def random_error(var_range, amplitude_tendency=0.01):
    efficiency = random.randrange(var_range[0], var_range[1]) * amplitude_tendency
    return efficiency
def gen_turbulence(value, setpoint):
    turbulence_range = (0, 300)
    amplitude = random_error(turbulence_range)
    return amplitude
def gen_fix(value, setpoint):
    error = setpoint - value
    fix_range = (0, 150)
    efficiency = random_error(fix_range)
    amplitude = error * efficiency
    return amplitude

from lib.tag.Tag import Tag

class Scalar(Tag):
    variable = None
    def __init__(self, name, station, namespace, initial_value=0, var_range=(0, 100), setpoint=50):
        super().__init__(name, station, namespace, initial_value)
        self.var_range = var_range
        self.setpoint = setpoint

    async def agitate(self):
        value = await self.get_value()
        setpoint = self.setpoint
        turbulence = gen_turbulence(value, setpoint)
        fix = gen_fix(value, setpoint)
        change = fix + turbulence
        await self.set_value(change)

