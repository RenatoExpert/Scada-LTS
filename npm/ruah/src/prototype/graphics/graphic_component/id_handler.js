class Id_handler {
	constructor (station_address) {
		this.station_address = station_address;
		this.dp_suffixes = [
			["PI-1", "Pressão"],
			["TI-1", "Temperatura"],
			["EI-1", "Tensão"]
		];
		this.estimate_datapoints();
	}

	estimate_datapoints () {
		let datapoints = [];
		this.dp_suffixes.forEach(meta_dp => {
			let suffix = meta_dp[0].toLowerCase();
			let datapoint = `${this.station_address}:${suffix}`;
			let description = meta_dp[1];
			datapoints.push([datapoint, description]);
		});
		this.datapoints = datapoints;
	}
}

export default Id_handler;

