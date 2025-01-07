import Component from '../../prototype/Component.js';
import ASSETSAPI from '../../lib/ASSETSAPI.js';
import NAVAPI from '../../lib/NAVAPI.js';

class BannerBody extends Component {
	constructor (map) {
		let nodeTag = "div";
		let className = "hp-bannerbody";
		super(map, nodeTag, className);
		this.#get_child();
	}

	#get_child () {
		ASSETSAPI.fetch_svg("ruah/img/bg/l0-banner.svg").then(svg => {
			this.node.appendChild(svg);
			let timeInterval = 1e3;
			setTimeout(() => {
				NAVAPI.goto_id("system");
			}, timeInterval);
		});
	}
}

export default BannerBody;

