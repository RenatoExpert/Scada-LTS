import Component from '../Component.js';
import PageInfo from './PageInfo.js';

class SummaryPage extends Component {
	constructor (entries, map) {
		let nodeTag = "nav";
		let className = "hp-summarypage";
		super(map, nodeTag, className);
		console.log({ SummaryPage: this });
		this.entries = entries;
		this.max_per_page = 20;
		this.#defineCount();
		this.#defineIndex();
		this.#defineLast();
		this.#defineRange();
		this.#makeChildren(entries);
	}

	#defineCount () {
		this.count = this.entries.length;
	}

	#defineIndex () {
		this.index = this.map.params.page;
	}

	#defineLast () {
		let avg = this.count / this.max_per_page;
		let floor = Math.floor(avg) + 1;
		this.last = floor;
	}

	#makeChildren () {
		let info = new PageInfo(`Página ${this.index} de ${this.last}`);
		this.node.appendChild(info.node);
		if (this.index > 1) {
			let previousButton = new PagePrevious(this.index);
			this.node.appendChild(previousButton.node);
		}
		if (this.index < this.last) {
			let nextButton = new PageNext(this.index);
			this.node.appendChild(nextButton.node);
		}
	}

	#defineRange () {
		if (this.index < this.last) {
			let next = document.createElement("a");
			next.innerText = "avançar";
			next.style.display = this.index < this.last ? 'inline' : 'none';
			next.href = this.map.gen_page_url(this.index + 1);
			this.node.append(next);
		}
                Array.prototype.slice.call(this.node.children).forEach(child => {
                        child.style.paddingLeft = "20px";
                });
	}
}

export default SummaryPage;

