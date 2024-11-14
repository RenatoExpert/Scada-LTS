import ButtonDisplay from "../proto/ButtonDisplay.js";

class Daily extends ButtonDisplay {
	constructor (isatag) {
		let target = `relatory:hourly:${isatag}`;
		super(target);
	}
}

export default Daily;

