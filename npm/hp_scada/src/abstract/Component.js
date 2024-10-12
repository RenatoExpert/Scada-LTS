class Component {
	constructor (map, nodeTag = "HTMLUnknownElement", children = []) {
		this.map = map;
		this.nodeTag = nodeTag;
		this.children = children;
	}

	makeNode () {
		this.node = document.createElement(this.nodeTag);
		children.forEach(child => {
			this.node.appendChild(child);
		});
	}

	getNode () {
		return this.node;
	}
}

export default Component;

