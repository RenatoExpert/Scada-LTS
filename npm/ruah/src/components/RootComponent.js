import Component from '../prototype/Component.js';
import HeaderComponent from './header/HeaderComponent.js';
import BodyComponent from './body/BodyComponent.js';

class RootComponent extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-rootcomponent";
		let header = new HeaderComponent(map);
		let body = new BodyComponent(map);
		super(map, nodeTag, className);
		this.node.appendChild(header.node);
		this.node.appendChild(body.node);
	}
}

export default RootComponent;

