import Component from './Component.js';
import DatapointApi from '../lib/DatapointApi.js';

class StatefulComponent extends Component {
	constructor (datapoint, className = "StatefulComponent") {
		let map = null;
		let nodeTag = 'td';
		super (map, nodeTag, className);
		this.datapoint = datapoint;
		this.errorCount = 0;
		this.start_loop();
		this.openRequestCount = 0;
	}

	fetch_value () {
		//console.debug({ datapoint: this.datapoint });
		this.openRequestCount += 1;
		DatapointApi.tag_load_num(this.datapoint).then(value => {
			//console.debug({ datapoint: this.datapoint, stats: "pegou" });
			this.write_value(value);
		}).catch((error) => {
			//console.debug({ datapoint: this.datapoint, stats: "deu erro" });
			this.errorCount += 1;
			console.error({ error, Component: this, datapoint: this.datapoint });
		}).finally(() => {
			setTimeout(() => {
				this.openRequestCount -= 1;
			}, 1e3 * this.errorCount);
		});
	}

	get_address () {
		return this.address;
	}

	replace_text (value) {
		this.node.innerText = value;
	}

	write_value (value) {
		this.replace_text(value);
	}

	write_error () {
		this.replace_text("\u274C");
	}

	start_loop () {
		this.loopPointer = setInterval(() => {
			let mayStop = this.errorCount > 3;
			//console.debug({ mayStop, errorCount: this.errorCount, datapoint: this.datapoint });
			if (mayStop) {
				this.stop_loop();
			} else if (this.openRequestCount > 1) {
				//	Skip - do not make a request before finishing another one
			} else {
				this.fetch_value();
			}
		}, 3e3);
	}

	stop_loop () {
		//console.debug({ message: "Stop loop", errorCount: this.errorCount, datapoint: this.datapoint });
		clearInterval(this.loopPointer);
		this.write_error();
	}
}

export default StatefulComponent;

