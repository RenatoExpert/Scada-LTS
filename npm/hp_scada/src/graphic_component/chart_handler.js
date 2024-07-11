import Chart from 'chart.js/auto';

class Chart_handler {
	constructor () {
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
						text: "Posto trevo"
					}
				}
			}
		};
		this.dom_element = this.create_dom_element();
		this.chart = new Chart(this.dom_element, this.config);
	}

	create_dom_element() {
		let canvas = document.createElement("canvas");
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
		this.chart.update();
	}
}

export default Chart_handler;

