import api from '../api/api.js';

class Api_connector {
	constructor (datapoints) {
		this.datapoints = datapoints;
	}
	download (range, datapoints = this.datapoints) {
		return new Promise((resolve, reject) => {
			datapoints.forEach(datapoint => {
				api.load_tag_history(tag, start_ts, end_ts).then(json => {
					resolve(json);
				}).catch(e => {
					console.error(e);
					reject(e);
				});
			});
		});
	}
}

export default Api_connector;

