import Component from './Component.js';

class StatefulComponent extends Component {
	constructor (datapoint, className = "StatefulComponent") {
		let map = null;
		let nodeTag = 'td';
		super (map, nodeTag, className);
	}

	get_address () {
		return this.address;
	}

	update_value (value) {
		this.node.innerText = value;
	}
}

export default StatefulComponent;
