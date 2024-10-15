import Component from '../../abstract/Component.js';

import BannerBody from './BannerBody.js';

/*
import SystemBody;
import StationBody;
import RectifiersBody;
import CathodicBody;
import RelatoryBody;
import GraphicBody;
*/

class BodyComponent {
	#get_child (map) {
		switch(map.template) {
			case 'banner':
				child = new BannerBody(map);
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

	constructor (map) {
		let nodeTag = "div";
		let children = [ this.#get_child(map) ];
		super(map, nodeTag, children);
	}
}

export default BodyComponent;

