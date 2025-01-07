import Component from '../../../../prototype/Component.js';
import Synoptic from "../../../../prototype/Synoptic";

class RectifiersUnit extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-rectifiersunit";
		super(map, nodeTag, className);
		this.#make_child();
	}

	#make_child () {
		let path = "ruah/img/bg/rectifiers.svg";
		let diagram = new Synoptic(this.map, path);
		this.node.append(diagram.node);
	}
}

export default RectifiersUnit;

