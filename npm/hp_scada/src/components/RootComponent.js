import Component;
import HeaderComponent;
import BodyComponent;

class RootComponent extends Component {
	constructor (map) {
		let nodeTag = "div";
		let header = new HeaderComponent(map);
		let body = new BodyComponent(map);
		let children = [
			header,
			body
		];
		super(map, nodeTag, children);
	}
}

export default RootComponent;

