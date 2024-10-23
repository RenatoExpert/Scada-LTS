import Component from '../Component.js';

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
	}

	#makeChildren () {
		this.model.forEach(column => {
			let td = document.createElement("td");
			let col;
			if (item.type == "SELFLABEL") {
				col = document.createElement("spam");
				col.innerText = this.label;
				/*
			} else if (item.type == "ISCONNECTED") {
				let suffix = "SG-1";
				let obj = new Check_display(this.station_tag, suffix, this.clock, "Conectado", "Desconectado");
				col = obj.get_dom_element();
			} else if (item.type == "COMSTATUS") {
				let suffix = "SG-1";
				let obj = new Check_display(this.station_tag, suffix, this.clock, "OK", "Err");
				col = obj.get_dom_element();
			} else if (item.type == "CLOCK") {
				col = this.clock.get_dom_element();
			} else if (item.type == "NUMBER") {
				let obj = new Numeric_display(this.station_tag, item.suffix, item.eunit, this.clock);
				col = obj.get_dom_element();
			} else if (item.type == "BUTTON") {
				let button = document.createElement("button");
				button.textContent = item.label;
				let xid = item.target;
				button.onclick = () => {
					utils.goto_id(xid);
				};
				col = button
				*/
			} else {
				col = document.createElement("spam");
				col.innerText = "Unknown Column Type";
			}
			td.append(col);
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
