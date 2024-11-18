class Observer {
	constructor(nodeId) {
		this.nodeId = nodeId;
	}

	do_it () {
		return new Promise((resolve, reject) => {
			let node = document.getElementById(this.nodeId);
			this.what_to_do(node);
		});
	}

	check_if_exist () {
		return new Promise((resolve, reject) => {
			let node = document.getElementById(this.nodeId);
			if (node == null) {
				reject();
			} else {
				this.do_it().then(resolve).catch(reject);
			}
		});
	}

	when_exist (callback) {
		this.what_to_do = callback;
		this.check_if_exist().catch(() => {
			let observer = new MutationObserver((mutationList, observer) => {
				for (let mutation of mutationList) {
					this.check_if_exist().then(() => {
						observer.disconnect();
					}).catch(e => {
						console.error("App object could never be created!");
					});
				}
			});
			//	Replace document.body by "viewContent" for better performance
			observer.observe(document.body, { childList: true });
		});
	}
}

export default Observer;

