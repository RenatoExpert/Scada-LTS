import Component from '../../prototype/Component.js';

import BannerBody from './BannerBody.js';
import SystemBody from './SystemBody.js';
import ERPMBody from './erpm/ERPMBody.js';
import GraphicsBody from './GraphicsBody.js';
import RectifiersBody from './rectifiers/RectifiersBody.js';
import CathodicBody from './cathodic/CathodicBody.js';

/*
import CathodicBody;
import RelatoryBody;
import GraphicBody;
*/

class BodyComponent extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-bodycomponent";
		super(map, nodeTag, className);
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
			case 'rectifiers':
				child = new RectifiersBody(this.map);
				break;
			case 'cathodic':
				child = new CathodicBody(this.map);
				break;
			case 'graphics':
				child = new GraphicsBody(this.map);
				break;
				/*
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

