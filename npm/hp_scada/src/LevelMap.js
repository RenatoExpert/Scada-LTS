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
		let level_names = view_address.split(':');
		for (let i = 1; i <= level_names.length; i++) {
			let name = level_names[i - 1];
			let path = this.#make_path_from_levelmap(name);
			let view = get_view_by_path(path);
			this.last = this[i] = {
				...view,
				name,
				path
			};
			this.max = i;
		}
		this.last = this[this.max];
	}

	#make_path_from_levelmap (target) {
		let path = [];
		let current_level;
		for (let i = 1; i <= this.max; i++) {
			current_level = this.levelmap[i];
			path.push(current_level.name);
		}
		return path;
	}
}

export default LevelMap;

