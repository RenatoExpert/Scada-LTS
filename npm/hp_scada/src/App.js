import DOMAPI;

import Map;
import RootComponent;


class App {
	constructor () {
		this.prepare();
	}

	prepare () {
		this.params = DOMAPI.getParametersSet("address", "reference", "page");
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

