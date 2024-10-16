class Component {
	constructor (map, nodeTag = "HTMLUnknownElement", className) {
		this.map = map;
		this.nodeTag = nodeTag;
		this.className = className;
		this.makeNode();
	}

	makeNode () {
		this.node = document.createElement(this.nodeTag);
		this.node.className = this.className;
	}

	getNode () {
		return this.node;
	}
}

export default Component;

