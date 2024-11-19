import utils from '../../utils/utils.js';

class Header_row {
	constructor (table_model) {
		this.table_model = table_model;
		this.create_dom_element();
	}

	create_dom_element () {
		let row = document.createElement("tr");
		row.style.backgroundColor = "#b4b4c4";
		this.table_model.forEach(item => {
			let header = item.header;
			let col = utils.tag_text("th", header);
			row.append(col);
		});
		this.dom_element = row;
	}

	get_dom_element () {
		return this.dom_element;
	}
}

export default Header_row;

