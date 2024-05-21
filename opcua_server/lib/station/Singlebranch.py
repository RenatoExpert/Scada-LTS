from lib.station.Station import Station

class Singlebranch(Station):
    def __init__(self, code_tuple, namespace, parent_node):
        super().__init__(code_tuple, namespace, parent_node)
        self.init_instruments()
    def init_instruments(self, number='101'):
        for isa_letter in instrument_tags:
            super().add_instrument(isa_letter, number)

instrument_tags = [
    "PI",
    "PA",
    "TI",
    "EI",
    "FI",
    "FQI",
    "FQIA"
]

