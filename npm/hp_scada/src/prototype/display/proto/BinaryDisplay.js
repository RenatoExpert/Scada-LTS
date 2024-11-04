import Component from '../../Component.js';

class BinaryDisplay extends Component {
	constructor (station_tag, suffix, case_true, case_false) {
		this.case_true = case_true;
		this.case_false = case_false;
		this.datapoint = `${station_tag}-${suffix}`;
		this.create_dom_element();
		this.render_value(false);
		this.value_fetch();
	}

	create_dom_element () {
		let td = document.createElement("td");
		td.innerText = "???";
		this.dom_element = td;
	}

	render_value (value) {
		let text = value == "true" ? this.case_true : this.case_false;
		this.dom_element.innerHTML = text;
	}

	get_dom_element () {
		return this.dom_element;
	}
}

export default BinaryDisplay;

