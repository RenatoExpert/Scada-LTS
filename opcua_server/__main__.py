#!/bin/python3

from opcua import ua, Server, instantiate
import sys
import time
sys.path.insert(0, "..")
from lib.station.Singlebranch import Singlebranch
from lib.station.Doublebranch import Doublebranch

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
    namespace = server.register_namespace(uri)
    # get Objects node, this is where we should put our nodes
    objects = server.get_objects_node()
    # populating our address space
    #super_connect = server.nodes.objects.add_folder(namespace, "SuperConnect")
    super_connect = objects.add_folder(namespace, "SuperConnect")
    bahiagas = super_connect.add_folder(namespace, "BrahmaGet")
    stations = []
    def add_station(region_code, station_code, station_type):
        code_tuple = (region_code, station_code)
        station = None
        match station_type:
            case 'singlebranch':
                station = Singlebranch(code_tuple, namespace, bahiagas)
            case 'doublebranch':
                station = Doublebranch(code_tuple, namespace, bahiagas)
        stations.append(station)
    add_station('001', '064', 'singlebranch')   #   Posto Trevo
    add_station('057', '001', 'doublebranch')   #   Etc Camaçari 2
    server.start()
    try:
        count = 0
        while True:
            time.sleep(2)
            [station.agitate() for station in stations]
    finally:
        server.stop()

