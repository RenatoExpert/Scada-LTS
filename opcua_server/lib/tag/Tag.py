class Tag:
    variable = None

    def __init__(self, name, station, namespace, initial_value=0):
        self.name = name
        self.station = station
        self.namespace = namespace
        self.initial_value = initial_value

    async def init(self):
        self.variable = await self.station.add_variable(self.namespace, self.name, self.initial_value)
        return self

    async def set_writable(self):
        await self.variable.set_writable()

    async def set_value(self, value):
        return await self.variable.write_value(value)

    async def get_value(self):
        return await self.variable.read_value()

