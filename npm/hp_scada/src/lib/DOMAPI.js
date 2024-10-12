import Observer from './Observer.js';
import ParameterController from './ParameterController.js';

class DOMAPI {
	static Observer (nodeId) {
		return new Observer(nodeId);
	}

	static ParametersController = ParametersController;
}

export default DOMAPI;

