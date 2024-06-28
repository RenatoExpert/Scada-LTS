import Chart from 'chart.js/auto';

class Chart_handler {
	constructor () {
		this.config = {
			type: "line",
			options: {
				plugins: {
					title: {
						display: true,
						text: "Visualizador gráfico"
					}
				}
			}
		};
		this.dom_element = this.create_dom_element();
		this.chart = new Chart(this.dom_element, this.config);
	}

	get_dom_element () {
		return this.dom_element;
	}

	create_dom_element() {
		let canvas = document.createElement("canvas");
		canvas.id = "graphic-canvas";
		canvas.id = "graphics-canvas";
		canvas.width = "350";
		canvas.height = "100";
		return canvas;
	}

	update (data) {
		this.canvas.data = data;
		this.canvas.update();
	}

	update_chart () {
		let data = graphics_memory.storage.current_data;
		this.chart.data.datasets = data.datasets;
		this.chart.data.labels = data.labels;
		this.chart.update();
		console.log('update_graphics()');
		console.log({ chart: this.chart, data });
	}
}


function render_frame(raw_labels, raw_datasets, limit = 100) {
	graphics_memory.storage.raw.datasets = raw_datasets;
	graphics_memory.storage.raw.labels = raw_labels;
	let labels = [];
	let mixed_datasets = [];
	for(let i in raw_labels) {
		let length = raw_labels.length;
		let ratio = Math.round(length / (limit - 1));
		if(i % ratio == 0 || i == 0) {
			let label = raw_labels[i];
			labels.push(label);
			mixed_datasets.push({
				label,
				data: raw_datasets[label]
			});
		}
	}
	graphics_memory.storage.filtered.datasets = mixed_datasets;
	graphics_memory.storage.filtered.labels = labels;
	graphics_memory.storage.current_data = {
		labels,
		datasets: [
			{
				label: "Pressure",
				data: mixed_datasets,
				parsing: { yAxisKey: "rd_1" }
			},
			{
				label: "Temperature",
				data: mixed_datasets,
				parsing: { yAxisKey: "rd_2" }
			}
		]
	};
	update_graphics();
}

export default Chart_handler;
