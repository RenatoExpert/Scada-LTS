import Component from '../../abstract/Component.js';
import ASSETSAPI from '../../lib/ASSETSAPI.js';

class BannerBody extends Component {
	constructor (map) {
		let nodeTag = "div";
		let children = [ this.#get_child(map) ];
		super(map, nodeTag, children);
	}

	#get_child (map) {
		let div = document.createElement("div");
		ASSETSAPI.fetch_svg("hp/bg/l0-banner.svg").then(svg => {
			div.appendChild(svg);
		});
		return div;
	}
}

export default BannerBody;

