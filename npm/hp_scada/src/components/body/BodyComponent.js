import Component from '../../abstract/Component.js';

import BannerBody from './BannerBody.js';
import SystemBody from './SystemBody.js';
import ERPMBody from './ERPMBody.js';
/*
import StationBody;
import RectifiersBody;
import CathodicBody;
import RelatoryBody;
import GraphicBody;
*/

class BodyComponent extends Component {
	constructor (map) {
		let nodeTag = "div";
		super(map, nodeTag);
		this.#get_child();
	}

	#get_child () {
		let child;
		switch(this.map.template) {
			case 'banner':
				child = new BannerBody(this.map);
				break;
			case 'system':
				child = new SystemBody(this.map);
				break;
			case 'erpm':
				child = new ERPMBody(this.map);
				break;
				/*
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
				*/
			default:
				console.warn(`Template is not set. \n map.template: ${this.map.template}`);
		}
		return this.node.appendChild(child.node);
	}
}

export default BodyComponent;

