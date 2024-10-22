import Component from '../Component.js';

class TableRow extends Component {
	constructor (table_info) {
		let nodeTag = "tr";
		let className = "hp-tablerow";
		super(null, nodeTag, className);
		this.#makeChildren();
	}

	#makeChildren () {
	}
}

export default TableRow;

