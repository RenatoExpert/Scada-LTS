import Component from '../../abstract/Component.js';
import ASSETSAPI from '../../lib/ASSETSAPI.js';

import StationsOverview from './stations/StationsOverview.js';

class StationsBody extends Component {
	constructor (map) {
		let nodeTag = "div";
		super(map, nodeTag);
		this.#get_child();
	}

	#get_child () {
		let child;
		switch(this.map.levelmap.max) {
			case 1:
				child = new StationsOverview(this.map);
				break;
			/*
			case 2:
				child = new SystemBody();
				break;
			case 3:
				child = new StationsBody();
				break;
				*/
			default:
				console.warn(`map.levelmap.max must be between 1 and 3: ${this.map.levelmap.max}`);
		}
		return this.node.appendChild(child.node);
	}
}

export default StationsBody;

