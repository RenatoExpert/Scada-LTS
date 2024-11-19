import BinaryDisplay from '../proto/BinaryDisplay.js';

class Communication extends BinaryDisplay {
	constructor (isaTag) {
		let suffix = "comstatus";
		let trueLabel = "OK";
		let falseLabel = "Err";
		let undefinedLabel = "\u23f3";
		super(isaTag, suffix, trueLabel, falseLabel, undefinedLabel);
	}
}

export default Communication;

