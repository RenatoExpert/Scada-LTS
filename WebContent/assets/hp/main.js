const version_tag = "4.1.1";

const canvas = document.getElementById("viewContent");
const viewBackGround = document.getElementById("viewBackground");

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

function tag_load_num(xid) {
	return new Promise((resolve, reject) => {
	tag_load_value(xid).then(string => {
			resolve(Number(string));
		}).catch(problem => {
			reject(problem);
		});
	});
}

function tag_load_value(xid) {
	let base_url = new URL("api/point_value/getValue/", get_root_path());
	let target_url = new URL(xid, base_url);
	return new Promise((resolve, reject) => {
		load_json(target_url).then(json => {
			if("value" in json) {
				let value = json["value"];
				console.debug({ xid, value });
				resolve(value);
			} else {
				reject("Bad return on Datapoint API! No value Field found");
			}
		}).catch(problem => {
			console.error(problem);
			reject("Datapoint API returned error!");
		});
	});
}

var sources;
var loaded;
var generated;
var current_view;

function find_parent(view_name) {
	let l2_list = loaded.tree.root.children;
	let process = {};
	for(let l2 in l2_list) {
		let process = l2_list[l2];
		let children = process.children;
		if(view_name in children) {
			return process;
		}
	}
	console.error('L3 name not found', view_name);
}

