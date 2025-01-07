import Component from "../Component";
import legacy_graphic from "./graphic_component/graphic_component";

//	All files inside ./graphic_component are legacy and be rewritten in new standard

class Graphics extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-graphics";
		super(map, nodeTag, className);
		this.#make_child();
	}

	#make_child () {
		//	current_view is a legacy component
		let graphic = new legacy_graphic(this.map);
		this.node.appendChild(graphic.node);
	}
}

export default Graphics;