import Component from '../../../abstract/Component.js';
import ASSETSAPI from '../../../lib/ASSETSAPI.js';


class StationsOverview extends Component {
	constructor (map) {
		let nodeTag = "div";
		super(map, nodeTag);
		this.#make_child();
	}

	#make_child () {
		let path = "hp/stations.svg";
		ASSETSAPI.fetch_svg(path).then(svg => {
			this.node.appendChild(svg);
		});
	}
}

export default StationsBody;

