import LevelMap from './LevelMap.js';

class Map {
	constructor (tree) {
		this.tree = tree;
		this.title = "Processo X";
		this.user = {
			fullname: "Luiz Fernando"
		};
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
		let routerTable = [
			{
				regex: /banner/,
				template: "banner"
			},
			{
				regex: /system/,
				template: "system"
			},
			{
				regex: /stations/,
				template: "stations-l1"
			},
			{
				regex: /stations:*/,
				template: "stations-l2"
			},
			{
				regex: /stations:*:*/,
				template: "stations-l3"
			}
		];
		for (let i = 0; i < routerTable.length; i++) {
			let route = routerTable[i];
			if (route.regex.test(this.params.address)) {
				this.template = route.template;
				break;
			}
		}
	}
}

export default Map;

