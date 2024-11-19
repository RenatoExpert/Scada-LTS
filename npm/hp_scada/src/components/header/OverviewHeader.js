import Component from '../../prototype/Component.js';
import ASSETSAPI from '../../lib/ASSETSAPI.js';
import NAVAPI from '../../lib/NAVAPI.js';

function get_date () {
	let date = new Date();
	let day = date.getDate();
	let month = date.toLocaleString('pt-br', { month: 'long' });
	let year = date.getFullYear();
	return `${day} de ${month} de ${year}`;
}

function get_time () {
	function two_digit(num) {
		num = `${num}`;
		while (num.length < 2) {
			num = "0" + num;
			if (num.length > 2) {
				throw new Error(`Error while parsing number in two_digit function: ${num}`);
			}
		}
		return num;
	}
	let date = new Date();
	let hours = two_digit(date.getHours());
	let minutes = two_digit(date.getMinutes());
	let seconds = two_digit(date.getSeconds());
	return `${hours}:${minutes}:${seconds}`;
}

function change_text (id, value) {
	document.getElementById(id).innerHTML = value;
}

function subtitle(desc, source) {
	var c = document.getElementById("hp-headers-subtitle");
	if (desc) {
		//var bounds = getAbsoluteNodeBounds(source);
		let bounds = source.getBoundingClientRect();
		console.debug(bounds);
		c.innerHTML = desc;
		c.style.left = (bounds.x + 16) +"px";
		c.style.top = (bounds.y - 150) +"px";
		show(c);
	} else {
		hide(c);
	}
}

class OverviewHeader extends Component {
	constructor (map) {
		let nodeTag = "div";
		super(map, nodeTag);
		this.#make_child();
	}

	#make_child () {
		let path = "hp/header_L1.svg";
		ASSETSAPI.fetch_svg(path).then(svg => {
			this.node.appendChild(svg);
			static_strings: {
				this.node.querySelector("#process-title").innerHTML = this.map.title;
				this.node.querySelector("#operator-name").innerHTML = this.map.user.fullname;
				if(this.map.levelmap.max == 3) {
					['#l1-daily', '#l1-hourly', '#l1-graphics'].forEach(selector => {
						set_visible(selector, div);
					});
				}
			}
			this.#bind_buttons();
		});
	}

	#bind_button (id, tooltip, action) {
		let btn = this.node.querySelector(`#${id}`);
		btn.onclick = action;
		btn.onmouseover = () => {
			subtitle(tooltip, btn);
		};
		btn.onmouseout = () => {
			subtitle();
		};
		btn.style.cursor = "pointer";
	}

	#bind_buttons () {
		this.#bind_button("l1-back", "Retroceder", () => {
			history.back();
		});
		this.#bind_button("l1-forward", "Avançar", () => {
			history.forward();
		});
		this.#bind_button("l1-map", "Mapa das estacoes", () => {
			NAVAPI.goto_id("erpm");
		});
		this.#bind_button("l1-system", "Status do sistema",() => {
			NAVAPI.goto_id("system");
		});
		this.#bind_button("l1-refresh", "Atualizar tela", () => {
			location.reload();
		});
		this.#bind_button("l1-mute", "Silenciar alarmes", () => {
			alert("Sound muted!");
		});
		this.#bind_button("l1-login", "Entrar", () => {
			window.location.href = "login.htm";
		});
		this.#bind_button("l1-lock", "Sair", () => {
			window.location.href = "logout.htm";
		});
		this.#bind_button("l1-graphics", "Gráficos", () => {
			NAVAPI.goto_id("l1-graphics");
		});
		this.#bind_button("l1-daily", "Relatório Diário", () => {
			NAVAPI.goto_id("l1-daily");
		});
		this.#bind_button("l1-hourly", "Relatório Horário", () => {
			NAVAPI.goto_id("l1-hourly");
		});
	}

	#update_clock () {
		let timeInterval = 1e3;
		setInterval(() => {
			change_text("date", get_date());
			change_text("time", get_time());
		}, timeInterval);
	}
}

export default OverviewHeader;

