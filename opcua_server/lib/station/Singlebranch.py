from lib.station.Station import Station

class Singlebranch(Station):
    def __init__(self, code_tuple, namespace, parent_node):
        super().__init__(code_tuple, namespace, parent_node)
    async def init(self):
        await super().init()
        await self.init_instruments()
        return self
    async def init_instruments(self, number='201'):
        for (isa_letter, suffix_number) in instrument_tags:
            await super().add_instrument(isa_letter, suffix_number)

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