function get_current_view() {
	let view = {};
	get_xid: {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let xid = urlParams.get('xid') || "l0-banner";
		view.xid = xid;
	}
	split: {
		let split = view.xid.split("-");
		view.level = split[0];
		view.name = split[1];
	}
	from_tree: {
		switch(view.level) {
			case 'l0':
				console.warn("No XID detected. Lets consider L0");
				break;
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
				process = find_parent(view.name);
				view.process = process;
				let reference = process.children[view.name];
				view.label = reference.label;
				view.title = process.label + "/" + view.label; 
				view.class = reference.class;
				console.log({ process });
				break;
			default:
				console.error('Level may be l1, l2 or l3, but its', view.level);
		}
	}
	console.log({view});
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
			l1: asset_url("hp/header_L1.svg"),
			tree: asset_url("hp/views_tree.js")
		};
		console.log(sources);

		[l1_svg, tree] = await Promise.all([ 
			load_svg(sources.l1),
			load_json(sources.tree)
		]);
		loaded = { l1_svg, tree };
	}

	generate: {
		let hp_headers = (() => {
			let div = document.createElement("div");
			div.style.position = "absolute";
			div.id = "hp-headers";
			div.style.display = "grid";
			subtitle_generation: {
				let subtitle = document.createElement("div");
				subtitle.id = "hp-headers-subtitle";
				subtitle.className = "labelDiv";
				subtitle.style.position = "absolute";
				subtitle.style.display = "none";
				subtitle.style.left = "200px";
				subtitle.style.top = "200px";
				div.appendChild(subtitle);
			}
			return div;
		})();
		current_view = get_current_view();
		if(current_view.level == 'l0') {
			generated = { current_view };
			// show banner
		} else {
			console.log({ current_view });
			let l1 = (() => {
				let div = loaded.l1_svg;
				static_strings: {
					div.querySelector("#process-title").innerHTML = current_view.title;
					div.querySelector("#operator-name").innerHTML = "Luiz Fernando";
				}
				bind_buttons: {
					function bind_button(id, tooltip, action) {
						let btn = div.querySelector(`#${id}`);
						btn.onclick = action;
						btn.onmouseover = () => {
							subtitle(tooltip, btn);
						};
						btn.onmouseout = () => {
							subtitle();
						};
					}
					function subtitle(desc, source) {
						var c = document.getElementById("hp-headers-subtitle");
						if (desc) {
							//var bounds = getAbsoluteNodeBounds(source);
							let bounds = source.getBoundingClientRect();
							console.log(bounds);
							c.innerHTML = desc;
							c.style.left = (bounds.x + 16) +"px";
							c.style.top = (bounds.y - 150) +"px";
							show(c);
						} else {
							hide(c);
						}
					}
					bind_button("l1-map", "Mapa das estacoes", () => {
						goto_id("l1-cidades");
					});
					bind_button("l1-system", "Status do sistema",() => {
						goto_id("l1-estatisticas");
					});
					bind_button("l1-refresh", "Atualizar tela", () => {
						location.reload();
					});
					bind_button("l1-mute", "Silenciar alarmes", () => {
						alert("Sound muted!");
					});
					bind_button("l1-login", "Entrar", () => {
						window.location.href = "login.htm";
					});
					bind_button("l1-lock", "Sair", () => {
						window.location.href = "logout.htm";
					});
				}
				return div;
			})();
			let l2 = create_inline_menu(loaded.tree.root.children, "l2");
			let l3 = current_view.level == "l2" || current_view.level == "l3" ? create_inline_menu(current_view.process.children, "l3") : document.createElement("div");
			let summary = current_view.level == "l2" ? create_status_table(current_view.process.children) : document.createElement("div");

			l1.id = "header-l1";
			l2.id = "header-l2";
			l3.id = "header-l3";
			summary.id = "summary";

			generated = { hp_headers, l1, l2, l3, summary, current_view };
		}
	}

	render: {
		if(current_view.level == "l0") {
			setTimeout(() => {
				goto_id("l1-estatisticas");
			}, 10e3);
		} else {
			canvas.insertBefore(generated.hp_headers, viewBackground);
			let headers = document.getElementById("hp-headers");
			headers.appendChild(generated.l1);
			if(current_view.level == "l2" || current_view.name == "cidades") {
				headers.appendChild(generated.l2);
				headers.appendChild(generated.l3);
				headers.appendChild(generated.summary);
			}
		}
		background: {
			let cv = generated.current_view;
			let background_url = asset_url("hp_bg/");
			let prefix, extension;
			if(cv.class == "erpm-single") {
				prefix = "erpm-single";
				extension = "svg";
				let filename = `${prefix}.${extension}`;
				let target_url = new URL(filename, background_url);
				load_svg(target_url).then(image => {
					replace_background(image);
				}).catch(problem => {
					console.error("Error on loading background SVG file");
					console.error(problem);
				});
			} else {
				prefix = cv.xid;
				extension = "png";
			}
			let filename = `${prefix}.${extension}`;
			let target_url = new URL(filename, background_url);
			test_url(target_url).then(sucess => {
				change_background(target_url);
			}).catch(problem => {
				console.warn("Background file not found");
			});
		}
	}

	loop: {
		if (current_view.level != "l0") {
			let duration = 10e3;
			setInterval(() => {
				clock_update: {
					change_text("date", get_date());
					change_text("time", get_time());
				}
				template: {
					template_fields.forEach(field => {
						let instrument_tag = get_tag(field);
						tag_load_num(instrument_tag).then(value => {
							update_display(field, value);
						}).catch(problem => {
							console.error(`Error on field ${field}, expected tag ${instrument_tag}`);
						});
					});
				}
			}, duration);
		}
	}
}

template_fields = [
	'update-pi-1',
	'update-pi-2',
	'update-ti-1',
	'update-pdi-1',
	'update-fi-1',
	'update-fqi-1',
	'update-fqia-1',
	'update-ei-1'
]

function get_loop_tag() {
	let area_tag;
	step_a: {
		let station_type = "ERPM";
		let area_number = "003";
		area_tag = `${station_type}${area_number}`;
	}
	let eqp_id;
	step_b: {
		let first_letters = "FQ";
		let equipment_suffix = "064";
		eqp_id = `${first_letters}${equipment_suffix}`;
	}
	let loop_tag = `${area_tag}-${eqp_id}`;
	return loop_tag;
}

