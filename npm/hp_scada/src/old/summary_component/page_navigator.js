class Page_navigator {
	constructor (map, items_per_page) {
		this.map = map;
		this.create_dom_element(items_per_page);
	}

	create_dom_element (items_per_page) {
		let tree_table = this.map.current_view.process.children;
		const current_page = this.map.current_page;
		const last_page = Math.floor(Object.keys(tree_table).length / items_per_page) + 1;
		let nav = document.createElement("nav");
		let page_display = document.createElement("spam");
		page_display.innerText = `Página ${current_page} de ${last_page}`;
		nav.append(page_display);
		let previous = document.createElement("a");
		previous.innerText = "retroceder";
		previous.style.display = current_page > 1 ? 'inline' : 'none';
		previous.href = this.map.gen_page_url(current_page - 1);
		nav.append(previous);
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

	get_dom_element () {
		return this.dom_element;
	}
}

export default Page_navigator;

