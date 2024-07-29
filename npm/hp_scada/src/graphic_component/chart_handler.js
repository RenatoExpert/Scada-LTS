import Chart from 'chart.js/auto';

class Chart_handler {
	constructor (graphic_title) {
		this.config = {
			type: "line",
			options: {
				/*
				scales: {
					x: {
						display: true,
						type: 'time',
						time: {
							parser: 'MM/DD/YYYY HH:mm',
							tooltipFormat: 'll HH:mm',
							unit: 'day',
							unitStepSize: 1,
							displayFormats: {
								'day': 'MM/DD/YYYY'
							}
						}
					}
				},
				*/
				animation: false,
				plugins: {
					title: {
						display: true,
						text: graphic_title
					}
				}
			}
		};
		this.dom_element = this.create_dom_element();
		this.chart = new Chart(this.dom_element, this.config);
	}

	create_dom_element() {
		let canvas = document.createElement("canvas");
		canvas.addEventListener("click", () => {
			console.log({ chart: this.chart, data: this.chart.data });
			console.log({ hidden: detect_hidden(this.chart) });
		});
		canvas.id = "graphic-canvas";
		canvas.id = "graphics-canvas";
		canvas.width = "350";
		canvas.height = "100";
		return canvas;
	}

	get_dom_element () {
		return this.dom_element;
	}

	render (data) {
		this.chart.data = data;
		let hidden_list = detect_hidden(this.chart);
		apply_hidden(this.chart, hidden_list);
		this.chart.update('active');
	}
}

function detect_hidden (chart) {
	let list = [];
	chart.legend.legendItems.forEach(item => {
		if (item.hidden) {
			list.push(item.text);
		}
	});
	return list;
}

function apply_hidden (chart, hidden_list) {
	chart.data.datasets.forEach(dataset => {
		let label = dataset.label;
		if (hidden_list.includes(label)) {
			dataset.hidden = true;
		}
	});
}


export default Chart_handler;

