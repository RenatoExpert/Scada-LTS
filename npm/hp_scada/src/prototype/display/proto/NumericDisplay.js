import StatefulComponent from '../../StatefulComponent.js';

class NumericDisplay extends StatefulComponent {
	constructor (station_tag, suffix, engineering_unit) {
		let map = null;
		let nodeTag = "div";
		let className = "NumericDisplay";
		let datapoint = `${station_tag}-${suffix}`;
		super(datapoint, className);
		let case_undefined = "\u23f3";
		this.engineering_unit = engineering_unit;
		this.case_undefined = case_undefined;
		this.update_value();
		//	Apagar isso futuramente
		setTimeout(() => {
			this.update_value(15.2);
		}, 5e3);
	}

	update_value (value) {
		let text = "";
		text = value === undefined ? this.case_undefined : value;
		this.node.innerHTML = text;
	}
}

export default NumericDisplay;

