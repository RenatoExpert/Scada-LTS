import Chart_handler from './chart_handler.js';
import Cache_manager from './cache_manager.js';
import Time_controller from './time_controller/time_controller.js';
import Id_handler from './id_handler.js';
import Api_connector from './api_connector.js';

class Graphic_component {
	constructor (map) {
		this.chart_handler = new Chart_handler(map.title);
		this.id_handler = new Id_handler(map.params.reference);
		this.api_connector = new Api_connector(this.id_handler.datapoints);
		this.cache_manager = new Cache_manager();
		this.time_controller = new Time_controller().on_new_frame((ts_start, ts_end) => {
			return this.new_frame(ts_start, ts_end);
		});
		this.create_dom_element();
		this.node.addEventListener("move_time", () => {
			console.log("inside controllers event listener to move time");
			this.time_controller.move_time();
		});
	}

	new_frame (ts_init, ts_end) {
		let datapoints = this.id_handler.datapoints;
		/*
		let datapoints = [
			"ERPM001-FQ064-TI-1",
			"ERPM001-FQ064-PI-1",
			"ERPM001-FQ064-PI-2",
			"ERPM001-FQ064-PDI-1",
			"ERPM001-FQ064-FQI-1",
			"ERPM001-FQ064-FI-1",
			"ERPM001-FQ064-FQIA-1",
			"ERPM001-FQ064-EI-1"
		];
		*/
		let range = [ts_init, ts_end];
		//console.log({ ts_init, ts_end, range, datapoints });
		return this.cache_manager.query(range, datapoints).then(result => {
			this.chart_handler.render(result);
		}).catch(error => {
			console.error(error);
		});
	}

	create_dom_element () {
		let div = document.createElement("div");
		div.addEventListener("start", () => {
			console.log("inside parent div event listener to start");
		});
		div.style.border = '1px solid gray';
		div.style.padding = "5px 15px 15px 15px";
		div.style.width = "100%";
		div.id = "graphic-div";
		div.append(this.chart_handler.get_dom_element());
		div.append(this.time_controller.get_dom_element());
		this.node = div;
	}

	start () {
	}

	stop () {
	}

	loop () {
		let selected_range = this.time_controller.get_selected_range();
		let data = this.cache_manager.consult_range(selected_range);
		this.chart_handler.update(data);
	}
}

export default Graphic_component;

