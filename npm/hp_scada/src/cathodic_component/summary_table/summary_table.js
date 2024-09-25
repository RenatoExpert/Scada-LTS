import utils from '../../utils/utils.js';
import Header_row from './header_row.js';
import Station_row from './station_row.js';

class Summary_table {
	constructor (map, items_per_page) {
		this.map = map;
		this.create_dom_element(items_per_page);
	}

	create_dom_element (items_per_page) {
		let tree_table = this.map.current_view.process.children;
		const current_page = this.map.current_page;
		let table = document.createElement("table");
		table.className = "summary";
		table.style.backgroundColor = "#f1f1f1";
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
		table.appendChild(css);
		this.header_row = new Header_row();
		table.append(this.header_row.get_dom_element());
		let index_number = 0;
		for(let item in tree_table) {
			console.log({ item });
			if(index_number < (current_page * items_per_page) && index_number >= (current_page - 1) * items_per_page) {
				let row = new Station_row(tree_table, item, this.map);
				table.append(row.get_dom_element());
			}
			index_number++;
		}
		this.dom_element = table;
	}

	get_dom_element () {
		return this.dom_element;
	}
}

export default Summary_table;

