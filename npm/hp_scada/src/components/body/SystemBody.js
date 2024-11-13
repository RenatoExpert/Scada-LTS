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
			{
				let rectId = "l1-rectifiers";
				let rectifiersButton = svg.querySelector("#" + rectId);
				DOMAPI.BindNavButton(rectifiersButton, "rectifiers");
			}
			{
				let rectId = "l1-cathodic";
				let rectifiersButton = svg.querySelector("#" + rectId);
				DOMAPI.BindNavButton(rectifiersButton, "cathodic");
			}
			this.node.appendChild(svg);
		});
	}
}

export default SystemBody;

