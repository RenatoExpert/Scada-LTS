import Component from '../../abstract/Component.js';
import OverviewHeader from './OverviewHeader.js';
//import UnitHeader;
//import DetailHeader;

class HeaderComponent extends Component {
	constructor (map) {
		let nodeTag = "div";
		super(map, nodeTag);
		let children = this.#make_menus();
	}

	#make_menus () {
		if (this.map.params.address == 'banner') {
		} else {
			let l1_menu = new OverviewHeader();
			this.node.appendChild(l1_menu);
			if (this.map.level.max > 1) {
				//let l2_menu = new UnitHeader(map);
				//children.push(l2_menu);
				if (this.map.level.max > 2) {
					//let l3_menu = new DetailHeader(map);
					//children.push(l3_menu);
				}
			}
		}
	}
}

export default HeaderComponent;

