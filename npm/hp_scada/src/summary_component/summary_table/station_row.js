import utils from '../../utils/utils.js';
import api from '../../api/api.js';

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

class Clock_display {
	constructor () {
		this.create_dom_element();
		this.update();
	}

	create_dom_element () {
		let td = document.createElement("td");
		td.innerText = "--:--";
		this.dom_element = td;
	}

	get_dom_element () {
		return this.dom_element;
	}

	update () {
		console.log("Clock_display.update()");
		this.dom_element.innerText = new Date().toLocaleString();
	}
}

class Check_display {
	constructor (station_tag, suffix, clock, case_true, case_false) {
		this.case_true = case_true;
		this.case_false = case_false;
		this.clock = clock;
		this.datapoint = `${station_tag}-${suffix}`;
		this.create_dom_element();
		setInterval(() => {
			this.value_fetch();
		}, 5e3);
		this.render_value(false);
		this.value_fetch();
	}

	create_dom_element () {
		let td = document.createElement("td");
		td.innerText = "???";
		this.dom_element = td;
	}

	value_fetch () {
		api.tag_load_value(this.datapoint).then(value => {
			this.render_value(value);
			this.clock.update();
		});
	}

	render_value (value) {
		let text = value == "true" ? this.case_true : this.case_false;
		this.dom_element.innerHTML = text;
	}

	get_dom_element () {
		return this.dom_element;
	}
}


class Station_row {
	constructor (tree_table, item, map, table_model) {
		this.tree_table = tree_table;
		this.item = item;
		this.info = tree_table[item];
		this.map = map;
		this.table_model = table_model;
		this.process_code = map.current_view.process.code;
		this.station_code = map.current_view.process.children[item].code
		this.station_tag = `ERPM${this.process_code}-FQ${this.station_code}`;
		this.create_dom_element();
	}

	create_dom_element () {
		let row = document.createElement("tr");
		this.clock = new Clock_display();
		this.table_model.forEach(item => {
			let col;
			if (item.type == "SELFLABEL") {
				col = utils.tag_text("td", this.info.label);
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
			}
			row.append(col);
		});
		let xid = `l3-${this.item}`;
		row.onclick = () => {
			utils.goto_id(xid);
		};
		this.dom_element = row;
	}

	get_dom_element () {
		return this.dom_element;
	}
}

export default Station_row;

