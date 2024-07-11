import api from '../api/api.js';

class Api_connector {
	constructor (datapoints) {
		this.datapoints = datapoints;
	}
	download (range, datapoints = this.datapoints) {
		let [start_ts, end_ts] = range;
		console.log({ range, start_ts, end_ts });
		return new Promise((resolve, reject) => {
			let promises = [];
			datapoints.forEach(datapoint => {
				let promise = api.load_tag_history(datapoint, start_ts, end_ts);
				promises.push(promise);
			});
			Promise.all(promises).then(results => {
				resolve(results);
			}).catch(e => {
				reject(e);
			});
		});
	}
}

export default Api_connector;

