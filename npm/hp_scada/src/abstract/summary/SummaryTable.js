import Component from '../Component.js';

class SummaryTable extends Component {
	constructor (map, currentPage, max_per_page) {
		let nodeTag = "table";
		let className = "hp-summarytable";
		super(map, nodeTag, className);
		this.index = currentPage;
		this.table_size = max_per_page;
	}

	#makeChildren () {
	}
}

export default SummaryTable;

