class Component {
	constructor (map, nodeTag = "HTMLUnknownElement") {
		this.map = map;
		this.nodeTag = nodeTag;
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

