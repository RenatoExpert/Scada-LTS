class Observer {
	constructor(nodeId) {
		this.nodeId = nodeId;
	}

	when_exist (callback) {
		let observer = new MutationObserver((mutationList, observer) => {
			for (let mutation of mutationList) {
				let node = document.getElementById(this.nodeId);
				if (node) {
					observer.disconnect();
					callback(node);
				}
			}
		});
		//	Replace document.body by "viewContent" for better performance
		observer.observe(document.body, { childList: true });
	}
}

export default Observer;

