import Chart_handler from './chart_handler.js';
import Cache_manager from './cache_manager.js';
import Time_controller from './time_controller.js';
import Id_handler from './id_handler.js';
import Api_connector from './api_connector.js';

class Graphic_component {
	constructor (reference) {
		this.chart_handler = new Chart_handler();
		this.id_handler = new Id_handler(reference);
		this.api_connector = new Api_connector(this.id_handler.datapoints);
		this.cache_manager = new Cache_manager();
		this.time_controller = new Time_controller();
		this.dom_element = this.create_dom_element();
	}

	create_dom_element () {
		let div = document.createElement("div");
		div.style.border = '1px solid gray';
		div.style.padding = "5px";
		div.id = "graphic-div";
		div.append(this.chart_handler.get_dom_element());
		div.append(this.time_controller.get_dom_element());
		return div;
	}

	get_dom_element () {
		return this.dom_element;
	}

	start () {
		if (this.interval) {
			console.error("Graphic Controller is already running");
		} else {
			this.interval = setInterval(this.routine, 1e3);
			//	Maybe need to pass this on 3rd parameter, to be used as 'self'
		}
	}

	stop () {
		if (this.interval) {
			clearInterval(this.interval);
		} else {
			console.error("Graphic Controller is already stopped!");
		}
	}

	loop () {
		let selected_range = this.time_controller.get_selected_range();
		let data = this.cache_manager.consult_range(selected_range);
		this.chart_handler.update(data);
	}

}

export default Graphic_component;

