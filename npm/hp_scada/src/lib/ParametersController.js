function readOperation (parameter) {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let value = urlParams.get(parameter);
	return value;
}

class ParametersController {
	static readMany (/**/) {
		let result = {};
		for (let i = 0;  i < arguments.length; i++) {
			let parameter = arguments[i];
			let value = readOperation(parameter);
			result[parameter] = value;
		}
		return result;
	}

	static read (parameter) {
		return readOperation(parameter);
	}
}

export default ParametersController;

