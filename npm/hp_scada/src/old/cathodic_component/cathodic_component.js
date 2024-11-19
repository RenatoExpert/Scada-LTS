import utils from '../utils/utils.js';

import Summary_component from '../summary_component/summary_component.js';

class Cathodic_component extends Summary_component {
	constructor (map) {
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
				"type": "BUTTON",
				"label": "Relatório Horário",
				"target": "l1-hourly_cathodic"
			},
			{
				"header": "Relatório Diário",
				"type": "BUTTON",
				"label": "Relatório Diário",
				"target": "l1-daily_cathodic"
			}
		];
		console.log('table_model', { table_model });
		let table_particle = "EP";
		super(map, table_model, table_particle);
	}
}

export default Cathodic_component;

