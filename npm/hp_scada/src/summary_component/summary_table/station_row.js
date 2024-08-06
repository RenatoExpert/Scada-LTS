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
	constructor (tree_table, item, map) {
		this.tree_table = tree_table;
		this.item = item;
		this.info = tree_table[item];
		this.map = map;
		this.process_code = map.current_view.process.code;
		this.station_code = map.current_view.process.children[item].code
		this.station_tag = `ERPM${this.process_code}-FQ${this.station_code}`;
		this.create_dom_element();
	}

	create_dom_element () {
		let row = document.createElement("tr");
		let label = utils.tag_text("td", this.info.label);
		row.append(label);
		let suffix_modem = "SG-1";
		let modem = new Check_display(this.station_tag, suffix_modem, this.clock, "Conectado", "Desconectado");
		row.append(modem.get_dom_element());
		let suffix_com = "SG-1";
		let com = new Check_display(this.station_tag, suffix_com, this.clock, "OK", "Err");
		row.append(com.get_dom_element());
		this.clock = new Clock_display();
		row.append(this.clock.get_dom_element());
		let suffix_pi = "PI-1";
		let pressure_in = new Numeric_display(this.station_tag, suffix_pi, "Kgf/cm²", this.clock);
		row.append(pressure_in.get_dom_element());
		let suffix_pi2 = "PI-2";
		let pressure_out = new Numeric_display(this.station_tag, suffix_pi2, "Kgf/cm²", this.clock);
		row.append(pressure_out.get_dom_element());
		let suffix_ti = "TI-1";
		let temp = new Numeric_display(this.station_tag, suffix_ti, "ºC", this.clock);
		row.append(temp.get_dom_element());
		let suffix_fi = "FI-1";
		let flow = new Numeric_display(this.station_tag, suffix_fi, "m³/dia", this.clock);
		row.append(flow.get_dom_element());
		let suffix_fqi = "FQI-1";
		let current_month = new Numeric_display(this.station_tag, suffix_fqi, "m³", this.clock);
		row.append(current_month.get_dom_element());
		let suffix_fqia = "FQIA-1";
		let previous_month = new Numeric_display(this.station_tag, suffix_fqia, "m³", this.clock);
		row.append(previous_month.get_dom_element());
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

