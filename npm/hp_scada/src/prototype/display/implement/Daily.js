import ButtonDisplay from "../proto/ButtonDisplay.js";

class Daily extends ButtonDisplay {
	constructor (isatag) {
		let text = "Relatório Diário";
		let target = `relatory:daily:${isatag}`;
		super(text, target);
	}
}

export default Daily;

