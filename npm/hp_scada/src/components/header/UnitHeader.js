import Component from '../../prototype/Component.js';
import ASSETSAPI from '../../lib/ASSETSAPI.js';
import NAVAPI from '../../lib/NAVAPI.js';

class InlineMenu extends Component {
	constructor (map, targetAddress) {
		let nodeTag = "div";
		let className = "hp-inlinemenu";
		super(map, nodeTag, className);
		this.targetAddress = targetAddress;
		this.#make_children();
	}

	#make_children () {
		this.node.style = {
			display: "inline-flex",
			width: "1280px",
			flexWrap: "wrap",
			padding: "0px 5px"
		};
		let erpm_children = this.map.tree.root.children.erpm.children;
		Object.entries(erpm_children).forEach(([nodeId, unit]) => {
			let button = document.createElement("button");
			let newAddress = this.targetAddress + ":" + nodeId;
			button.textContent = unit.label;
			button.onclick = () => {
				NAVAPI.goto_id(newAddress);
			};
			button.id = `button-${newAddress}`;
			button.style.width = "90px";
			button.style.height = "45px";
			this.node.append(button);
		});
	}
}


class UnitHeader extends Component {
	constructor (map) {
		let nodeTag = "div";
		super(map, nodeTag);
		this.#make_child();
	}

	#make_child () {
		let menu = new InlineMenu(this.map, "erpm");
		this.node.appendChild(menu.node);
	}
}

export default UnitHeader;

