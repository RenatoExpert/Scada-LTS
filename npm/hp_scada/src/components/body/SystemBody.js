import Component from '../../abstract/Component.js';
import ASSETSAPI from '../../lib/ASSETSAPI.js';

class SystemBody extends Component {
	constructor (map) {
		let nodeTag = "div";
		super(map, nodeTag);
		this.#get_child();
	}

	#get_child () {
		ASSETSAPI.fetch_svg("hp/bg/system.svg").then(svg => {
			this.node.appendChild(svg);
		});
	}
}

export default SystemBody;

