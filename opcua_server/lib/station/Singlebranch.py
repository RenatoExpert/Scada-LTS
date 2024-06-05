from lib.station.Station import Station

class Singlebranch(Station):
    instrument_tags = [
        ("EI", "201"),
        ("FI", "201"),
        ("FQI", "201"),
        ("FQIA", "201"),
        ("FQIM", "201"),
        ("FQIMA", "201"),
        ("PDI", "203"),
        ("PI", "201"),
        ("PI", "202"),
        ("TI", "202")
    ]
    def __init__(self, code_tuple, namespace, parent_node):
        super().__init__(code_tuple, namespace, parent_node)
        self.init_instruments()
    def init_instruments(self):
        for (isa_letter, number) in self.instrument_tags:
            super().add_instrument(isa_letter, number)


