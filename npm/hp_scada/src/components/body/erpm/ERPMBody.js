import Component from '../../../prototype/Component.js';
//import ASSETSAPI from '../../../lib/ASSETSAPI.js';

import ERPMDetails from './details/ERPMDetails.js';
import ERPMOverview from './overview/ERPMOverview.js';
import ERPMUnit from './unit/ERPMUnit.js';

class ERPMBody extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-erpmbody";
		super(map, nodeTag, className);
		this.#get_child();
	}

	#get_child () {
		let child;
		switch (this.map.levelmap.max) {
			case 1:
				child = new ERPMOverview(this.map);
				break;
			case 2:
				child = new ERPMUnit(this.map);
				break;
			case 3:
				child = new ERPMDetails(this.map);
				break;
			case 4:
				child = new ERPMMaintenance(this.map);
				
			default:
				console.warn(`map.levelmap.max must be between 1 and 3: ${this.map.levelmap.max}`);
				child = document.createElement("div");
				child.innerText("Internal Error\n check it on console");
		}
		this.node.appendChild(child.node);
	}
}

export default ERPMBody;

