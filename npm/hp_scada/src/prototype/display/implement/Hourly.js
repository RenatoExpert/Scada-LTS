import ButtonDisplay from "../proto/ButtonDisplay.js";

class Hourly extends ButtonDisplay {
	constructor (isatag) {
		let text = "Relatório Horário";
		let target = `relatory:hourly:${isatag}`;
		super(text, target);
	}
}

export default Hourly;

