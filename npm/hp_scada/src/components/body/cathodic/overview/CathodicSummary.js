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
		"header": "Potencial",
		"type": "NUMBER",
		"suffix": "EI-1",
		"eunit": "Vdc"
	},
	{
		"header": "Relatório Horário",
		"type": "DAILY",
		"label": "Relatório Horário",
		"target": "l1-hourly_cathodic"
	},
	{
		"header": "Relatório Diário",
		"type": "HOURLY",
		"label": "Relatório Diário",
		"target": "l1-daily_cathodic"
	}
];
let table_particle = "EP";
//	Make a separated file for particle and model

class CathodicSummary extends Summary {
	constructor (entries, map) {
		console.log({ table_model });
		super (entries, map, table_particle, table_model);
		console.log({ CathodicSummary: this });
	}
}

export default CathodicSummary;

