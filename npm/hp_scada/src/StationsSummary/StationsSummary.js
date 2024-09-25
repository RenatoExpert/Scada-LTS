import Summary_component from '../summary_component/summary_component.js';

class StationSummary extends Summary_component {
	constructor (map) {
		let table_model = [
			{
				"type": "SELFLABEL"
			},
			{
				"type": "ISCONNECTED"
			},
			{
				"type": "COMSTATUS"
			},
			{
				"type": "CLOCK"
			},
			{
				"type": "NUMBER",
				"suffix": "PI-1",
				"eunit": "Kgf/cm²"
			},
			{
				"type": "NUMBER",
				"suffix": "PI-2",
				"eunit": "Kgf/cm²"
			},
			{
				"type": "NUMBER",
				"suffix": "TI-1",
				"eunit": "ºC"
			},
			{
				"type": "NUMBER",
				"suffix": "FI-1",
				"eunit": "ºm³/dia"
			},
			{
				"type": "NUMBER",
				"suffix": "FQI-1",
				"eunit": "ºm³"
			},
			{
				"type": "NUMBER",
				"suffix": "FQIA-1",
				"eunit": "ºm³"
			},
		];
		console.log('table_model', { table_model });
		super(map, table_model);
	}
}

export default Summary_component;

