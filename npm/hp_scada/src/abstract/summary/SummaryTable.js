import Component from '../Component.js';
import TableRow from './TableRow.js';

class SummaryTable extends Component {
	constructor (map, currentPage, max_per_page, table_model, table_particle) {
		let nodeTag = "table";
		let className = "hp-summarytable";
		super(map, nodeTag, className);
		this.node.style.backgroundColor = "#f1f1f1";
		let css = document.createElement("style");
		css.innerHTML = `
			tr:nth-child(even) {
				background-color: #ddddff;
			}
			tr:hover {
				background-color: #aaaadd;
			}
			td, th {
				padding: 2px 7px;
			}
		`;
		this.node.appendChild(css);
		this.index = currentPage;
		this.table_size = max_per_page;
		this.model = table_model;
		this.particle = table_particle;
		this.#makeChildren();
	}

	#makeChildren () {
		let header_row = new Header_row(this.table_model);
		this.node.append(header_row.node);
		let from = this.index * this.table_size;
		let to = from + this.table_size - 1;
		entries.slice(from, to).forEach(child => {
			let row = new TableRow(this.table_model, child);
			this.node.append(row.node);
		});
	}
}

export default SummaryTable;

