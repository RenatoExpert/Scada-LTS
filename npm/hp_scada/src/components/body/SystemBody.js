import Component from '../../prototype/Component.js';
import ASSETSAPI from '../../lib/ASSETSAPI.js';
import DOMAPI from '../../lib/DOMAPI.js';

class SystemBody extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-systembody";
		super(map, nodeTag, className);
		this.#get_child();
	}

	#get_child () {
		ASSETSAPI.fetch_svg("hp/bg/system.svg").then(svg => {
			DOMAPI.BindNavButton(svg, "hellofoo");
			this.node.appendChild(svg);
		});
	}
}

export default SystemBody;

