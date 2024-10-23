import Component from '../Component.js';

class TableRow extends Component {
	constructor (model, name, label) {
		let nodeTag = "tr";
		let className = "hp-tablerow";
		super(null, nodeTag, className);
		this.model = model;
		this.name = name;
		this.label = label;
		console.log({ TableRow: this });
		this.#makeChildren();
	}

	#makeChildren () {
		this.model.forEach(column => {
			let td = document.createElement("td");
			td.innerText = this.label;
			this.node.append(td);
		});
	}
}

export default TableRow;

