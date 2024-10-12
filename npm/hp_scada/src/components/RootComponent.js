import Component from '../abstract/Component.js';
import HeaderComponent from './header/HeaderComponent.js';
//import BodyComponent from './body/BodyComponent.js';

class RootComponent extends Component {
	constructor (map) {
		let nodeTag = "div";
		let header = new HeaderComponent(map);
		//let body = new BodyComponent(map);
		let children = [
			header//,
			//body
		];
		super(map, nodeTag, children);
	}
}

export default RootComponent;

