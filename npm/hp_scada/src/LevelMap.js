function get_view_by_path (tree, path) {
	let current_view = tree.root;
	path.forEach(name => {
		current_view = current_view.children[name];
	});
	return current_view;
}

class LevelMap {
	constructor (tree, view_address) {
		this.tree = tree;
		let all_names = view_address.split(':');
		let path = [];
		for (let i = 1; i <= all_names.length; i++) {
			let name = all_names[i - 1];
			path.push(name);
			let view = get_view_by_path(tree, path);
			this.last = this[i] = {
				...view,
				name,
				path
			};
			this.max = i;
		}
		this.last = this[this.max];
	}
}

export default LevelMap;

