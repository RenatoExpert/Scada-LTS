import Observer from './Observer.js';
import ParametersController from './ParametersController.js';

class DOMAPI {
	static Observer (nodeId) {
		return new Observer(nodeId);
	}

	static ParametersController = ParametersController;
}

export default DOMAPI;

