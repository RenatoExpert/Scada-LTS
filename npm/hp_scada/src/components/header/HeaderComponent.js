import Component from '../../prototype/Component.js';
import OverviewHeader from './OverviewHeader.js';
import UnitHeader from './UnitHeader.js';
//import UnitHeader;
//import DetailHeader;

class HeaderComponent extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-headercomponent"
		super(map, nodeTag, className);
		this.#make_menus();
		this.#make_subtitle();
	}

	#make_menus () {
		if (this.map.params.address == 'banner') {
		} else {
			let l1_menu = new OverviewHeader(this.map);
			this.node.appendChild(l1_menu.node);
			if (this.map.levelmap[1].name == "erpm" && this.map.levelmap.max < 3) {
				let l2_menu = new UnitHeader(this.map);
				this.node.appendChild(l2_menu.node);
				/*
				if (this.map.level.max > 2) {
					//let l3_menu = new DetailHeader(map);
					//children.push(l3_menu);
				}
				*/
			}
		}
	}

	#make_subtitle () {
		//	This must be a separated class in a separated file
		let subtitle = document.createElement("div");
		subtitle.id = "hp-headers-subtitle";
		subtitle.className = "labelDiv";
		subtitle.style.position = "absolute";
		subtitle.style.display = "none";
		subtitle.style.left = "200px";
		subtitle.style.top = "200px";
		this.node.appendChild(subtitle);
	}
}

export default HeaderComponent;

