class ParametersController {
	static read (parameter) {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let value = urlParams.get(parameter);
		return value;
	}

	static readMany (/**/) {
		let result = {};
		for (let i = 0;  i < arguments.length; i++) {
			let parameter = arguments[i];
			let value = this.read(parameter);
			result[parameter] = value;
		}
		return result;
	}
}

export default ParametersController;

