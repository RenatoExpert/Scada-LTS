class Id_handler {
	constructor (current_view) {
		this.current_view = current_view;
		console.log({ current_view });
		this.area_tag = `ERPM${current_view.process.code}`;
		this.station_suffix = `FQ${current_view.code}`;
		this.station_tag = `${this.area_tag}-${this.station_suffix}`;
		this.dp_suffixes = [
			"PI-1",
			"TI-1",
			"EI-1"
		];
		this.estimate_datapoints();
	}

	estimate_datapoints () {
		let datapoints = [];
		this.dp_suffixes.forEach(suffix => {
			let datapoint = `${this.station_tag}-${suffix}`;
			datapoints.push(datapoint);
		});
		this.datapoints = datapoints;
	}
}

export default Id_handler;

