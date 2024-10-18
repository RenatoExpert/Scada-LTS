import Component from '../Component.js';



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
                let next = document.createElement("a");
                next.innerText = "avançar";
                next.style.display = current_page < last_page ? 'inline' : 'none';
                next.href = this.map.gen_page_url(current_page + 1);
                nav.append(next);
                Array.prototype.slice.call(nav.children).forEach(child => {
                        child.style.paddingLeft = "20px";
                });
                this.dom_element = nav;
	}
}

export default SummaryPage;

        create_dom_element (items_per_page) {
        }

