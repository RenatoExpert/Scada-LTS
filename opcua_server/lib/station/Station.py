import datetime
from lib.tag.Tag import Tag

class Station:
    def __init__(self, code_tuple, namespace, parent_node):
        region_code, station_code = code_tuple
        name = f"{region_code}{station_code}"
        major_folder = parent_node.add_folder(namespace, name)
        minor_folder = major_folder.add_folder(namespace, name)
        # Register into object
        self.region_code = region_code
        self.station_code = station_code
        self.code_tuple = code_tuple
        self.name = name
        self.namespace = namespace
        self.major_folder = major_folder
        self.minor_folder = minor_folder
        self.children = {
            'instrument': {},
            'telemetry': {},
            'other': {}
        }
        self.init_modem()

    def init_modem(self):
        gateway_tags = [
                "Command",
                "ScanRate",
                "Signal",
                "Status",
                "Update"
        ]
        [self.add_modem_tag(tag) for tag in gateway_tags]
        self.add_writable("timestamp", 'other')

    def add_variable(self, name, collection='other'):
        station = self.minor_folder
        namespace = self.namespace
        var_range = (0, 100)
        initial_value = 0
        return Tag(name, station, namespace, var_range, initial_value)

    def add_writable(self, name, collection='other'):
        tag = self.add_variable(name)
        tag.set_writable()
        self.children[collection][name] = tag
        return tag

    def add_modem_tag(self, radical):
        name = f"{self.region_code}{self.station_code}.Gateway.{radical}"
        return self.add_variable(name, 'telemetry')

    def add_instrument(self, isa_letter, number):
        tag = f"{self.region_code}-{isa_letter}-{self.station_code}-{number}"
        return self.add_writable(tag, 'instrument')

    def agitate(self):
        instruments = self.children['instrument']
        [instruments[tag].agitate() for tag in instruments]
        nowdate = datetime.datetime.now()
        self.children['other']['timestamp'].set_value(nowdate)

