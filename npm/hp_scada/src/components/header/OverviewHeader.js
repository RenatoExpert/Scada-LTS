import Component from '../../abstract/Component.js';
import ASSETSAPI from '../../lib/ASSETSAPI.js';

class OverviewHeader extends Component {
	constructor (map) {
		let nodeTag = "div";
		let children = [ this.#make_child(map) ];
		super(map, nodeTag, children);
	}

	#make_child (map) {
		let child = document.createElement('div');
		let svg_link = "hp/header_L1.svg";
		ASSETSAPI.fetch_asset(svg_link).then(svg => {
			child.append(svg);
		});
		return div;
	}
}

export default OverviewHeader;

