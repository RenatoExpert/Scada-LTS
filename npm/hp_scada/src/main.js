import utils from './utils/utils.js';
//	Not in use
//		utils.get_sublocation
//		assets_dir_url

import api from './api/api.js';

import Graphic_component from './graphic_component/graphic_component.js';
import Rectifiers_component from './rectifiers_component/rectifiers_component.js';
import Cathodic_component from './cathodic_component/cathodic_component.js';
//import Summary_component from './summary_component/summary_component.js';
import StationsSummary from './StationsSummary/StationsSummary.js';
import RelatoryView from './RelatoryView.js';


import * as views_tree from 'views_tree.json';

const version_tag = "4.1.1";

const canvas = document.getElementById("viewContent");
const viewBackGround = document.getElementById("viewBackground");


class Map {
	constructor (tree) {
		this.full_tree = tree;
		this.get_current_view();
		this.get_reference_info();
		this.get_current_page();
	}

	get_current_page () {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let page = parseInt(urlParams.get('page')) || 1;
		this.current_page = page;
	}

	get_current_view () {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let xid = urlParams.get('xid') || "l0-banner";
		let view = get_view_info(xid);
		this.current_view = view;
	}

	get_reference_info () {
		let queryString = window.location.search;
		let urlParams = new URLSearchParams(queryString);
		let xid = urlParams.get('reference') || "l0-banner";
		let view = get_view_info(xid);
		return view;
	}

