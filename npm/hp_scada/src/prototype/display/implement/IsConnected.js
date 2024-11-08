import BinaryDisplay from '../proto/BinaryDisplay.js';

class IsConnected extends BinaryDisplay {
	constructor (isaTag) {
		let suffix = "comstatus";
		let trueLabel = "Conectado";
		let falseLabel = "Desconectado";
		let undefinedLabel = "Aguardando...";
		super(isaTag, suffix, trueLabel, falseLabel, undefinedLabel);
	}
}

export default IsConnected;

