import Component from "../../../../prototype/Component";
import Synoptic from "../../../../prototype/Synoptic";

class ERPMDetails extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-erpmdetails";
		super(map, nodeTag, className);
		this.#make_child();
	}

	#make_child () {
		let stationType = this.map.levelmap[3].class || "rpm-single";
		let path = `ruah/img/bg/${stationType}.svg`;
		let diagram = new Synoptic(this.map, path);
		this.node.append(diagram.node);
	}
}

export default ERPMDetails;

