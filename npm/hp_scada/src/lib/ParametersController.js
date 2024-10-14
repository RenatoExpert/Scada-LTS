class ParametersController {
	#readOperation (parameter) {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let value = urlParams.get(parameter);
		return value;
	}

	static readMany (/**/) {
		let result = {};
		for (let i = 0;  i < arguments.length; i++) {
			let parameter = arguments[i];
			let value = this.#readOperation(parameter);
			result[parameter] = value;
		}
		return result;
	}

	static read (parameter) {
		return this.#readOperation(parameter);
	}
}

export default ParametersController;

