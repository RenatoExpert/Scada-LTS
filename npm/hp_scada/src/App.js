import DOMAPI from './lib/DOMAPI.js';
import ASSETSAPI from './lib/ASSETSAPI.js';

import Map from './Map.js';
import RootComponent from './components/RootComponent.js';


class App {
	download_tree (tree_link) {
		return ASSETSAPI.fetch_asset(tree_link);
	}

	constructor () {
		let tree_link = "hp/views_tree.js";
		this.tree_promise = this.download_tree(tree_link);
		this.tree_promise.then(tree => {
			console.log({ tree });
			this.params = DOMAPI.ParametersController.readMany("address", "reference", "page");
			console.log({ app: this.params });
			this.map = new Map(tree).setParameters(this.params);
			console.log({ map: this.map });
			this.rootComponent = new RootComponent(this.map);
			this.node = this.rootComponent.getNode();
		});
	}

	print () {
		this.tree_promise.then(() => {
			let canvasId = 'viewContent';
			DOMAPI.Observer(canvasId).when_exist(canvas => {
				canvas.append(this.node);
				console.log("Plugin initialized with success");
			});
		});
	}
}

export default App;

