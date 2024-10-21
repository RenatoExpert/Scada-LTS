import Component from '../../../abstract/Component.js';
import ERPMSummary from '../../../widget/erpm/ERPMSummary.js';

class ERPMUnit extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-erpmunit";
		super(map, nodeTag, className);
		this.#make_child();
	}

	#make_child () {
		let unit_children = this.map.levelmap[2].children;
		let unit_entries = Object.entries(unit_children);
		let summary = new ERPMSummary(unit_entries, this.map);
		this.node.appendChild(summary.node);
	}
}

export default ERPMUnit;

