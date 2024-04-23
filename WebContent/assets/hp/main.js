const version_tag = "4.1.1";

const canvas = document.getElementById("viewContent");
const viewBackGround = document.getElementById("viewBackground");

function asset_url(asset) {
    let currentPath = window.location.pathname;
    currentPath = currentPath.split('?')[0];
    let pathSegments = currentPath.split('/');
    let rootPath = '/' + pathSegments[1];
    let url = window.location.origin + rootPath + "/assets/" + asset;
    return url;
}

var sources;
var loaded;
var generated;
var current_view;

function get_current_view() {
	let view = {};
	get_id: {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let id = urlParams.get('viewId');
		view.id = id || 0;
	}
	console.log(view);
	get_xid: {
		for(let xid in loaded.links) {
			if(loaded.links[xid] == view.id) {
				view.xid = xid;
			}
		}
	}
	split: {
		let split = view.xid.split("-");
		view.level = split[0];
		view.name = split[1];
	}
	from_tree: {
		switch(view.level) {
			case 'l1':
				process = loaded.tree.root.menus[view.name];
				view.process = process;
				view.label = process.label;
				view.title = process.label;
				break;
			case 'l2':
				process = loaded.tree.root.children[view.name];
				view.process = process;
				view.label = process.label;
				view.title = process.label;
				break;
			case 'l3':
				let l2_list = loaded.tree.root.children;
				for(let l2 in l2_list) {
					let process = l2_list[l2];
					let children = process.children;
					if(view.name in children) {
						view.process = process;
						let reference = children[view.name];
						view.label = reference.label;
						view.title = process.label + "/" + view.label; 
						console.log({ l2, process });
						break from_tree;
					}
				}
				console.error('L3 name not found', view.name);
				break;
			default:
				console.error('Level may be l1, l2 or l3, but its', view.level);
		}
	}
	return view;
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

async function main() {
	console.log(`Starting High Performance SCADA Library - version ${version_tag}`);

	load: {
		const localhost_path = "http://localhost:8080";
		let preferred_path = localhost_path;

		sources = {
			localhost: localhost_path,
			preferred: preferred_path,
			l1: `${preferred_path}/Scada-LTS/assets/hp/header_L1.svg`,
			tree: `${preferred_path}/Scada-LTS/assets/hp/views_tree.js`,
			links: `${preferred_path}/Scada-LTS/assets/hp/views_link.js`
		};
		console.log(sources);

		[l1_svg, tree, links] = await Promise.all([ 
			load_svg(sources.l1),
			load_json(sources.tree),
			load_json(sources.links)
		]);
		loaded = { l1_svg, tree, links };
	}

	generate: {
		let hp_headers = (() => {
			div = document.createElement("div");
			div.style.position = "absolute";
			div.id = "hp-headers";
			div.style.display = "grid";
			return div;
		})();
		current_view = get_current_view();
		console.log({ current_view });
		let l1 = (() => {
			let div = loaded.l1_svg;
			static_strings: {
				div.querySelector("#process-title").innerHTML = current_view.title;
				div.querySelector("#operator-name").innerHTML = "João Carlos";
			}
			bind_buttons: {
				function bind_button(id, action) {
					div.querySelector(`#${id}`).onclick = action;
				}
				bind_button("l1-map", () => {
					goto_id(loaded.links["l1-cidades"]);
				});
				bind_button("l1-system", () => {
					goto_id(loaded.links["l1-estatisticas"]);
				});
				bind_button("l1-refresh", () => {
					location.reload();
				});
				bind_button("l1-mute", () => {
					alert("Sound muted!");
				});
				bind_button("l1-lock", () => {
					alert("Logged out!");
				});
			}
			return div;
		})();
		let l2 = create_inline_menu(loaded.tree.root.children, "l2");
		let l3 = current_view.level == "l2" || current_view.level == "l3" ? create_inline_menu(current_view.process.children, "l3") : document.createElement("div");

		l1.id = "header-l1";
		l2.id = "header-l2";
		l3.id = "header-l3";

		generated = { hp_headers, l1, l2, l3, current_view };
	}

	render: {
		canvas.insertBefore(generated.hp_headers, viewBackground);
		let headers = document.getElementById("hp-headers");
		headers.appendChild(generated.l1);
		if(current_view.level == "l2" || current_view.name == "cidades") {
			headers.appendChild(generated.l2);
			headers.appendChild(generated.l3);
		}
		background: {
			let extension = "png";
			let src = `${sources.localhost}/Scada-LTS/assets/hp_bg/${generated.current_view.xid}.${extension}`;
			if(await test_url(src)) {
				change_background(src);
			} else {
				console.warn("Background file not found");
			}
		}
	}

	loop: {
		setInterval(() => {
			clock_update: {
				change_text("date", get_date());
				change_text("time", get_time());
			}
		}, 200);
	}
}

async function load_svg(url) {
	file = await fetch(url);
	text = await file.text();
	let div = document.createElement("div");
	div.style.position = "relative";
	div.innerHTML = text;
	return div;
}

async function load_json(url) {
	file = await fetch(url);
	json = await file.json();
	return json;
}

function goto_id(id) {
	let link = `?viewId=${id}`;
	window.location.href = link;
}

function create_inline_menu(table, level) {
	let menu = document.createElement("div");
	menu.style.display = "inline-flex";
	menu.style.width = "1280px";
	menu.style.flexWrap = "wrap";
	for(item in table) {
		let button = document.createElement("button");
		button.textContent = table[item].label;
		let xid = `${level}-${item}`;
		let view_id = loaded.links[xid];
		button.onclick = () => {
			goto_id(view_id);
		};
		button.id = `${level}-button-${item}`;
		button.style.width = "90px";
		button.style.height = "45px";
		menu.append(button);
	}
	return menu;
}

//	Header labels
function change_text(id, value) {
	document.getElementById(id).innerHTML = value;
}

function get_date() {
	let date = new Date();
	let day = date.getDate();
	let month = date.toLocaleString('pt-br', { month: 'long' });
	let year = date.getFullYear();
	return `${day} de ${month} de ${year}`;
}

function get_time() {
	function two_digit(num) {
		num = `${num}`;
		while (num.length < 2) {
			num = "0" + num;
			if (num.length > 2) {
				throw new Error(`Error while parsing number in two_digit function: ${num}`);
			}
		}
		return num;
	}
	let date = new Date();
	let hours = two_digit(date.getHours());
	let minutes = two_digit(date.getMinutes());
	let seconds = two_digit(date.getSeconds());
	return `${hours}:${minutes}:${seconds}`;
}

function change_background(src) {
	let img_tag = document.getElementById('viewBackground');
	img_tag.src = src;
	img_tag.width = "1280";
	img_tag.height = "720";
	return
}

boot: {
	if(document.currentScript.hasAttribute("boot")) {
		main();
	}
}


