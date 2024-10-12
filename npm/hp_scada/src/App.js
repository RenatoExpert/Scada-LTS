import DOMAPI from './lib/DOMAPI.js';

import Map from './Map.js';
import RootComponent from './components/RootComponent.js';


class App {
	constructor () {
		this.prepare();
	}

	prepare () {
		this.params = DOMAPI.ParametersController.readMany("address", "reference", "page");
		this.map = new Map().setParameters(params);
		this.rootComponent = new RootComponent(this.map);
		this.node = this.rootComponent.getNode();
	}

	print () {
		let canvasId = 'viewContent';
		DOMAPI.Observer(canvasId).when_exist(canvas => {
			canvas.append(this.node());
		});
	}
}

export default App;

