import Component from '../Component.js';
import TableHeader from './TableHeader.js';
import TableRow from './TableRow.js';

class SummaryTable extends Component {
	constructor (entries, map, currentPage, max_per_page, table_particle, table_model) {
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
		this.entries = entries;
		console.log({ SummaryTable: this });
		this.#makeChildren();
	}

	#makeChildren () {
		let header = new TableHeader(this.model);
		this.node.append(header.node);
		let from = (this.index - 1) * this.table_size;
		let to = from + this.table_size - 1;
		let slice = this.entries.slice(from, to);
		let preTag = this.map.params.address;
		slice.forEach(([childName, child]) => {
			let childLabel = child.label;
			let isaTag = `${preTag}:${childName.toLowerCase()}`;
			let row = new TableRow(this.model, childName, childLabel, isaTag);
			this.node.append(row.node);
		});
		console.log({ from, to, slice, here: this });
	}
}

export default SummaryTable;

