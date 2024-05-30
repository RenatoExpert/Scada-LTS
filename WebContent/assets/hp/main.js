const version_tag = "4.1.1";

const canvas = document.getElementById("viewContent");
const viewBackGround = document.getElementById("viewBackground");


//	==============================================================================================
//	URL utils

function tag_text(tag, text) {
	let element = document.createElement(tag);
	element.innerHTML = text;
	return element;
}

function format_var(value, eu) {
	return `<b>${value}</b><small>${eu}</small>`;
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

function goto_id(id, reference = generated.current_view.xid) {
	let link = `?xid=${id}&reference=${reference}`;
	window.location.href = link;
}


//	==============================================================================================
//	SCADA API

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

function load_relatory(xid, start, end) {
	let base_url = new URL("api/point_value/getValuesFromTimePeriod/xid/", get_root_path());
	let target_url = new URL(`${xid}/${start}/${end}`, base_url);
	return new Promise((resolve, reject) => {
		load_json(target_url).then(json => {
			console.debug({ json });
			resolve(json);
		}).catch(problem => {
			console.error(problem);
			console.error({ target_url });
			reject("Datapoint API returned error!");
		});
	});
}

//	==============================================================================================
//	HTML Utils

function sum_datetime(/**/) {
	let args = arguments;
	let sum = new Date().getTimezoneOffset() * 60e3;
	for(let i = 0; i < args.length; i++) {
		let element = document.getElementById(args[i]);
		sum += element.valueAsNumber;
	}
	if(Number.isNaN(sum)) {
		throw new Error("Empty value");
	}
	return sum;
}

function relatory (area_code, station_code, start_ts, end_ts, id_col = 'Dia') {
	let tags = get_hist_tags(area_code, station_code);
	let promises = [];
	let indexes = make_relatory_indexes(start_ts, end_ts);
	Object.getOwnPropertyNames(tags).forEach(key => {
		let tag = tags[key];
		let promise = new Promise((resolve, reject) => {
			load_relatory(tag, start_ts, end_ts).then(json => {
				let table = normatize_relatory_column(json, key);
				resolve({ key, table });
			});
		})
		promises.push(promise);
	});
	Promise.all(promises).then(results => {
		let table = {};
		console.log({ indexes });
		indexes.forEach(index => {
			console.log({ index });
			table[index] = {};
			results.forEach(result => {
				console.log({ result });
				let key = result.key;
				table[index][key] = result.table[index];
			});
		});
		console.log(table);
		render_relatory(table, id_col);
	});
}

function normatize_relatory_column(json) {
	let values = json.values;
	let from = json.fromTs;
	let to = json.toTs;
	let hour_in_ms = 60 * 60 * 1e3;
	let object = {};
	for(let target = from; target <= to; target += hour_in_ms) {
		let min_time = target;
		let max_time = target + hour_in_ms;
		let filtered_list = values.filter(row => {
			time = row.ts;
			return min_time <= time && time <= max_time;
		});
		let sum = 0;
		filtered_list.forEach(row => {
			let value_str = row.value;
			if (Number.isNaN(value_str)) {
				throw new Error(`Invalid value ${value_str} on ${row}`);
			} else {
				value = Number.parseFloat(value_str);
				sum += value;
			}
		});
		let length = filtered_list.length
		let avg = sum / length;
		let date_index = new Date(target).toLocaleDateString();
		let hour_index = new Date(target).toLocaleTimeString();
		let full_index = `${date_index} ${hour_index}`;
		object[full_index] = avg;
	}
	console.table(object);
	return object;
}

function render_relatory(obj, id_col) {
	let child_dom = generate_relatory_dom(obj, id_col);
	let parent_dom = document.getElementById('relatory-table');
	parent_dom.replaceChildren([child_dom]);
}

function generate_relatory_dom(obj, id_col, linear = true) {
	let relatory = document.createElement("div");
	let table = document.createElement("table");
	header: {
		raw_volume_eu = linear ? "m³" : "kPa";
		std_volume_eu = "m³";
		avg_pressure_eu = "kgf/cm²";
		avg_temperature_eu = "ºC";
		let row = document.createElement("tr");
		let headers = [id_col, "Volume não-corrigido", "Volume corrigido", "Pressão Média", "Temperatura Média"];
		for(header in headers) {
			let col = tag_text("th", headers[header]);
			row.append(col);
		}
		table.append(row);
	}
	body: {
		Object.getOwnPropertyNames(table).forEach(time => {
			let frame = obj[time];
			let row = document.createElement("tr");
			let { raw_volume, std_volume, avg_pressure, avg_temperature } = frame;
			let cols = [
				time,
				format_var(raw_volume, raw_volume_eu),
				format_var(std_volume, std_volume_eu),
				format_var(avg_pressure, avg_pressure_eu),
				format_var(avg_temperature, avg_temperature_eu)
			];
			for(i in cols) {
				let col = tag_text("td", cols[i]);
				row.append(col);
			}
			table.append(row);
		});
	}
	return table;
}

function make_relatory_indexes(from, to) {
	let hour_in_ms = 60 * 60 * 1e3;
	let step = hour_in_ms;
	let indexes = [];
	let min = from;
	let max = min + step;
	while(max < to) {
		indexes.push(min);
		min = max;
		max += step;
	}
	return indexes;
}

function get_hist_tags(area_code, station_code) {
	let sample = {
		raw_volume: "ERPM001-FQ064-FQIA-1",
		std_volume: "ERPM001-FQ064-FQI-1",
		avg_pressure: "ERPM001-FQ064-PI-1",
		avg_temperature: "ERPM001-FQ064-TI-1"
	};
	return sample;
}

function validate_filter(e) {
	let start_ts, end_ts;
	let isValid;
	try {
		start_ts = sum_datetime("start-date", "start-time");
		end_ts = sum_datetime("end-date", "end-time");
		let xid = "ERPM001-FQ028-PI-1";
		relatory('001', '064', start_ts, end_ts);
		isValid = true;
	} catch(e) {
		isValid = false;
	} finally {
		console.log({ start_ts, end_ts });
		return isValid;
	}
}

function clear_minutes(e) {
	let input = e.srcElement;
	console.log(input);
	console.log(input.value);
	let previous = input.value;
	let clean = previous.replace(/:../, ":00");
	input.value = clean;
}

function change_text(id, value) {
	document.getElementById(id).innerHTML = value;
}

function change_background(src) {
	let img_tag = document.getElementById('viewBackground');
	img_tag.src = src;
	img_tag.width = "1280";
	img_tag.height = "720";
	return
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


//	==============================================================================================
//	SVG utils

function set_visibility(element, value) {
	element.style.display = value;
}

function set_visible(selector, root = document) {
	set_visibility(root.querySelector(selector), '');
}

function get_loop_tag() {
	let area_tag;
	step_a: {
		let station_type = "ERPM";
		let area_number = generated.current_view.process.code;
		area_tag = `${station_type}${area_number}`;
	}
	let eqp_id;
	step_b: {
		let first_letters = "FQ";
		let equipment_suffix = generated.current_view.code;
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


//	==============================================================================================
//	Misc

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


//	==============================================================================================
//	Static Data

let status_report = {};
template_fields = {
	'rpm-single': [
		'update-pi-1',
		'update-pi-2',
		'update-ti-1',
		'update-pdi-1',
		'update-fi-1',
		'update-fqi-1',
		'update-fqia-1',
		'update-ei-1'
	],
	'rpm-double': [
		'update-pi-1',
		'update-pi-2',
		'update-ti-1',
		'update-pdi-1',
		'update-fi-1',
		'update-fqi-1',
		'update-fqia-1',
		'update-ei-1'
	]
};


//	==============================================================================================
//	Library Utils

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
				view.code = reference.code;
				console.log({ process });
				break;
			default:
				console.error('Level may be l1, l2 or l3, but its', view.level);
		}
	}
	console.log({view});
	return view;
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

function create_relatory_view() {
	let root = document.createElement("div");
	generate_filter: {
		let filter = document.createElement("div");
		let form = document.createElement("form");
		form.addEventListener("submit", validate_filter);
		form.action = "javascript:;";
		start: {
			let date = document.createElement("input");
			date.id = "start-date";
			date.type = "date";
			date.valueAsNumber = new Date() - (1e3 * 60 * 60 * 24);
			date.required = true;
			form.append(date);
			let time = document.createElement("input");
			time.addEventListener("change", clear_minutes);
			time.id = "start-time";
			time.type = "time";
			time.valueAsNumber = 0;
			time.required = true;
			form.append(time);
		}
		end: {
			let date = document.createElement("input");
			date.id = "end-date";
			date.type = "date";
			date.valueAsDate = new Date();
			date.required = true;
			form.append(date);
			let time = document.createElement("input");
			time.addEventListener("change", clear_minutes);
			time.id = "end-time";
			time.type = "time";
			time.valueAsNumber = 0;
			time.required = true;
			form.append(time);
		}
		submit: {
			let button = document.createElement("input");
			button.type = "submit";
			button.value = "Gerar";
			form.append(button);
		}
		filter.append(form);
		root.append(filter);
	}
	let relatory_table = document.createElement("div");
	relatory_table.id = "relatory-table";
	root.append(relatory_table);
	return root;
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


//	==============================================================================================
//	Runtime

var sources;
var loaded;
var generated;
var current_view;

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
					if(current_view.level == 'l3') {
						['#l1-daily', '#l1-hourly'].forEach(selector => {
							set_visible(selector, div);
						});
					}
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
					bind_button("l1-daily", "Relatório Diário", () => {
						goto_id("l1-daily");
					});
					bind_button("l1-hourly", "Relatório Horário", () => {
						goto_id("l1-hourly");
					});
				}
				return div;
			})();
			let l2 = create_inline_menu(loaded.tree.root.children, "l2");
			let l3 = current_view.level == "l2" || current_view.level == "l3" ? create_inline_menu(current_view.process.children, "l3") : document.createElement("div");
			let summary = current_view.level == "l2" ? create_status_table(current_view.process.children) : document.createElement("div");
			let relatory =	current_view.xid == "l1-hourly" ? create_relatory_view(current_view.xid) :
					current_view.xid == "l1-daily" ? create_relatory_view(current_view.xid) :
					null;

			l1.id = "header-l1";
			l2.id = "header-l2";
			l3.id = "header-l3";
			summary.id = "summary";

			generated = { hp_headers, l1, l2, l3, summary, current_view, relatory };
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
			headers.style.zIndex = 1;
			headers.appendChild(generated.l1);
			if(current_view.level == "l2" || current_view.name == "cidades") {
				headers.appendChild(generated.l2);
				headers.appendChild(generated.l3);
				headers.appendChild(generated.summary);
			} else if(["l1-hourly", "l1-daily"].includes(current_view.xid)) {
				headers.appendChild(generated.relatory);
			}
		}
		background: {
			let cv = generated.current_view;
			let background_url = asset_url("hp_bg/");
			let prefix = cv.class;
			let extension;
			if(prefix) {
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
				let filename = `${prefix}.${extension}`;
				let target_url = new URL(filename, background_url);
				test_url(target_url).then(sucess => {
					change_background(target_url);
				}).catch(problem => {
					console.warn("Background file not found");
				});
			}
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
					console.log("Test");
					let station_class = current_view.class;
					if(station_class) {
						console.log({ current_view, template_fields, station_class });
						template_fields[station_class].forEach(field => {
							let instrument_tag = get_tag(field);
							let success;
							tag_load_num(instrument_tag).then(value => {
								update_display(field, value);
								success = "\u2714";
							}).catch(problem => {
								//console.error(`Error on field ${field}, expected tag ${instrument_tag}`);
								success = "\u274c";
							}).finally(fin => {
								status_report[field] = { instrument_tag, success };
							});
						});
						console.table(status_report);
					}
				}
			}, duration);
		}
	}
}


//	==============================================================================================
//	Boot

boot: {
	if(document.currentScript.hasAttribute("boot")) {
		main();
	}
}

