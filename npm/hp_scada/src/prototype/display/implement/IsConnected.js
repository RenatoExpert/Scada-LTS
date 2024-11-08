import BinaryDisplay from '../proto/BinaryDisplay.js';

class IsConnected extends BinaryDisplay {
	constructor (isaTag) {
		let suffix = "comstatus";
		let trueLabel = "Conectado";
		let falseLabel = "Desconectado";
		let case_undefined = "Aguardando...";
		super(isaTag, suffix, trueLabel, falseLabel, case_undefined);
	}
}

export default IsConnected;

