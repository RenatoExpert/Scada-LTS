import Component from '../../abstract/Component.js';
import ASSETSAPI from '../../lib/ASSETSAPI.js';

function make_child () {
	let child = document.createElement('div');
	let svg_link = "hp/header_L1.svg";
	ASSETSAPI.fetch_asset(svg_link).then(svg => {
		child.append(svg);
	});
	return child;
}

class OverviewHeader extends Component {
	constructor (map) {
		let nodeTag = "div";
		let children = [ make_child() ];
		super(map, nodeTag, children);
	}
}

export default OverviewHeader;

