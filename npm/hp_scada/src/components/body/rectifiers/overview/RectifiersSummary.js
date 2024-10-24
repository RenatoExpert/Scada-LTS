import Summary from '../../../../prototype/Summary.js';

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
		"header": "Alimentação",
		"type": "NUMBER",
		"suffix": "EI-1",
		"eunit": "Vac"
	},
	{
		"header": "Saída",
		"type": "NUMBER",
		"suffix": "EI-2",
		"eunit": "Vdc"
	},
	{
		"header": "Corrente",
		"type": "NUMBER",
		"suffix": "II-1",
		"eunit": "A"
	},
	{
		"header": "Proteção",
		"type": "NUMBER",
		"suffix": "EDI-1",
		"eunit": "Vdc"
	}
];
let table_particle = "EU";
//	Make a separated file for particle and model

class RectifiersSummary extends Summary {
	constructor (entries, map) {
		console.log({ table_model });
		super (entries, map, table_particle, table_model);
		console.log({ RectifiersSummary: this });
	}
}

export default RectifiersSummary;