function get_tag(svg_id) {
	let [algorithm, instrument_function, instrument_number] = svg_id.toUpperCase().split("-");
	let loop_tag = get_loop_tag();
	let tag = `${loop_tag}-${instrument_function}-${instrument_number}`;
	//	Misses branch code suffix
	return tag;
}

function update_display(field, value) {
	let display;
	get_display: {
		let root = document.getElementById(field);
		let whatToShow = NodeFilter.SHOW_ELEMENT;
		let filter = node => {
			let name = node.nodeName.toLowerCase();
			let label = node.getAttribute("inkscape:label");
			let name_matches = name == "g";
			let label_matches = label == "numeric value";
			let right_one = name_matches && label_matches;
			if (right_one) {
				console.debug({ name, label, name_matches, label_matches, right_one, node });
				return NodeFilter.FILTER_ACCEPT;
			} else {
				return NodeFilter.FILTER_REJECT;
			}
		};
		let iterator = document.createNodeIterator(root, whatToShow, filter);
		let currentNode;
		while ((currentNode = iterator.nextNode())) {
			query = currentNode.querySelector("tspan");
			if (query) {
				display = query;
				break;
			}
		}
		console.debug({ display });
	}
	display.innerHTML = value.toFixed(2);
}

function replace_element_by_id(id, new_element) {
	let old_element = document.getElementById(id);
	let parent_element = old_element.parentNode;
	parent_element.replaceChild(new_element, old_element);
}

function replace_background(image) {
	bg_id = "viewBackground";
	image.id = bg_id;
	replace_element_by_id(bg_id, image);
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
	let link = `?xid=${id}`;
	window.location.href = link;
}

function create_inline_menu(table, level) {
	let menu = document.createElement("div");
	menu.style.display = "inline-flex";
	menu.style.width = "1280px";
	menu.style.flexWrap = "wrap";
	menu.style.padding = "0px 5px";
	for(item in table) {
		let button = document.createElement("button");
		button.textContent = table[item].label;
		let xid = `${level}-${item}`;
		button.onclick = () => {
			goto_id(xid);
		};
		button.id = `${level}-button-${item}`;
		button.style.width = "90px";
		button.style.height = "45px";
		menu.append(button);
	}
	return menu;
}

function tag_text(tag, text) {
	let element = document.createElement(tag);
	element.innerHTML = text;
	return element;
}

function format_var(value, eu) {
	return `<b>${value}</b><small>${eu}</small>`;
}

function create_status_table(tree_table) {
	let div = document.createElement("div");
	let table = document.createElement("table");
	let css = document.createElement("style");
	css.innerHTML = `
		tr:nth-child(even) {
			background-color: #ddddff;
		}
		tr:hover {
			background-color: #aaaadd;
		}
		td, th {
			padding: 2px 7px;
		}
	`;
	table.appendChild(css);
	table.className = "summary";
	table.style.backgroundColor = "#f1f1f1";
	header: {
		let row = document.createElement("tr");
		row.style.backgroundColor = "#b4b4c4";
		let headers = ["Estacao", "Modem", "Comunicacao", "Atualizacao", "Entrada", "Saida", "Temperatura", "Vazao", "Mes", "Anterior"];
		for(header in headers) {
			let col = tag_text("th", headers[header]);
			row.append(col);
		}
		table.append(row);
	}
	for(item in tree_table) {
		let row = document.createElement("tr");
		let cols = [tree_table[item].label, "Conectado", "OK", "14:23",
			format_var(22, "Kgf/cm²"),
			format_var(12, "Kgf/cm²"),
			format_var(28, "°C"),
			format_var(4.792, "m3/dia"),
			format_var(40.634, "m3"),
			format_var(92.179, "m3")
		];
		for(i in cols) {
			let col = tag_text("td", cols[i]);
			row.append(col);
		}
		let xid = `l3-${item}`;
		row.onclick = () => {
			goto_id(xid);
		};
		table.append(row);
	}
	div.append(table);
	return div;
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

