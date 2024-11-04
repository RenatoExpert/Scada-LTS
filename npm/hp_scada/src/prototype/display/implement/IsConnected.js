import BinaryDisplay from '../proto/BinaryDisplay.js';

class IsConnected extends BinaryDisplay {
	constructor (isaTag) {
		let suffix = "comstatus";
		let trueLabel = "Conectado";
		let falseLabel = "Desconectado";
		super(isaTag, suffix, trueLabel, falseLabel);
	}
}

export default IsConnected;

