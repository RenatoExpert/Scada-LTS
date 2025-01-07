import ASSETSAPI from "../lib/ASSETSAPI";
import Component from "../prototype/Component";
import DatapointApi from "../lib/DatapointApi";

class LiveThread {
	constructor (station_tag, element) {
		this.node = element;
		let suffix = element.id.split("update-")[1];
		this.datapoint = station_tag + ":" + suffix.toLowerCase();
		this.errorCount = 0;
		this.displayElement = Array.from(element.children)
			.find(child => child.getAttribute("inkscape:label") == "numeric value")
			.children[0]
			.children[0];
		this.start_thread();
	}

	write_value (value) {
		console.log({ value, displayElement: this.displayElement });
		this.displayElement.innerHTML = value;
	}

	fetch_value () {
		console.debug("Trying to get value of XID " + this.datapoint);
		console.debug({ errorCount: this.errorCount });
		if (this.errorCount < 3) {
			DatapointApi.tag_load_num(this.datapoint).then(value => {
				console.debug("Datapoint loaded with success " + value);
				this.write_value(value);
			}).catch(error => {
				console.error("Could not fetch tag value");
				this.errorCount += 1;
				console.error(error);
			});
		} else {
			console.warn("Stopping Thread at XID " + this.datapoint);
			this.stop_thread();
		}
	}

	start_thread () {
		this.thread = setInterval(() => {
			this.fetch_value();
		}, 1.2e3);
	}

	stop_thread () {
		clearInterval(this.thread);
	}
}

class Synoptic extends Component {
	constructor (map, bgName) {
		let nodeTag = "div";
		let className = "hp-livediagram";
		super(map, nodeTag, className);
		this.bgName = bgName;
		this.#make_child();
	}

	#make_child () {
		ASSETSAPI.fetch_svg(this.bgName).then(svg => {
			let station_tag = this.map.params.address;
			this.node.appendChild(svg);
			let elementSet = svg.querySelectorAll('[id^="update-"]');
			elementSet.forEach(element => {
				new LiveThread(station_tag, element);
			});
		});
	}
}

export default Synoptic;

