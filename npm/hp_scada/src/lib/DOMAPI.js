import Observer from './Observer.js';
import ParametersController from './ParametersController.js';

import NAVAPI from './NAVAPI.js';

class DOMAPI {
	static Observer (nodeId) {
		return new Observer(nodeId);
	}

	static ParametersController = ParametersController;

	static BindNavButton (element, target) {
		element.addEventListener("click", e => {
			NAVAPI.goto_id(target);
		});
	}
}

export default DOMAPI;

