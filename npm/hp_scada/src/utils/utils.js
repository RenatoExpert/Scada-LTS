//	==============================================================================================
//	URL utils

function tag_text(tag, text) {
	let element = document.createElement(tag);
	element.innerHTML = text;
	return element;
}

function format_var(value, eu) {
	return `<b>${value.toFixed(2)}</b><small>${eu}</small>`;
}

function get_sublocation() {
	let currentPath = window.location.pathname;
	currentPath = currentPath.split('?')[0];
	let pathSegments = currentPath.split('/');
	let rootPath = '/' + pathSegments[1] + "/";
	return rootPath;
}

function get_root_path() {
	return new URL(get_sublocation(), window.location.origin);
}

function assets_dir_url() {
	return new URL("assets/", get_root_path());
}

function asset_url(asset) {
	return new URL(asset, assets_dir_url());
}

function test_url(url) {
	return new Promise((resolve, reject) => {
		fetch(url).then(response => {
			console.log(response);
			if(response.status == 200) {
				resolve(true);
			} else {
				resolve(false);
			}
		}).catch(e => {
			resolve(false);
		});
	});
}

async function load_svg(url) {
	let file = await fetch(url);
	let text = await file.text();
	let div = document.createElement("div");
	div.style.position = "relative";
	div.innerHTML = text;
	return div;
}

async function load_json(url) {
	let file = await fetch(url);
	let json = await file.json();
	return json;
}

function goto_id(id, reference) {
	reference = reference || new URLSearchParams(window.location.search).get("xid");
	let link = `?xid=${id}&reference=${reference}`;
	window.location.href = link;
}

const utils = {
	tag_text,
	format_var,
	get_sublocation,
	get_root_path,
	assets_dir_url,
	asset_url,
	test_url,
	load_svg,
	load_json,
	goto_id
};

module.exports = utils;

