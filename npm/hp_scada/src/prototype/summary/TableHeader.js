import Component from '../Component.js';

class TableHeader extends Component {
	constructor (model) {
		let map = null;
		let nodeTag = "tr";
		let className = 'hp-tableheader';
		super(map, nodeTag, className);
		this.model = model;
		this.#makeChildren();
	}

	#makeChildren () {
		this.model.forEach(column => {
			let th = document.createElement('th');
			th.innerText = column.header;
			this.node.append(th);
		});
	}
}

export default TableHeader;

