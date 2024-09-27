import Summary_component from '../summary_component/summary_component.js';

class StationSummary extends Summary_component {
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
		console.log('table_model', { table_model });
		let table_particle = "FQ";
		super(map, table_model, "FQ");
	}
}

export default StationSummary;

