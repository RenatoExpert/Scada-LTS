#!/bin/python3

print("Importing libraries...")

import asyncio
import sys
import time
from asyncua import ua, Server, uamethod
from lib.station.Singlebranch import Singlebranch

print("Libraries imported!")

stations = []

async def init(server):
    print("Initializing server")
    await server.init()
    server.set_endpoint("opc.tcp://0.0.0.0:4840/")
    server.set_server_name("Argus OPC Server");
    #server.set_security_policy([ua.SecurityPolicyType.NoSecurity])
    #await server.load_certificate("./sec/public.der")
    #server.set_security_policy([
    #    ua.SecurityPolicyType.NoSecurity,
    #    ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt,
    #    ua.SecurityPolicyType.Basic256Sha256_Sign])
    uri = "brahmaget"
    namespace = await server.register_namespace(uri)
    # get Objects node, this is where we should put our nodes
    objects = server.get_objects_node()
    # populating our address space
    #super_connect = server.nodes.objects.add_folder(namespace, "SuperConnect")
    super_connect = await objects.add_folder(namespace, "SuperConnect")
    bahiagas = await super_connect.add_folder(namespace, "BrahmaGet")
    async def add_station(region_code, station_code):
        code_tuple = (region_code, station_code)
        station = await Singlebranch(code_tuple, namespace, bahiagas).init()
        stations.append(station)
    await add_station('001', '064')

async def update():
    print("Updating variables...")
    [await station.agitate() for station in stations]

def main():
    print("def main")
    server = Server()
    try:
        asyncio.run(init(server))
        while True:
            asyncio.run(update())
            time.sleep(1)
    finally:
        print("finally")
        asyncio.run(server.stop())
        exit()

if __name__ == "__main__":
    main()

print("Script end")
