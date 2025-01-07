import Component from '../Component.js';
import NAVAPI from '../../lib/NAVAPI.js';
import TableData from '../display/implement/TableData.js';

class TableRow extends Component {
	constructor (model, name, label, isatag) {
		let nodeTag = "tr";
		let className = "hp-tablerow";
		super(null, nodeTag, className);
		this.model = model;
		this.name = name;
		this.label = label;
		this.isatag = isatag;
		console.log({ TableRow: this });
		this.#makeChildren();
		this.node.addEventListener("click", e => {
			NAVAPI.append_address(name);
		});
	}

	#makeChildren () {
		this.model.forEach(column => {
			let td = document.createElement("td");
			let col = new TableData(this.label, column, this.isatag);
			td.append(col.node);
			this.node.append(td);
		});
	}
}

export default TableRow;

//======================================
//======================================
//======================================

/*
class Numeric_display {
	constructor (station_tag, suffix, engineering_unit, clock) {
		this.clock = clock;
		this.datapoint = `${station_tag}-${suffix}`;
		this.engineering_unit = engineering_unit;
		this.create_dom_element();
		setInterval(() => {
			this.value_fetch();
		}, 5e3);
		this.value_fetch();
	}

	create_dom_element () {
		let td = document.createElement("td");
		td.innerText = "???";
		this.dom_element = td;
	}

	value_fetch () {
		api.tag_load_num(this.datapoint).then(value => {
			this.render_value(value);
			this.clock.update();
		});
	}

	render_value (value) {
		let text = utils.format_var(value, this.engineering_unit);
		this.dom_element.innerHTML = text;
	}

	get_dom_element () {
		return this.dom_element;
	}
}

*/
