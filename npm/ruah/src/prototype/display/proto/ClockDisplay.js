import StatefulComponent from '../../StatefulComponent.js';

class ClockDisplay extends StatefulComponent {
	constructor (station_tag) {
		let map = null;
		let nodeTag = "div";
		let className = "ClockDisplay";
		let datapoint = station_tag;
		super(datapoint, className);
		let case_undefined = "\u23f3";
		this.case_undefined = case_undefined;
		this.update_value();
		//	Apagar isso futuramente
		setTimeout(() => {
			this.update_value(new Date());
		}, 5e3);
	}

	update_value (value) {
		let text = "";
		text = value === undefined ? this.case_undefined : (new Date(value)).toLocaleString();
		this.node.innerHTML = text;
	}
}

export default ClockDisplay;

