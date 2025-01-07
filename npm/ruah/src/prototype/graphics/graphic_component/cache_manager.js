import Api_connector from './api_connector.js';

function is_between (x, min, max) {
	return x > min && x < max;
}

function is_inside (min_i, max_i, min_j, max_j) {
	return is_between(min_i, min_j, max_j) && is_between(max_i, min_j, max_j);
}

function do_collides (min_i, max_i, min_j, max_j) {
	return is_between(min_i, min_j, max_j) || is_between(max_i, min_j, max_j);
}

function subtract_list (input_list, subtrahend) {
	let output_list = [];
	subtract_range(input_list, subtrahend).forEach(missing_range => {
		output_list.push(missing_range);
	});
	return output_list;
}

function subtract_range (minuend, subtrahend) {
	let output_list = [];
	if (collision) {
		if (inside) {
			output_list = [
				[minuend[0], subtrahend[0]],
				[subtrahend[1], minuend[1]]
			];
		} else {
			if (minuend[0] < subtrahend[0]) {
				output_list = [
					[minuend[0], subtrahend[0]]
				];
			} else {
				output_list = [
					[subtrahend[1], minuend[1]]
				];
			}
		}
	} else {
		output_list = [minuend];
	}
	return output_list;
}

function int_seconds (ts) {
	let ms = ts % 1000;
	let cleaned = ts - ms; 
	return cleaned;
}

class Cache_manager {
	constructor () {
		this.loaded_ranges = [];
		this.data = {};
		this.connector = new Api_connector();
		this.cached_promise = new Promise(resolve => resolve());
		this.no_pending = true;
	}

	query (range, datapoints) {
		let newPromise;
		if (this.no_pending) {
			newPromise = new Promise((resolve, reject) => {
				this.no_pending = false;
				this.connector.download(range, datapoints).then(results => {
					let memory = {};
					results.forEach(result => {
						let xid = result.name;
						result.values.forEach(point => {
							let int_ts = int_seconds(point.ts);
							let ts = new Date(int_ts).toLocaleString();
							memory[ts] = memory[ts] ? memory[ts] : {};
							memory[ts][xid] = point.value;
						});
					});
					let mixed = [];
					let labels = [];
					Object.keys(memory).forEach(ts => {
						labels.push(ts);
						let frame = memory[ts];
						frame.time = ts;
						mixed.push(frame);
					});
					let datasets = [];
					results.forEach(result => {
						let xid = result.name;
						let dataset = {
							label: xid,
							data: mixed,
							parsing: {
								yAxisKey: xid,
								xAxisKey: "time"
							}
						};
						datasets.push(dataset);
					});
					let data = {
						labels,
						datasets
					};
					resolve(data);
				}).catch(e => {
					reject(e);
				});
			});
			newPromise.finally(() => {
				this.no_pending = true;
			});
		} else {
			newPromise = new Promise((resolve, reject) => {
				reject(new Error ("Previous Promise Still Open"));
			});
		}
		return newPromise;
	}

	_get_missing_parts (selected_range) {
		let missing = [selected_range];
		this.loaded_ranges.forEach(loaded_range => {
			let missing = subtract_range(missing, loaded_range);
		});
		return missing;
	}

	register_range (range, frames) {
		frames.forEach(frame => {
			this.data[frame.label] = frame.values;
		});
		this.loaded_ranges.push(range);
		this.check_and_merge_collisions();
	}

	check_and_merge_collisions () {
		//      Create merges
		let original = this.loaded_ranges;
		let merges = [];
		for(let i = 0; i < original.length - 1; i++) {
			let [min_i, max_i] = original[i];
			for(let j = i + 1; j < original.length; j++) {
				let [min_j, max_j] = original[j];
				let merge = merge(min_i, max_i, min_j, max_j);
				if (merge) {
					merges.push(merge);
				}
			}
		}
		//      Clear redundancies
		let cleaned = original.filter(range => {
			let filter_flag = true;
			merges.forEach(merge => {
				if (do_collides(range[0], range[1], merge[0], merge[1])) {
					filter_flag = false;
				}
			});
			return filter_flag;
		});
		let result = cleaned.concat(merges);
		this.loaded_ranges = result;
	}
}

export default Cache_manager;
