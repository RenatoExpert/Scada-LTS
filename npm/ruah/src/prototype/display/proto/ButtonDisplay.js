import Component from "../../Component.js";
import NAVAPI from "../../../lib/NAVAPI.js";

class ButtonDisplay extends Component {
	constructor (text, target) {
		let nodeTag = "button";
		let className = "ButtonDisplay";
		super(null, nodeTag, className);
		this.node.innerText = text;
		this.node.addEventListener("click", e => {
			NAVAPI.goto_id(target);
		});
	}
}

export default ButtonDisplay;

