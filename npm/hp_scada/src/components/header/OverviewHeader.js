import Component from '../../abstract/Component.js';
import ASSETSAPI from '../../lib/ASSETSAPI.js';


class OverviewHeader extends Component {
	constructor (map) {
		let nodeTag = "div";
		super(map, nodeTag);
		this.#make_child();
	}

	#make_child () {
		let svg_link = "hp/header_L1.svg";
		ASSETSAPI.fetch_asset(svg_link).then(svg => {
			this.node.appendChild(svg);
		});
	}
}

export default OverviewHeader;

