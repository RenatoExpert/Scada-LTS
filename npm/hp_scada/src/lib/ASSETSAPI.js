class ASSETSAPI {
	static fetch_asset (path) {
		return fetch(this.#asset_url(path));
	}

	static #asset_url (path) {
		return new URL(path, this.#assets_dir_url);
	}

	static #assets_dir_url = new URL("assets/", this.#root_path);
	static #root_path = new URL(this.#sublocation(), window.location.origin);
	static #sublocation = this.#catch_sublocation();

	static #catch_sublocation () {
		let currentPath = window.location.pathname;
		currentPath = currentPath.split('?')[0];
		let pathSegments = currentPath.split('/');
		let rootPath = '/' + pathSegments[1] + "/";
		return rootPath;
	}
}

export default ASSETSAPI;

