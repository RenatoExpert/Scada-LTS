#!/bin/python3

from opcua import ua, Server, instantiate
import sys
import time
import datetime
import random
sys.path.insert(0, "..")

if __name__ == "__main__":
    # setup our server
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:4840/")
    server.set_server_name("Argus OPC Server");
    server.set_security_policy([ua.SecurityPolicyType.NoSecurity])
    #server.load_certificate("./sec/public.der")
    #server.set_security_policy([
    #    ua.SecurityPolicyType.NoSecurity,
    #    ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt,
    #    ua.SecurityPolicyType.Basic256Sha256_Sign])
    # setup our own namespace, not really necessary but should as spec
    uri = "brahmaget"
    idx = server.register_namespace(uri)
    # get Objects node, this is where we should put our nodes
    objects = server.get_objects_node()
    # populating our address space
    super_connect = server.nodes.objects.add_folder(idx, "SuperConnect")
    bahiagas = super_connect.add_folder(idx, "BrahmaGet")
    region_code = "001"
    station_code = "002A"
    code_tuple = f"{region_code}{station_code}"
    station = singlebranch_station(code_tuple, idx, bahiagas)
    # starting!
    server.start()
    try:
        count = 0
        while True:
            time.sleep(2)
            station.agitate()
            timestamp.set_value(datetime.datetime.now())
    finally:
        server.stop()

class singlebranch_station(default_station):
    #   TAGS
    pi = substation.add_variable(idx, "001-PI-002A-201", 22.8)
    pi.set_writable()
    pa = substation.add_variable(idx, "001-PA-002A-201", 15.6)
    pa.set_writable()

class default_station(station):
    def __init__(self, code_tuple, namespace, parent_node):
        super().__init__(code_tuple, namespace, parent_node)
        gateway_tags = [
                "Command",
                "ScanRate",
                "Signal",
                "Status",
                "Update"
        ]
        super().add_modem_tag(tag) for tag in gateway_tags
        super().add_writable("timestamp")

class station:
    def __init__(self, code_tuple, namespace, parent_node):
        region_code, station_code = code_tuple
        name = f"{region_code}{station_code}"
        major_folder = parent_node.add_folder(namespace, name)
        minor_folder = major_folder.add_folder(namespace, name)
        # Register into object
        self.region_code = region_code
        self.code_tuple = code_tuple
        self.name = name
        self.namespace = namespace
        self.major_folder = major_folder
        self.minor_folder = minor_folder
        self.children = {}
    def add_variable(self, name):
        self.minor_folder.add_variable(self.namespace, name, 0)
    def add_writable(self, name):
        tag = self.add_variable(name)
        tag.set_writable()
        self.children[name] = tag
    def add_modem_tag(self, radical):
        name = f"{self.region_code}{self.station_code}.Gateway.{radical}"
        self.add_variable(self, name)
    def add_instrumentation_tag(self, radical, number):
        f"{region-code}-{isa_letter}-{station_code}-{number}"
    def agitate(self):
        tag.agitate() for tag in self.children

class pressure(tag):
    def __init__(self, station, namespace, var_range=(0, 50), initial_value=20, isa_letter="PI"):
        super().__init__(station, namespace, var_range, initial_value, isa_letter)

class tag:
    def __init__(self, station, namespace, var_range, initial_value=0, isa_letter):
        region_code = station.region_code
        station_code = station.station_code
        name = f"{region_code}-{isa_letter}-{station_code}-201"
        self.variable = station.add_variable(namespace, name, initial_value)
        self.variable.set_writable()
        self.range = var_range
        self.isa_letter = isa_letter
    def set_value(self, value):
        return self.variable.set_value(value)
    def get_value(self, value):
        return self.variable.get_value(value)
    def agitate(self):
        def random_error(var_range, amplitude_tendency=0.01):
            efficiency = random.randrange(var_range[0], var_range[1]) * amplitude_tendency
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
        value = self.get_value()
        setpoint = self.get_setpoint()
        turbulence = gen_turbulence(value, setpoint)
        fix = gen_fix(value, setpoint)
        change = fix + turbulence
        self.set_value(change)
        self.update_timestamp()

