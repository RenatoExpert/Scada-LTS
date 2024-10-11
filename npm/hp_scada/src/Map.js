
class Map {
	constructor (tree) {
		this.current_view = new LevelMap(tree, view_address);
		this.full_tree = tree;
		this.update_current_view();
		this.update_current_page();
	}

	current_view (tree) {
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
		let view = get_view_info(xid, this.full_tree);
		this.current_view = view;
	}

	get_view_info_by_xid (xid) {
		let view = {};

	get_reference_info () {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let xid = urlParams.get('reference') || "l0-banner";
		let view = get_view_info(xid, this.full_tree);
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

get_param(param, default_value) {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let value = urlParams.get(param) || default_value;
	return value;
}

class LevelMap {
	constructor (tree, view_address) {
		let levelmap = {};
		let level_names = xid.split(':');
		for(let i = 1; i <= level_names.length; i++) {
			let name = level_names[i - 1];
			let path = this.#make_path_from_levelmap(levelmap, name);
			let view = get_view_by_path(this.tree, path);
			levelmap[last] = levelmap[i] = {
				...view,
				name,
				path
			};
			levelmap.max = i;
		}
		levelmap.max = i;
		levelmap.last = levelmap[levelmap.max];
		return levelmap;
	}

	static #make_path_from_levelmap (levelmap, target) {
		let path = [];
		while(let i = 1; let current_level = levelmap[i]; i++) {
			path.push(current_level.name);
		}
		return path;
	}
}

/*
function get_current_page() {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let page = parseInt(urlParams.get('page')) || 1;
	return page;
}

function get_current_view() {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let xid = urlParams.get('xid') || "banner";
	let view = get_view_info(xid);
	return view;
}

function get_reference_info() {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let xid = urlParams.get('reference') || "banner";
	let view = get_view_info(xid);
	return view;
}


get_view_by_path (tree, path) {
	let current_view = tree.root;
	path.forEach(name => {
		current_view = current_view.children[name];
	});
	return current_view;
}

get_view_info_by_viewaddress (viewaddress) {
}



*/
export default Map;

