import StatefulComponent from '../../StatefulComponent.js';

class BinaryDisplay extends StatefulComponent {
	constructor (station_tag, suffix, case_true, case_false) {
		let map = null;
		let nodeTag = "div";
		let className = "BinaryDisplay";
		let datapoint = `${station_tag}-${suffix}`;
		super(datapoint, className);
		this.case_true = case_true;
		this.case_false = case_false;
		this.update_value('52');
	}

	update_value () {
		let text = value == "true" ? this.case_true : this.case_false;
		this.node.innerHTML = text;
	}
}

export default BinaryDisplay;

