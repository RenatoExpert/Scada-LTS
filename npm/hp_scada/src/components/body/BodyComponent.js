import Component;

import SystemBody;
import StationBody;
import RectifiersBody;
import CathodicBody;
import RelatoryBody;
import GraphicBody;

class BodyComponent {
	constructor (map) {
		let nodeTag = "div";
		let children = [ this.#get_child(map) ];
		super(map, nodeTag, children);
	}

	#get_child (map) {
		switch(map.template) {
			case 'system':
				child = new SystemBody();
				break;
			case 'erpm':
				child = new StationsBody();
				break;
			case 'rectifiers':
				child = new RectifiersBody();
				break;
			case 'cathodic':
				child = new CathodicBody();
				break;
			case 'relatory':
				child = new RelatoryBody();
				break;
			case 'graphic':
				child = new GraphicBody();
				break;
			default:
				console.warn(`Template is not set. \n map.template: ${map.template}`);
		}
		return child;
	}
}

export default BodyComponent;

