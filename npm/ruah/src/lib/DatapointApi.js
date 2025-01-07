import ASSETSAPI from './ASSETSAPI';

async function load_json(url) {
	let file = await fetch(url);
	let json = await file.json();
	return json;
}

class DatapointApi {
	static tag_load_num(xid) {
		return new Promise((resolve, reject) => {
			this.tag_load_value(xid).then(string => {
				resolve(Number(string));
			}).catch(problem => {
				reject(problem);
			});
		});
	}

	static tag_load_value(xid) {
		xid = encodeURIComponent(xid);
		let base_url = new URL("api/point_value/getValue/", ASSETSAPI.get_root_path());
		//	use 'xid' instead of xid
		let target_url = new URL(xid, base_url);
		return new Promise((resolve, reject) => {
			load_json(target_url).then(json => {
				if("value" in json) {
					let value = json["value"];
					//console.debug({ xid, value });
					resolve(value);
				} else {
					reject("Bad return on Datapoint API! No value Field found");
				}
			}).catch(problem => {
				console.error(problem);
				reject("Datapoint API returned error!");
			});
		});
	}

	static load_tag_history(datapoint, start, end) {
		let xid = datapoint[0];
		xid = encodeURIComponent(xid);
		let description = datapoint[1];
		let base_url = new URL("api/point_value/getValuesFromTimePeriod/xid/", ASSETSAPI.get_root_path());
		let target_url = new URL(`${xid}/${start}/${end}`, base_url);
		return new Promise((resolve, reject) => {
			load_json(target_url).then(json => {
				json.name = `${json.name} (${description})`;
				//console.debug({ json });
				resolve(json);
			}).catch(problem => {
				console.error({ problem, target_url, xid });
				reject("Datapoint API returned error!");
			});
		});
	}

	static load_tag_history_compressed (datapoint, start, end, points=50) {
		let xid = datapoint[0];
		xid = encodeURIComponent(xid);
		let description = datapoint[1];
		let base_url = new URL("api/point_value/getDistributedPointValues/", ASSETSAPI.get_root_path());
		let target_url = new URL(`${xid}/${start}/${end}/${points}`, base_url);
		return new Promise((resolve, reject) => {
			load_json(target_url).then(json => {
				json.name = `${json.name} (${description})`;
				//console.debug({ json });
				resolve(json);
			}).catch(problem => {
				console.error({ problem, target_url, xid });
				reject("Datapoint API returned error!");
			});
		});
	}
}

export default DatapointApi;

