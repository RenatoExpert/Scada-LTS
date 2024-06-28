class Id_handler {
	constructor (reference) {
		this.station = reference;
		this.datapoints = this.estimate_datapoints() ;
	}
	estimate_datapoints () {
		return ["rd_1", "rd_2"];
	}
}

export default Id_handler;

