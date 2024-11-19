class ASSETSAPI {
	static fetch_svg (path) {
		let div = document.createElement("div");
		div.style.position = "relative";
		let asset_path = new URL(path, this.#assets_dir_url);
		return new Promise((resolve, reject) => {
			fetch(asset_path).then(file => {
				file.text().then(text => {
					div.innerHTML = text;
					resolve(div);
				});
			});
		});
	}

	static fetch_asset (path) {
		return fetch(this.#asset_url(path));
	}

	static #asset_url (path) {
		return new URL(path, this.#assets_dir_url);
	}

	static #catch_sublocation () {
		let currentPath = window.location.pathname;
		currentPath = currentPath.split('?')[0];
		let pathSegments = currentPath.split('/');
		let rootPath = '/' + pathSegments[1] + "/";
		return rootPath;
	}

	static #sublocation = this.#catch_sublocation();
	static #root_path = new URL(this.#sublocation, window.location.origin);
	static #assets_dir_url = new URL("assets/", this.#root_path);
}

export default ASSETSAPI;

