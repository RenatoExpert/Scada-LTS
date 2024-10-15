import LevelMap from './LevelMap.js';

class Map {
	constructor (tree) {
		this.tree = tree;
	}

	setParameters (params) {
		this.params = params;
		this.params.address = this.params.address || "banner";
		console.log(params);
		this.levelmap = new LevelMap(this.tree, params.address);
		this.setTemplate();
		return this;
	}

	setTemplate () {
		let template;
		switch (this.params.address) {
			case "banner":
				template = "banner";
				break;
			case "system":
				template = "system";
				break;
		}
		this.template = template;
	}
}


export default Map;

