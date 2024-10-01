import utils from '../utils/utils.js';

import Summary_component from '../summary_component/summary_component.js';

class Rectifiers_component extends Summary_component {
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
		console.log('table_model', { table_model });
		let table_particle = "EU";
		super(map, table_model);
	}
}

export default Rectifiers_component;

