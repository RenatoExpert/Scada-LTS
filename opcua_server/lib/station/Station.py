import datetime
from lib.tag.Tag import Tag
from lib.tag.Scalar import Scalar

def get_nowdate():
        nowdate = datetime.datetime.now()

class Station:
    major_folder = None
    minor_folder = None
    def __init__(self, code_tuple, namespace, parent_node):
        self.code_tuple = code_tuple
        self.namespace = namespace
        self.parent_node = parent_node
        region_code, station_code = code_tuple
        self.region_code = region_code
        self.station_code = station_code
        name = f"{region_code}{station_code}"
        self.name = name
        self.children = {
            'instrument': {},
            'telemetry': {},
            'other': {}
        }
    async def init(self):
        namespace = self.namespace
        name = self.name
        major_folder = await self.parent_node.add_folder(namespace, name)
        minor_folder = await major_folder.add_folder(namespace, name)
        self.major_folder = major_folder
        self.minor_folder = minor_folder
        await self.init_modem()
        return self

    async def init_modem(self):
        gateway_tags = [
                "Command",
                "ScanRate",
                "Signal",
                "Status",
                "Update"
        ]
        [await self.add_modem_tag(tag) for tag in gateway_tags]
        await self.add_writable_tag("timestamp", 'other', get_nowdate())

    async def add_modem_tag(self, radical):
        name = f"{self.region_code}{self.station_code}.Gateway.{radical}"
        return await self.add_tag(name, 'telemetry')

    async def add_writable_tag(self, name, collection='other', initial_value=0.0):
        tag = await self.add_tag(name, collection, initial_value)
        await tag.set_writable()
        self.children[collection][name] = tag
        return tag

    async def add_tag(self, name, collection='other', initial_value=0.0):
        station = self.minor_folder
        namespace = self.namespace
        return await Tag(name, station, namespace, initial_value).init()

    async def add_scalar(self, name, collection, initial_value=0.0, var_range=(0, 100), setpoint=50):
        station = self.minor_folder
        namespace = self.namespace
        return await Scalar(name, station, namespace, initial_value, var_range, setpoint).init()

    async def add_instrument(self, isa_letter, suffix_number='201'):
        tag = f"{self.region_code}-{isa_letter}-{self.station_code}-{suffix_number}"
        return await self.add_scalar(tag, 'instrument', 0.0, (0,40), 30)

    async def agitate(self):
        instruments = self.children['instrument']
        [await instruments[tag].agitate() for tag in instruments]
        await self.update_datetime()

    async def update_datetime(self):
        await self.children['other']['timestamp'].set_value(get_nowdate())

