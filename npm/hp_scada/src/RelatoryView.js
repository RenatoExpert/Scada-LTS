import utils from './utils/utils.js';
import api from './api/api.js';

var generated_relatory = false;
var relatory_memory = {};


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

function make_relatory_indexes(from, to) {
	let hour_in_ms = 60 * 60 * 1e3;
	let day_in_ms = hour_in_ms * 24;
	let formstep = document.getElementById("select-timestep");
	let step = formstep.value == "hour" ? hour_in_ms : day_in_ms;
	let indexes = [];
	let min = from;
	let max = min + step;
	while(max < to) {
		indexes.push(get_timedate(min));
		min = max;
		max += step;
	}
	return indexes;
}
function render_relatory(obj, id_col) {
	let iframe = document.getElementById("relatory-iframe");
	let parent_dom = iframe.contentWindow.document.getElementById('relatory-table')
	let child_dom = generate_relatory_dom(obj, id_col);
	parent_dom.replaceChildren(child_dom);
}

function get_hist_tags(area_code, station_code) {
	let sample = {
		raw_volume: [`ERPM${area_code}-FQ${station_code}-FQIA-1`, "Contagem anterior"],
		std_volume: [`ERPM${area_code}-FQ${station_code}-FQI-1`, "Contagem atual"],
		avg_pressure: [`ERPM${area_code}-FQ${station_code}-PI-1`, "Pressão"],
		avg_temperature: [`ERPM${area_code}-FQ${station_code}-TI-1`, "Temperatura"]
	};
	return sample;
}

