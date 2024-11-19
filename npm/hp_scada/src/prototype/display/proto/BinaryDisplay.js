import StatefulComponent from '../../StatefulComponent.js';

class BinaryDisplay extends StatefulComponent {
	constructor (station_tag, suffix, case_true, case_false, case_undefined) {
		let map = null;
		let nodeTag = "div";
		let className = "BinaryDisplay";
		let datapoint = `${station_tag}-${suffix}`;
		super(datapoint, className);
		this.case_true = case_true;
		this.case_false = case_false;
		this.case_undefined = case_undefined;
		this.update_value();
		//	Apagar isso futuramente
		setTimeout(() => {
			this.update_value(true);
		}, 5e3);
	}

	update_value (value) {
		let text = "";
		if (value === undefined) {
			text = this.case_undefined;
		} else {
			text = value ? this.case_true : this.case_false;
		}
		this.node.innerHTML = text;
	}
}

export default BinaryDisplay;

