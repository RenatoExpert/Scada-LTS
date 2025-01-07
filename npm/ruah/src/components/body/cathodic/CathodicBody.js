
import Component from '../../../prototype/Component.js';

import CathodicOverview from './overview/CathodicOverview.js';

/*
import ASSETSAPI from '../../../lib/ASSETSAPI.js';

import ERPMOverview from './overview/ERPMOverview.js';
import ERPMUnit from './unit/ERPMUnit.js';
*/

class CathodicBody extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-cathodicbody";
		super(map, nodeTag, className);
		this.#get_child();
	}

	#get_child () {
		let child;
		switch (this.map.levelmap.max) {
			case 1:
				child = new CathodicOverview(this.map);
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
				child = {
					node: document.createElement("div")
				};
				child.node.innerText = "Internal Error\n check it on console";
		}
		this.node.appendChild(child.node);
	}
}

export default CathodicBody;

