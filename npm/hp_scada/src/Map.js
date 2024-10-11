
class Map {
	constructor (tree) {
		this.full_tree = tree;
		this.update_current_view();
		this.update_reference_info();
		this.update_current_page();
	}

	update_current_page () {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let page = parseInt(urlParams.get('page')) || 1;
		this.current_page = page;
	}

	update_current_view () {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let xid = urlParams.get('xid') || "l0-banner";
		let view = get_view_info(xid);
		this.current_view = view;
	}

	get_reference_info () {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let xid = urlParams.get('reference') || "l0-banner";
		let view = get_view_info(xid);
		return view;
	}

	gen_page_url (page) {
		let url = new URL(window.location.href);
		url.searchParams.set("page", page);
		return url;
	}

	get_current_page () {
		return this.current_page;
	}

	get_current_view () {
		return this.current_view;
	}
}

//	==============================================================================================
//	Library Utils

function get_current_page() {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let page = parseInt(urlParams.get('page')) || 1;
	return page;
}

function get_current_view() {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let xid = urlParams.get('xid') || "l0-banner";
	let view = get_view_info(xid);
	return view;
}

function get_reference_info() {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let xid = urlParams.get('reference') || "l0-banner";
	let view = get_view_info(xid);
	return view;
}

function get_view_info(xid) {
	let view = {};
	view.xid = xid;
	split: {
		let split = view.xid.split("-");
		view.level = split[0];
		view.name = split[1];
	}
	let process;
	console.log({ view, xid });
	from_tree: {
		switch(view.level) {
			case 'l0':
				console.warn("No XID detected. Lets consider L0");
				break;
			case 'l1':
				process = loaded.tree.root.menus[view.name];
				console.log({ menus: loaded.tree.root.menus, process });
				view.process = process;
				view.label = process.label;
				view.title = process.label;
				view.custom_bg = process.custom_bg;
				break;
			case 'l2':
				process = loaded.tree.root.erpm[view.name];
				view.process = process;
				view.label = process.label;
				view.title = process.label;
				break;
			case 'l3':
				process = find_parent(view.name);
				view.process = process;
				let reference = process.children[view.name];
				view.label = reference.label;
				view.title = process.label + "/" + view.label; 
				view.class = reference.class;
				view.custom_bg = reference.custom_bg;
				view.code = reference.code;
				console.log({ process });
				break;
			default:
				console.error('Level may be l1, l2 or l3, but its', view.level);
		}
	}
	console.log({view});
	return view;
}

export default Map;

