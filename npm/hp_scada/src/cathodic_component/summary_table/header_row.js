import utils from '../../utils/utils.js';

class Header_row {
	constructor () {
		this.create_dom_element();
	}

	create_dom_element () {
		let row = document.createElement("tr");
		row.style.backgroundColor = "#b4b4c4";
		let headers = ["Estacao", "Modem", "Comunicacao", "Atualizacao", "Entrada", "Saida", "Temperatura", "Vazao", "Mes", "Anterior"];
		for(let header in headers) {
			let col = utils.tag_text("th", headers[header]);
			row.append(col);
		}
		this.dom_element = row;
	}

	get_dom_element () {
		return this.dom_element;
	}
}

export default Header_row;