function relatory(area_code, station_code, start_ts, end_ts, id_col = 'Data-hora') {
	let tags = get_hist_tags(area_code, station_code);
	let promises = [];
	let indexes = make_relatory_indexes(start_ts, end_ts);
	Object.getOwnPropertyNames(tags).forEach(key => {
		let tag = tags[key];
		let promise = new Promise((resolve, reject) => {
			api.load_tag_history(tag, start_ts, end_ts).then(json => {
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

function download_pdf() {
	let iframe = document.getElementById('relatory-iframe');
	iframe.contentWindow.print();
}

function clear_minutes(e) {
	let input = e.srcElement;
	console.log(input);
	console.log(input.value);
	let previous = input.value;
	let clean = previous.replace(/:../, ":00");
	input.value = clean;
}

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

function update_station_options(area, station_select, reference) {
	station_select.replaceChildren();
	Object.values(area.children).forEach(child => {
		let option = document.createElement("option");
		option.value = child.code;
		option.innerText = child.label;
		option.selected = child.code == reference.code ? 'selected' : '';
		station_select.append(option);
	});
}

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
		if (area && station) {
			relatory(area, station, start_ts, end_ts);
			generated_relatory = true;
			isValid = true;
		} else {
			console.error({ area, station });
			throw new Error("Error on validade_filter");
		}
	} catch (e) {
		isValid = false;
		console.error(e);
	} finally {
		console.log({ start_ts, end_ts });
		return isValid;
	}
}

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

function make_selector_div(id, title, callback) {
	return make_field_div("select", id, title, callback);
}

function get_area_by_intcode(intcode, children) {
	let area_obj;
	Object.values(children).forEach(area => {
		if (area.code == intcode) {
			area_obj = area;
		}
	});
	if (area_obj) {
		console.debug(`Area found for code ${intcode}`);
		console.debug({ area_obj, intcode });
		return area_obj;
	} else {
		throw new Error(`Area not found for code ${intcode}`);
	}
}



// RelatoryView.js
class RelatoryView {
	constructor(reference, timestep, tree) {
		this.reference = reference;
		this.timestep = timestep;
		this.tree = tree;
		this.generated_relatory = false;
		this.generate_dom_element();
	}

	get_dom_element() {
		return this.dom_element;
	}

	downloadXlsx() {
		console.log("xlsx");
	}

	checkRelatoryThenSave(data, filename, type) {
		if (this.generated_relatory) {
			this.saveFile(data, filename, type);
		} else {
			throw new Error("No relatory generated to be saved!");
		}
	}

	saveFile(data, filename, type) {
		let file = new Blob([data], { type });
		let anchor = document.createElement("a");
		let url = URL.createObjectURL(file);
		anchor.href = url;
		anchor.download = filename;
		document.body.appendChild(anchor);
		anchor.click();
		document.body.removeChild(anchor);
		window.URL.revokeObjectURL(url);
	}

	generate_dom_element(obj, id_col) {
		let root = document.createElement("div");
		root.style.display = "grid";
		generate_filter: {
			let filter = document.createElement("div");
			let form = document.createElement("form");
			form.id = "relatory-form";
			form.addEventListener("submit", validate_filter);
			form.action = "javascript:;";
			form.style.padding = "3px 15px";
			selectors: {
				let area_value;
				let area = make_selector_div('select-area', "Área", element => {
					element.addEventListener("change", function on_change_area(e) {
						let area;
						get_area: {
							let area_selector = document.getElementById('select-area');
							let area_code = area_selector.value;
							console.log({ socorro: this.tree });
							area = get_area_by_intcode(area_code, this.tree.root.children);
						}
						let station_select = document.getElementById('select-station');
						let reference = generated.reference;
						update_station_options(area, station_select, reference);
					});
					Object.values(this.tree.root.erpm).forEach(child => {
						let option = document.createElement("option");
						option.value = child.code;
						option.innerText = child.label;
						option.selected = child.code == this.reference.process.code ? 'selected' : '';
						element.append(option);
					});
					area_value = element.value;
				});
				form.append(area);
				let area_int_code = get_area_by_intcode(area_value, this.tree.root.children);
				let station = make_selector_div('select-station', "Estação", element => {
					update_station_options(area_int_code, element, this.reference)
				});
				form.append(station);
			}
			start: {
				let date = make_field_div("input", "start-date", "Data Início", element => {
					element.type = "date";
					let days_delta = this.timestep == 'day' ? 3 : 1;
					let ms_in_day = 1e3 * 60 * 60 * 24;
					element.valueAsNumber = new Date() - (ms_in_day * days_delta);
					element.required = true;
				});
				form.append(date);
				let time = make_field_div("input", "start-time", "Hora Início", element => {
					element.addEventListener("change", clear_minutes);
					element.type = "time";
					element.valueAsNumber = 0;
					element.required = true;
					element.disabled = this.timestep == 'day';
				});
				form.append(time);
			}
			end: {
				let date = make_field_div("input", "end-date", "Data Final", element => {
					element.type = "date";
					element.valueAsDate = new Date();
					element.required = true;
				});
				form.append(date);
				let time = make_field_div("input", "end-time", "Hora Início", element => {
					element.addEventListener("change", clear_minutes);
					element.type = "time";
					element.valueAsNumber = 0;
					element.required = true;
					element.disabled = this.timestep == 'day';
				});
				form.append(time);
			}
			step_type: {
				let timestep = make_selector_div("select-timestep", "Tipo de relatório", element => {
					element.addEventListener("change", on_change_timestep);
					let hourly = document.createElement("option");
					hourly.value = "hour";
					hourly.innerText = "Horário";
					hourly.selected = this.timestep == "hour" ? 'selected' : '';
					element.append(hourly);
					let daily = document.createElement("option");
					daily.value = "day";
					daily.innerText = "Diário";
					daily.selected = this.timestep == "day" ? 'selected' : '';
					element.append(daily);
				})
				form.append(timestep);
			}
			submit: {
				let submit = make_field_div("input", "form-submit", "*", element => {
					element.type = "submit";
					element.value = "Gerar";
					element.style.backgroundColor = "lightgray";
					element.style.borderRadius = "5px";
					element.style.width = "50px";
				});
				form.append(submit);
			}
			filter.append(form);
			file_export: {
				let export_menu = document.createElement("div");
				let pdf = make_field_div("button", "export-pdf", "Export as", element => {
					element.innerText = "PDF";
					element.onclick = download_pdf;
				});
				export_menu.append(pdf);
				let csv = make_field_div("button", "export-csv", "Export as", element => {
					element.innerText = "csv";
					element.onclick = download_csv;
				});
				export_menu.append(csv);
				let xlsx = make_field_div("button", "export-xlsx", "Export as", element => {
					element.innerText = "xlsx";
					element.onclick = download_xlsx;
				});
				export_menu.append(xlsx);
				filter.append(export_menu);
			}
			root.append(filter);
		}
		let iframe_parent = document.createElement("div");
		iframe_parent.style.padding = "15px 30px";
		let relatory_iframe = document.createElement("IFRAME");
		relatory_iframe.id = "relatory-iframe";
		relatory_iframe.height = "500";
		relatory_iframe.width = "1150";
		iframe_parent.append(relatory_iframe);
		root.append(iframe_parent);
		after_dom: {
			let relatory_table = document.createElement("div");
			relatory_table.id = "relatory-table";
			let observer = new MutationObserver((mutationList, observer) => {
				for (let mutation of mutationList) {
					console.log({ mutation });
					if (document.getElementById("relatory-iframe")) {
						relatory_iframe.contentWindow.document.body.append(relatory_table);
						observer.disconnect();
					}
				}
			});
			observer.observe(document.getElementById("viewContent"), { childList: true });
		}
		this.dom_element = root;
		return this.dom_element;
	}
}

export default RelatoryView;
