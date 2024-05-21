class pressure(Tag):
    def __init__(self, station, namespace, var_range=(0, 50), initial_value=20, isa_letter="PI"):
        super().__init__(station, namespace, var_range, initial_value, isa_letter)

