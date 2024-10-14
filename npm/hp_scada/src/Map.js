import LevelMap from './LevelMap.js';

class Map {
	constructor (tree) {
		this.tree = tree;
	}

	setParameters (params) {
		this.params = params;
		this.levelmap = new LevelMap(tree, params.address);
		return this;
	}
}


export default Map;

