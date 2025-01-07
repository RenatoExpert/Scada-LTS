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
		this.params.page = parseInt(this.params.page) || 1;
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
				regex: /erpm/,
				template: "erpm"
			},
			{
				regex: /rectifiers/,
				template: "rectifiers"
			},
			{
				regex: /cathodic/,
				template: "cathodic"
			},
			{
				regex: /graphics/,
				template: "graphics"
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

