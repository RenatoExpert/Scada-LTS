import Component from '../../../../prototype/Component.js';
import ASSETSAPI from '../../../../lib/ASSETSAPI.js';

class ERPMOverview extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-erpmoverview";
		super(map, nodeTag, className);
		this.#make_child();
	}

	#make_child () {
		let path = "hp/bg/erpm.svg";
		ASSETSAPI.fetch_svg(path).then(svg => {
			this.node.appendChild(svg);
		});
	}
}

export default ERPMOverview;

