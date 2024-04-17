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
    station = bahiagas.add_folder(idx, "001002A")
    substation = station.add_folder(idx, "001002A")
    #   TAGS
    command = substation.add_variable(idx, "001002A.Gateway.Command", 0)
    scanrate = substation.add_variable(idx, "001002A.Gateway.ScanRate", 0)
    signal = substation.add_variable(idx, "001002A.Gateway.Signal", 0)
    status = substation.add_variable(idx, "001002A.Gateway.Status", 0)
    update = substation.add_variable(idx, "001002A.Gateway.Update", 0)
    pi = substation.add_variable(idx, "001-PI-002A-201", 22.8)
    pi.set_writable()
    pa = substation.add_variable(idx, "001-PA-002A-201", 15.6)
    pa.set_writable()
    timestamp = substation.add_variable(idx, "timestamp", 0)
    timestamp.set_writable()    # Set MyVariable to be writable by clients
    # starting!
    server.start()
    try:
        count = 0
        while True:
            time.sleep(2)
            count = pi.get_value()
            efective = random.randrange(0, 150) * 0.01
            out = 28 - count
            response = efective * out
            turbulence = random.randrange(0, 300) * 0.01
            count += response + turbulence
            timestamp.set_value(datetime.datetime.now())
            pi.set_value(count)
    finally:
        server.stop()


