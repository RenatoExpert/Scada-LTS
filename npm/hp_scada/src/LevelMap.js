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
		let levelmap = {};
		let level_names = view_address.split(':');
		for (let i = 1; i <= level_names.length; i++) {
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

	#make_path_from_levelmap (levelmap, target) {
		let path = [];
		let current_level;
		for (let i = 1; current_level = levelmap[i]; i++) {
			path.push(current_level.name);
		}
		return path;
	}
}

export default LevelMap;

