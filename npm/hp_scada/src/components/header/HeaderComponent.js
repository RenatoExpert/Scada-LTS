import Component from '../../abstract/Component.js';
import OverviewHeader from './OverviewHeader.js';
//import UnitHeader;
//import DetailHeader;

function make_menus (map) {
	let children = [];
	if (map.params.address == 'banner') {
	} else {
		let l1_menu = new OverviewHeader();
		children.push(l1_menu);
		if (map.level.max > 1) {
			//let l2_menu = new UnitHeader(map);
			//children.push(l2_menu);
			if (map.level.max > 2) {
				//let l3_menu = new DetailHeader(map);
				//children.push(l3_menu);
			}
		}
	}
	return children;
}

class HeaderComponent extends Component {
	constructor (map) {
		let nodeTag = "div";
		let children = make_menus(map);
		super(map, nodeTag, children);
	}
}

export default HeaderComponent;

