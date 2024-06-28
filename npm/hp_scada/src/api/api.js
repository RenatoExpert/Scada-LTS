import utils from '../utils/utils.js';

//	==============================================================================================
//	SCADA API

function tag_load_num(xid) {
	return new Promise((resolve, reject) => {
	tag_load_value(xid).then(string => {
			resolve(Number(string));
		}).catch(problem => {
			reject(problem);
		});
	});
}

function tag_load_value(xid) {
	let base_url = new URL("api/point_value/getValue/", utils.get_root_path());
	let target_url = new URL(xid, base_url);
	return new Promise((resolve, reject) => {
		utils.load_json(target_url).then(json => {
			if("value" in json) {
				let value = json["value"];
				console.debug({ xid, value });
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

function load_tag_history(xid, start, end) {
	let base_url = new URL("api/point_value/getValuesFromTimePeriod/xid/", utils.get_root_path());
	let target_url = new URL(`${xid}/${start}/${end}`, base_url);
	return new Promise((resolve, reject) => {
		utils.load_json(target_url).then(json => {
			console.debug({ json });
			resolve(json);
		}).catch(problem => {
			console.error({ problem, target_url, xid });
			reject("Datapoint API returned error!");
		});
	});
}

const api = {
	tag_load_num,
	tag_load_value,
	load_tag_history
};

export default api;

