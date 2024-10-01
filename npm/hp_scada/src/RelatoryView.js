import utils from './utils/utils.js';

// RelatoryView.js
class RelatoryView {
    constructor(reference, timestep, tree) {
        this.reference = reference;
        this.timestep = timestep;
        this.tree = tree;
        this.generated_relatory = false;
    }
    get_dom_element(id) {
        return document.getElementById(id);
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

    render_relatory(obj, id_col) {
        let iframe = document.getElementById("relatory-iframe");
        let parent_dom = iframe.contentWindow.document.getElementById('relatory-table')
        let child_dom = this.generate_relatory_dom(obj, id_col);
        parent_dom.replaceChildren(child_dom);
    }

    generate_relatory_dom(obj, id_col, linear = true) {
        this.dom_element = document.createElement("div");
        this.dom_element.style.padding = "3px 15px";
        let table = document.createElement("table");
        header: {
            let row = document.createElement("tr");
            let headers = [id_col, "Volume não-corrigido", "Volume corrigido", "Pressão Média", "Temperatura Média"];
            for(let header in headers) {
                let col = utils.tag_text("th", headers[header]);
                col.style.padding = "2px 15px";
                row.append(col);
            }
            table.append(row);
        }
        body: {
            let raw_volume_eu = linear ? "m³" : "kPa";
            let std_volume_eu = "m³";
            let avg_pressure_eu = "kgf/cm²";
            let avg_temperature_eu = "ºC";
            Object.getOwnPropertyNames(obj).forEach(time => {
                let frame = obj[time];
                let row = document.createElement("tr");
                let { raw_volume, std_volume, avg_pressure, avg_temperature } = frame;
                let cols = [
                    time,
                    utils.format_var(raw_volume, raw_volume_eu),
                    utils.format_var(std_volume, std_volume_eu),
                    utils.format_var(avg_pressure, avg_pressure_eu),
                    utils.format_var(avg_temperature, avg_temperature_eu)
                ];
                for(let i in cols) {
                    let col = utils.tag_text("td", cols[i]);
                    col.style.padding = "2px 15px";
                    col.style.textAlign = "right";
                    row.append(col);
                }
                table.append(row);
            });
        }
        this.dom_element.append(table);
        return this.dom_element;
    }
}

export default RelatoryView;

    /*
    make_relatory_indexes(from, to) {
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

    get_hist_tags(area_code, station_code) {
        let sample = {
            raw_volume: [`ERPM${area_code}-FQ${station_code}-FQIA-1`, "Contagem anterior"],
            std_volume: [`ERPM${area_code}-FQ${station_code}-FQI-1`, "Contagem atual"],
            avg_pressure: [`ERPM${area_code}-FQ${station_code}-PI-1`, "Pressão"],
            avg_temperature: [`ERPM${area_code}-FQ${station_code}-TI-1`, "Temperatura"]
        };
        return sample;
    }
}

export default RelatoryView;


function render_relatory(obj, id_col) {
	let iframe = document.getElementById("relatory-iframe");
	let parent_dom = iframe.contentWindow.document.getElementById('relatory-table')
	let child_dom = generate_relatory_dom(obj, id_col);
	parent_dom.replaceChildren(child_dom);
}

function generate_relatory_dom(obj, id_col, linear = true) {
	let relatory = document.createElement("div");
	relatory.style.padding = "3px 15px";
	let table = document.createElement("table");
	header: {
		let row = document.createElement("tr");
		let headers = [id_col, "Volume não-corrigido", "Volume corrigido", "Pressão Média", "Temperatura Média"];
		for(let header in headers) {
			let col = utils.tag_text("th", headers[header]);
			col.style.padding = "2px 15px";
			row.append(col);
		}
		table.append(row);
	}
	body: {
		let raw_volume_eu = linear ? "m³" : "kPa";
		let std_volume_eu = "m³";
		let avg_pressure_eu = "kgf/cm²";
		let avg_temperature_eu = "ºC";
		Object.getOwnPropertyNames(obj).forEach(time => {
			let frame = obj[time];
			let row = document.createElement("tr");
			let { raw_volume, std_volume, avg_pressure, avg_temperature } = frame;
			let cols = [
				time,
				utils.format_var(raw_volume, raw_volume_eu),
				utils.format_var(std_volume, std_volume_eu),
				utils.format_var(avg_pressure, avg_pressure_eu),
				utils.format_var(avg_temperature, avg_temperature_eu)
			];
			for(let i in cols) {
				let col = utils.tag_text("td", cols[i]);
				col.style.padding = "2px 15px";
				col.style.textAlign = "right";
				row.append(col);
			}
			table.append(row);
		});
	}
	relatory.append(table);
	return relatory;
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

function get_hist_tags(area_code, station_code) {
	let sample = {
		raw_volume: [`ERPM${area_code}-FQ${station_code}-FQIA-1`, "Contagem anterior"],
		std_volume: [`ERPM${area_code}-FQ${station_code}-FQI-1`, "Contagem atual"],
		avg_pressure: [`ERPM${area_code}-FQ${station_code}-PI-1`, "Pressão"],
		avg_temperature: [`ERPM${area_code}-FQ${station_code}-TI-1`, "Temperatura"]
	};
	return sample;
}

*/