	gen_page_url (page) {
		let url = new URL(window.location.href);
		url.searchParams.set("page", page);
		return url;
	}
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

var relatory_memory = {};

function relatory(area_code, station_code, start_ts, end_ts, id_col = 'Data-hora') {
	let tags = get_hist_tags(area_code, station_code);
	let promises = [];
	let indexes = make_relatory_indexes(start_ts, end_ts);
	Object.getOwnPropertyNames(tags).forEach(key => {
		let tag = tags[key];
		let promise = new Promise((resolve, reject) => {
			api.load_tag_history_compress(tag, start_ts, end_ts).then(json => {
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
		console.log({ table });
		relatory_memory = table;
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
			let time = row.ts;
			return min_time <= time && time <= max_time;
		});
		let sum = 0;
		filtered_list.forEach(row => {
			let value_str = row.value;
			if (Number.isNaN(value_str)) {
				throw new Error(`Invalid value ${value_str} on ${row}`);
			} else {
				let value = Number.parseFloat(value_str);
				sum += value;
			}
		});
		let length = filtered_list.length
		let avg = sum / length;
		let index = get_timedate(target);
		object[index] = avg;
	}
	console.table(object);
	return object;
}

function get_timedate(timestamp) {
	let date = new Date(timestamp).toLocaleDateString();
	let hour = new Date(timestamp).toLocaleTimeString();
	let full = `${date} ${hour}`;
	return full;
}

var generated_relatory = false;

function validate_filter(e) {
	let start_ts, end_ts;
	let isValid;
	console.warn({ e });
	try {
		start_ts = sum_datetime("start-date", "start-time");
		let TWO_HOURS = 2 * 60 * 60 * 1e3;
		end_ts = sum_datetime("end-date", "end-time") + TWO_HOURS;
		let area = document.getElementById('select-area').value;
		let station = document.getElementById('select-station').value;
		if(area && station) {
			relatory(area, station, start_ts, end_ts);
			generated_relatory = true;
			isValid = true;
		} else {
			console.error({ area, station });
			throw new Error("Error on validade_filter");
		}
	} catch(e) {
		isValid = false;
		console.error(e);
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
	let bg_id = "viewBackground";
	image.id = bg_id;
	replace_element_by_id(bg_id, image);
}

function find_parent(view_name) {
	let l2_list = loaded.tree.root.erpm;
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
			let query = currentNode.querySelector("tspan");
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
let template_fields = {
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

function get_current_page() {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let page = parseInt(urlParams.get('page')) || 1;
	return page;
}

function get_current_view() {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let xid = urlParams.get('xid') || "l0-banner";
	let view = get_view_info(xid);
	return view;
}

function get_reference_info() {
	let queryString = window.location.search;
	let urlParams = new URLSearchParams(queryString);
	let xid = urlParams.get('reference') || "l0-banner";
	let view = get_view_info(xid);
	return view;
}

function get_view_info(xid) {
	let view = {};
	view.xid = xid;
	split: {
		let split = view.xid.split("-");
		view.level = split[0];
		view.name = split[1];
	}
	let process;
	console.log({ view, xid });
	from_tree: {
		switch(view.level) {
			case 'l0':
				console.warn("No XID detected. Lets consider L0");
				break;
			case 'l1':
				process = loaded.tree.root.menus[view.name];
				console.log({ menus: loaded.tree.root.menus, process });
				view.process = process;
				view.label = process.label;
				view.title = process.label;
				view.custom_bg = process.custom_bg;
				break;
			case 'l2':
				process = loaded.tree.root.erpm[view.name];
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
				view.custom_bg = reference.custom_bg;
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
	for(let item in table) {
		let button = document.createElement("button");
		button.textContent = table[item].label;
		let xid = `${level}-${item}`;
		button.onclick = () => {
			utils.goto_id(xid);
		};
		button.id = `${level}-button-${item}`;
		button.style.width = "90px";
		button.style.height = "45px";
		menu.append(button);
	}
	return menu;
}

function update_station_options(area, station_select, reference) {
	station_select.replaceChildren();
	Object.values(area.erpm).forEach(child => {
		let option = document.createElement("option");
		option.value = child.code;
		option.innerText = child.label;
		option.selected = child.code == reference.code ? 'selected' : '';
		station_select.append(option);
	});
}

function on_change_timestep(e) {
	let timestep = document.getElementById('select-timestep');
	let start = document.getElementById('start-time');
	let end = document.getElementById('end-time');
	let lock = timestep.value == 'day';
	update_time_lock(start, end, lock);
}

function update_time_lock(start, end, lock) {
	start.disabled = lock;
	end.disabled = lock;
}

function on_change_area(e) {
	let area;
	get_area: {
		let area_selector = document.getElementById('select-area');
		let area_code = area_selector.value;
		area = get_area_by_intcode(area_code, loaded.tree);
	}
	let station_select = document.getElementById('select-station');
	let reference = generated.reference;
	update_station_options(area, station_select, reference);
}

function save_file(data, filename, type) {
	let file = new Blob([data], { type });
	console.log({ file });
	let anchor = document.createElement("a");
	let url = URL.createObjectURL(file);
	anchor.href = url;
	anchor.download = filename;
	document.body.appendChild(anchor);
	anchor.click();
	console.log({ anchor, url, filename, data, file });
	cleaning: {
		document.body.removeChild(anchor);
		window.URL.revokeObjectURL(url);
	}
}

function check_relatory_then_save(data, filename, type) {
	if(generated_relatory) {
		save_file(data, filename, type);
	} else {
		throw new Error("No relatory generated to be saved!");
	}
}

function download_pdf() {
	let iframe = document.getElementById('relatory-iframe');
	iframe.contentWindow.print();
}

function download_csv() {
	console.log("csv");
	let memory = relatory_memory;
	let csv_content = "Data-hora;Pressão média;Temperatura média;Volume não-corrigido;Volume corrigido\n";
	Object.getOwnPropertyNames(relatory_memory).forEach(datetime => {
		let { avg_pressure, avg_temperature, raw_volume, std_volume } = memory[datetime];
		csv_content += `${datetime};${avg_pressure};${avg_temperature};${raw_volume};${std_volume}\n`;
	});
	check_relatory_then_save(csv_content, "relatory.csv", "text/plain");
}

function download_xlsx() {
	console.log("xlsx");
}

//	Here starts relatory section
function make_field_div(dom, id, title, callback) {
	let div = document.createElement("div");
	div.style.cssFloat = "left";
	div.style.margin = "5px";
	div.style.padding = "3px";
	div.style.border = "1px";
	div.style.minWidth = "60px";
	label: {
		let label = document.createElement("label");
		label.innerText = title;
		label.style.display = "block";
		div.append(label);
	}
	input: {
		let input = document.createElement(dom);
		input.id = id;
		input.name = id;
		callback(input);
		div.append(input);
	}
	return div;
}

function get_area_by_intcode(intcode, tree) {
	let area_obj;
	Object.values(tree.root.erpm).forEach(area => {
		if(area.code == intcode) {
			area_obj = area;
		}
	});
	if(area_obj) {
		console.debug(`Are found for code ${intcode}`);
		console.debug({ area_obj, intcode });
		return area_obj;
	} else {
		throw new Error(`Area not found for code ${intcode}`);
	}
}


function make_selector_div(id, title, callback) {
	return make_field_div("select", id, title, callback);
}

//	Here ends relatory section

function page_url(page) {
	let url = new URL(window.location.href);
	url.searchParams.set("page", page);
	return url;
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
			l1: utils.asset_url("hp/header_L1.svg"),
			tree: utils.asset_url("hp/views_tree.js")
		};
		console.log(sources);

		let [l1_svg, tree] = await Promise.all([
			utils.load_svg(sources.l1),
			utils.load_json(sources.tree)
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
		let reference = get_reference_info();
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
						['#l1-daily', '#l1-hourly', '#l1-graphics'].forEach(selector => {
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
						btn.style.cursor = "pointer";
					}
					function subtitle(desc, source) {
						var c = document.getElementById("hp-headers-subtitle");
						if (desc) {
							//var bounds = getAbsoluteNodeBounds(source);
							let bounds = source.getBoundingClientRect();
							console.debug(bounds);
							c.innerHTML = desc;
							c.style.left = (bounds.x + 16) +"px";
							c.style.top = (bounds.y - 150) +"px";
							show(c);
						} else {
							hide(c);
						}
					}
					bind_button("l1-back", "Retroceder", () => {
						history.back();
					});
					bind_button("l1-forward", "Avançar", () => {
						history.forward();
					});
					bind_button("l1-map", "Mapa das estacoes", () => {
						utils.goto_id("l1-cidades");
					});
					bind_button("l1-system", "Status do sistema",() => {
						utils.goto_id("l1-system");
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
					bind_button("l1-graphics", "Gráficos", () => {
						utils.goto_id("l1-graphics");
					});
					bind_button("l1-daily", "Relatório Diário", () => {
						utils.goto_id("l1-daily");
					});
					bind_button("l1-hourly", "Relatório Horário", () => {
						utils.goto_id("l1-hourly");
					});
				}
				return div;
			})();
			let map = new Map(loaded.tree);
			let summary = current_view.level == "l2" ? new StationsSummary(map).get_dom_element() : null
			let rectifiers = current_view.xid == "l1-rectifiers" ? new Rectifiers_component(map).get_dom_element() : null
			let cathodic = current_view.xid == "l1-cathodic" ? new Cathodic_component(map).get_dom_element() : null
			let relatory = current_view.xid == "l1-hourly" ? new RelatoryView(reference, "hour", loaded.tree).get_dom_element() :
					current_view.xid == "l1-daily" ? new RelatoryView(reference, "day", loaded.tree).get_dom_element() :
					null;
			let graphics = current_view.xid == "l1-graphics" ? new Graphic_component(reference).get_dom_element() : null;

			let l2 = create_inline_menu(loaded.tree.root.erpm, "l2");

			l1.id = "header-l1";
			l2.id = "header-l2";

			generated = { hp_headers, l1, l2, summary, current_view, relatory, reference, graphics, cathodic, rectifiers };
		}
	}

	render: {
		if(current_view.level == "l0") {
			setTimeout(() => {
				utils.goto_id("l1-system");
			}, 10e3);
		} else {
			canvas.insertBefore(generated.hp_headers, viewBackground);
			let headers = document.getElementById("hp-headers");
			headers.style.zIndex = 1;
			headers.appendChild(generated.l1);
			if(current_view.level == "l2") {
				headers.appendChild(generated.summary);
			} else if(["l1-hourly", "l1-daily"].includes(current_view.xid)) {
				headers.appendChild(generated.relatory);
			} else if(current_view.xid == "l1-cathodic") {
				headers.appendChild(generated.cathodic);
			} else if(current_view.xid == "l1-rectifiers") {
				headers.appendChild(generated.rectifiers);
			} else if(current_view.xid == "l1-graphics") {
				headers.appendChild(generated.graphics);
			} else if(current_view.xid == "l1-cidades") {
				headers.appendChild(generated.l2);
			}
		}
		background: {
			let cv = generated.current_view;
			let background_url = utils.asset_url("hp/bg/");
			let custom_bg = cv.custom_bg;
			if (cv.xid == "l0-banner") {
				custom_bg = "l0-banner.svg";
			}
			let prefix = cv.class;
			let extension;
			if (custom_bg) {
				let filename = custom_bg;
				let target_url = new URL(filename, background_url);
				utils.load_svg(target_url).then(image => {
					console.log("Background with custom_bg goes fine");
					replace_background(image);
					if (current_view.xid == "l1-system") {
						console.log("inside current_view.xid == l1-system");
						function subtitle(desc, source) {
							var c = document.getElementById("hp-headers-subtitle");
							if (desc) {
								//var bounds = getAbsoluteNodeBounds(source);
								let bounds = source.getBoundingClientRect();
								console.debug(bounds);
								c.innerHTML = desc;
								c.style.left = (bounds.x + 16) +"px";
								c.style.top = (bounds.y - 150) +"px";
								show(c);
							} else {
								hide(c);
							}
						}
						function bind_button(id, tooltip, action) {
							console.log("inside bind_button");
							let btn = document.body.querySelector(`#${id}`);
							btn.onclick = action;
							btn.onmouseover = () => {
								subtitle(tooltip, btn);
							};
							btn.onmouseout = () => {
								subtitle();
							};
							btn.style.cursor = "pointer";
						}
						bind_button("l1-rectifiers", "Retificadores", () => {
							utils.goto_id("l1-rectifiers");
						});
						bind_button("l1-cathodic", "Monitoramento da proteção catódica", () => {
							utils.goto_id("l1-cathodic");
						});
					}
				}).catch(problem => {
					console.error("Error on loading background SVG file");
					console.error({ target_url, filename, extension });
					console.error(problem);
				});
			} else if (prefix) {
				extension = "svg";
				let filename = `${prefix}.${extension}`;
				let target_url = new URL(filename, background_url);
				utils.load_svg(target_url).then(image => {
					console.log("Background with prefix goes fine");
					replace_background(image);
				}).catch(problem => {
					console.error("Error on loading background SVG file");
					console.error({ target_url, filename, extension });
					console.error(problem);
				});
			} else {
				prefix = cv.xid;
				extension = "png";
				let filename = `${prefix}.${extension}`;
				let target_url = new URL(filename, background_url);
				utils.test_url(target_url).then(sucess => {
					console.log("Background without prefix goes fine");
					change_background(target_url);
				}).catch(problem => {
					console.warn("Background file not found");
				});
			}
		}
	}

	loop: {
		if (current_view.level != "l0") {
			let duration = 1e3;
			setInterval(() => {
				clock_update: {
					change_text("date", get_date());
					change_text("time", get_time());
				}
				template: {
					let station_class = current_view.class;
					if(station_class) {
						console.debug({ current_view, template_fields, station_class });
						template_fields[station_class].forEach(field => {
							let instrument_tag = get_tag(field);
							let success;
							api.tag_load_num(instrument_tag).then(value => {
								update_display(field, value);
								success = "\u2714";
							}).catch(problem => {
								//console.error(`Error on field ${field}, expected tag ${instrument_tag}`);
								success = "\u274c";
								console.error({ instrument_tag, field, problem });
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

