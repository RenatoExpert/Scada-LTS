import Component from './Component.js';
import SummaryPage from './summary/SummaryPage.js';
import SummaryTable from './summary/SummaryTable.js';

function howManyPages (count, max_per_page) {
	let avg = count / max_per_page;
	let floor = Math.floor(avg) + 1;
	return floor;
}

class Summary extends Component {
	constructor (entries, map, table_particle, table_model) {
		let nodeTag = "div";
		let className = "hp-summary";
		super(map, nodeTag, className);
		this.entries = entries;
		this.max_per_page = 20;
		this.last = howManyPages(entries.length, this.max_per_page);
		this.index = this.map.params.page;
		this.table_particle = table_particle;
		this.table_model = table_model;
		console.log({ Summary: this });
		this.#makeChildren();
		console.log({ Summary: this });
	}

	#makeChildren () {
		let page = new SummaryPage(this.index, this.last);
		this.node.appendChild(page.node);
		let table = new SummaryTable(this.entries, this.map, this.index, this.max_per_page, this.table_particle, this.table_model);
		this.node.appendChild(table.node);
	}
}

export default Summary;

