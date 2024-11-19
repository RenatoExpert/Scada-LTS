import Component from '../../../prototype/Component.js';

import RectifiersOverview from './overview/RectifiersOverview.js';

/*
import ASSETSAPI from '../../../lib/ASSETSAPI.js';

import ERPMOverview from './overview/ERPMOverview.js';
import ERPMUnit from './unit/ERPMUnit.js';
*/

class RectifiersBody extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-rectifiersbody";
		super(map, nodeTag, className);
		this.#get_child();
	}

	#get_child () {
		let child;
		switch (this.map.levelmap.max) {
			case 1:
				child = new RectifiersOverview(this.map);
				break;
				/*
			case 2:
				child = new RectifiersUnit(this.map);
				break;
			/*
			case 3:
				child = new StationsBody();
				break;
				*/
			default:
				console.warn(`map.levelmap.max must be between 1 and 3: ${this.map.levelmap.max}`);
				child = document.createElement("div");
				child.innerText("Internal Error\n check it on console");
		}
		this.node.appendChild(child.node);
	}
}

export default RectifiersBody;

