import IsConnected from "./IsConnected.js";
import Modem from "./Modem.js";
import Component from "../../Component.js";

class Label extends Component {
	constructor (text) {
		let map = null;
		let tag = "div"
		let className = "hp-label";
		super(map, tag, className);
		this.node.innerText = text;
	}
}

class Unknown extends Component {
	constructor () {
		let map = null;
		let tag = "spam";
		let className = "hp-unknown";
		super(map, tag, className);
		this.node.innerText = "Unknown Column";
	}
}

class TableData extends Component {
	constructor (column, isatag) {
		let map = null;
		let nodetag = "td";
		let className = "TableData"
		super(map, nodetag, className);
		this.#makeChild(column, isatag);
	}

	#makeChild (column, isatag) {
		let type = column.type;
		if (type == "SELFLABEL") {
			col = new Label(column.label)
		} else if (type == "ISCONNECTED") {
			col = new IsConnected(isatag);
		} else if (type == "COMSTATUS") {
			col = new Modem(isatag);
		} else {
			col = new Unknown();
		}
		this.node.append(col.node);
	}
}

export default TableData;

				/*
				/*
				let suffix = "SG-1";
				let obj = new Check_display(this.station_tag, suffix, this.clock, "Conectado", "Desconectado");
				col = obj.get_dom_element();

				let suffix = "SG-1";
				let obj = new Check_display(this.station_tag, suffix, this.clock, "OK", "Err");
				col = obj.get_dom_element();
			} else if (item.type == "CLOCK") {
				col = this.clock.get_dom_element();
			} else if (item.type == "NUMBER") {
				let obj = new Numeric_display(this.station_tag, item.suffix, item.eunit, this.clock);
				col = obj.get_dom_element();
			} else if (item.type == "BUTTON") {
				let button = document.createElement("button");
				button.textContent = item.label;
				let xid = item.target;
				button.onclick = () => {
					utils.goto_id(xid);
				};
				col = button
				*/
