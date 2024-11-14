import ButtonDisplay from "../proto/ButtonDisplay.js";

class Hourly extends ButtonDisplay {
	constructor (isatag) {
		let target = `relatory:hourly:${isatag}`;
		super(target);
	}
}

export default Hourly;

