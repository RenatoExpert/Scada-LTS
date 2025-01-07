import Summary from '../../../../prototype/Summary.js';

//	Make a separated file for particle and model
let table_particle = "FQ";
let table_model = [
	{
		"header": "Estação",
		"type": "SELFLABEL"
	},
	{
		"header": "Modem",
		"type": "ISCONNECTED"
	},
	{
		"header": "Comunicação",
		"type": "COMSTATUS"
	},
	{
		"header": "Atualização",
		"type": "CLOCK"
	},
	{
		"header": "Entrada",
		"type": "NUMBER",
		"suffix": "PI-1",
		"eunit": "Kgf/cm²"
	},
	{
		"header": "Saída",
		"type": "NUMBER",
		"suffix": "PI-2",
		"eunit": "Kgf/cm²"
	},
	{
		"header": "Temperatura",
		"type": "NUMBER",
		"suffix": "TI-1",
		"eunit": "ºC"
	},
	{
		"header": "Vazão",
		"type": "NUMBER",
		"suffix": "FI-1",
		"eunit": "ºm³/dia"
	},
	{
		"header": "Mês",
		"type": "NUMBER",
		"suffix": "FQI-1",
		"eunit": "ºm³"
	},
	{
		"header": "Anterior",
		"type": "NUMBER",
		"suffix": "FQIA-1",
		"eunit": "ºm³"
	},
];

class ERPMSummary extends Summary {
	constructor (entries, map) {
		console.log({ table_model });
		super (entries, map, table_particle, table_model);
		console.log({ ERPMSummary: this });
	}
}

export default ERPMSummary;

