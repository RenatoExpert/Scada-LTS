class Time_controller {
	constructor () {
		this.spam = 1e3 * 60 * 60 * 24; //	A day
		this.ts_start = 0;
		this.set_end(new Date().valueOf());
		this.state = 'stop';
		this.create_dom_element();
	}

	create_dom_element () {
		let controllers = document.createElement("div");
		controllers.id = "graphic-controllers-div";
		controllers.style.border = "1px solid gray";
		controllers.style.width = "fit-content";
		reverse_button: {
			let reverse = document.createElement("button");
			reverse.innerText = "\u23ea";
			controllers.append(reverse);
		}
		play_button: {
			let play = document.createElement("button");
			play.innerText = "\u25b6";
			play.onclick = () => {
				graphics_memory.player_mode = "running";
			};
			controllers.append(play);
		}
		pause_button: {
			let pause = document.createElement("button");
			pause.innerText = "\u23f8";
			pause.onclick = () => {
				graphics_memory.player_mode = "stopped";
			};
			controllers.append(pause);
		}
		forward_button: {
			let forward = document.createElement("button");
			forward.innerText = "\u23e9";
			controllers.append(forward);
		}
		timer_display: {
			let before_date = document.createElement("input");
				before_date.type = "date";
				before_date.valueAsDate = new Date();
				before_date.required = true;
				controllers.append(before_date);
			let before_time = document.createElement("input");
				before_time.addEventListener("change", clear_minutes);
				before_time.type = "time";
				before_time.valueAsNumber = 0;
				before_time.required = true;
				before_time.disabled = step == 'day';
				controllers.append(before_time);
			let after_date = document.createElement("input");
				controllers.append(after_date);
			let after_time = document.createElement("input");
				controllers.append(after_time);
			let time_spam = document.createElement("div");
			time_spam.innerText = "27/06/2024 16:30";
			controllers.append(time_spam);
		}
		controllers.children.forEach(child => {
			child.style.height = "30px";
			child.style.width = "100px";
		});
		this.dom_element = controllers;
	}

	get_selected_range () {
		return [this.ts_start, this.ts_end];
	}

	get_dom_element () {
		return this.dom_element;
	}

	loop () {
		this.increment_time();
		this.update_display();
	}

	update_display () {
		let current = document.getElementById("graphics-timer");
		let time_ms = graphics_memory.time_range.end;
		let time_string = new Date(time_ms).toLocaleString();
		current.innerText = time_string;
		//	Update also play/pause buttons
	}

	increment_time () {
		if(this.state == "run") {
			this.set_end(this.ts_end + 100);
		}
	}

	play () { }
	pause () { }

	set_spam (new_spam) {
		this.spam = new_spam;
		this.update_start();
	}

	set_end (new_end) {
		this.ts_end = new_end;
		this.update_start();
	}

	update_start () {
		this.ts_start = this.ts_end - this.spam;
	}
}

export default Time_controller;

