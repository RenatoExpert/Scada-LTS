import Component from '../Component.js';
import TableHeader from './TableHeader.js';
import TableRow from './TableRow.js';

class SummaryTable extends Component {
	constructor (map, currentPage, max_per_page, table_particle, table_model) {
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
		console.log({ SummaryTable: this });
		this.#makeChildren();
	}

	#makeChildren () {
		let header = new TableHeader(this.model);
		this.node.append(header.node);
		let from = this.index * this.table_size;
		let to = from + this.table_size - 1;
		let children = this.map.levelmap[2].children;
		let entries = Object.keys(children);
		entries.slice(from, to).forEach(childName => {
			let childLabel = children[childName];
			let row = new TableRow(this.table_model, childName, childLabel);
			this.node.append(row.node);
		});
	}
}

export default SummaryTable;

