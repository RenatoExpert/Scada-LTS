import LevelMap from './LevelMap.js';

class Map {
	constructor (tree) {
		this.tree = tree;
	}

	setParameters (params) {
		this.params = params;
		this.params.address = this.params.address || "system";
		console.log(params);
		this.levelmap = new LevelMap(this.tree, params.address);
		return this;
	}
}


export default Map;

