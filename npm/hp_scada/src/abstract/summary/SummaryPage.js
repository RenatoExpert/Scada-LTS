import NAVAPI from '../../lib/NAVAPI.js';
import Component from '../Component.js';
import PageInfo from './PageInfo.js';

class PageButton {
	constructor (targetPage, text) {
		this.node = document.createElement("a");
		this.node.innerText = text;
		this.node.style.display = 'inline';
		this.node.href = NAVAPI.page_url(targetPage);
		this.node.style.paddingLeft = "20px";
	}
}

class PagePrevious extends PageButton {
	constructor (index) {
		let targetPage = index - 1;
		super(targetPage, "anterior");
	}
}

class PageNext extends PageButton {
	constructor (index) {
		let targetPage = index + 1;
		super(targetPage, "próximo");
	}
}

class SummaryPage extends Component {
	constructor (entries, map) {
		let nodeTag = "nav";
		let className = "hp-summarypage";
		super(map, nodeTag, className);
		this.entries = entries;
		this.max_per_page = 20;
		this.#defineCount();
		this.#defineIndex();
		this.#defineLast();
		this.#makeChildren();
		console.log({ SummaryPage: this });
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
}

export default SummaryPage;

