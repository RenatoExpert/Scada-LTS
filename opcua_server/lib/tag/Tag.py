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

class Tag:
    def __init__(self, name, station, namespace, var_range, initial_value=0, setpoint=30):
        self.variable = station.add_variable(namespace, name, initial_value)
        self.setpoint = setpoint
        self.range = var_range

    def set_writable(self):
        self.variable.set_writable()

    def set_value(self, value):
        return self.variable.set_value(value)

    def get_value(self):
        return self.variable.get_value()

    def agitate(self):
        value = self.get_value()
        setpoint = self.setpoint
        turbulence = gen_turbulence(value, setpoint)
        fix = gen_fix(value, setpoint)
        change = fix + turbulence
        self.set_value(change)

