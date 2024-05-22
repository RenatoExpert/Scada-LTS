from lib.station.Singlebranch import Singlebranch

class Doublebranch(Station):
    instrument_tags = [
        ("EI", "201"),
        ("FI", "201A"),
        ("FQI", "201A"),
        ("FQIA", "201A"),
        ("FQIM", "201A"),
        ("FQIMA", "201A"),
        ("PDI", "203A"),
        ("PI", "201A"),
        ("PI", "202A"),
        ("TI", "202A"),
        ("FI", "201B"),
        ("FQI", "201B"),
        ("FQIA", "201B"),
        ("FQIM", "201B"),
        ("FQIMA", "201B"),
        ("PDI", "203B"),
        ("PI", "201B"),
        ("PI", "202B"),
        ("TI", "202B")
    ]
    def __init__(self, code_tuple, namespace, parent_node):
        super().__init__(code_tuple, namespace, parent_node)

