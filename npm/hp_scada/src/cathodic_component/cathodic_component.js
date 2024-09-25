import utils from '../utils/utils.js';

import Summary_component from '../summary_component/summary_component.js';

class Cathodic_component extends Summary_component {
	/*
	constructor (map) {
		this.map = map;
		this.dom_element = this.create_dom_element(20);
	}

	create_dom_element (items_per_page) {
		let tree_table = this.map.current_view.process.children;
		let div = document.createElement("div");
		div.id = "summary";
		this.nav = new Page_navigator(this.map, items_per_page);
		div.appendChild(this.nav.get_dom_element());
		this.table = new Summary_table(this.map, items_per_page);
		div.append(this.table.get_dom_element());
		return div;
	}

	get_dom_element () {
		return this.dom_element;
	}
	*/
}

export default Summary_component;

