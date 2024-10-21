import Component from './Component.js';
import SummaryPage from './summary/SummaryPage.js';

class Summary extends Component {
	constructor (entries, map, nodeTag = "div", className = "hp-summary") {
		super(map, nodeTag, className);
		console.log({ Summary: this });
		this.#makeChildren(entries);
	}

	#makeChildren (entries) {
		let page = new SummaryPage(entries, this.map);
		this.node.appendChild(page.node);
	}
}

export default Summary;

