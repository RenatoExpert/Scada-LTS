class Component {
	constructor (map, nodeTag = "HTMLUnknownElement") {
		this.map = map;
		this.nodeTag = nodeTag;
		this.children = children;
		this.makeNode();
	}

	makeNode () {
		this.node = document.createElement(this.nodeTag);
	}

	getNode () {
		return this.node;
	}
}

export default Component;

