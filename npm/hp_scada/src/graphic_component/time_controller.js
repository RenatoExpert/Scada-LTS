class Time_controller {
	constructor () {
		this.forward_speed = 10e3;
		this.reverse_speed = -10e3;
		this.normal_speed = 1e3;
		this.current_speed = 0;
		this.start_event = new Event("start", {
			bubbles: true,
			cancelable: true
		});
		this.stop_event = new Event("stop", {
			bubbles: true,
			cancelable: true
		});
		this.forward_event = new Event("forward", {
			bubbles: true,
			cancelable: true
		});
		this.reverse_event = new Event("reverse", {
			bubbles: true,
			cancelable: true
		});
		this.after_selection_event = new Event("change_after_selection", {
			bubbles: true,
			cancelable: true
		});
		this.create_dom_element();
		this.spam = 0;
		this.ts_start = 0;
		this.ts_end = 0;
		//this.set_spam(1e3 * 60 * 60 * 24); //	A day
		this.set_spam(1e3 * 60); //	A minute
		this.set_end(new Date().valueOf());
		this.state = 'stop';
		this.children = this.dom_element.children;
	}

	on_new_frame (callback) {
		this.new_frame_callback = callback;
		this.update_display();
		return this;
	}

	create_dom_element () {
		let controller_obj = this;
		let controllers = document.createElement("div");
		controllers.addEventListener("start", () => {
			console.log("inside controllers event listener to start");
			this.start();
		});
		controllers.addEventListener("stop", () => {
			console.log("inside controllers event listener to stop");
			this.stop();
		});
		controllers.addEventListener("forward", () => {
			console.log("inside controllers event listener to stop");
			this.forward();
		});
		controllers.addEventListener("reverse", () => {
			console.log("inside controllers event listener to stop");
			this.reverse();
		});
		controllers.addEventListener("change_after_selection", () => {
			this.set_after_selection();
		});
		controllers.id = "graphic-controllers-div";
		controllers.style.border = "1px solid gray";
		controllers.style.width = "fit-content";
		reverse_button: {
			let reverse = document.createElement("button");
			reverse.id = "reverse";
			reverse.innerText = "\u23ea";
			reverse.addEventListener("click", pointer_event => {
				reverse.dispatchEvent(controller_obj.reverse_event);
			});
			controllers.append(reverse);
		}
		play_button: {
			let play = document.createElement("button");
			play.id = "play";
			play.innerText = "\u25b6";
			play.addEventListener("click", pointer_event => {
				play.dispatchEvent(controller_obj.start_event);
			});
			controllers.append(play);
		}
		pause_button: {
			let pause = document.createElement("button");
			pause.id = "pause";
			pause.innerText = "\u23f8";
			pause.addEventListener("click", pointer_event => {
				pause.dispatchEvent(controller_obj.stop_event);
			});
			controllers.append(pause);
		}
		forward_button: {
			let forward = document.createElement("button");
			forward.id = "forward";
			forward.innerText = "\u23e9";
			forward.addEventListener("click", pointer_event => {
				forward.dispatchEvent(controller_obj.forward_event);
			});
			controllers.append(forward);
		}
		timer_display: {
			let before_date = document.createElement("input");
				before_date.id = "before-date";
				before_date.type = "date";
				before_date.valueAsDate = new Date();
				before_date.disabled = true;
				controllers.append(before_date);
			let before_time = document.createElement("input");
				before_time.id = "before-time";
				before_time.type = "time";
				before_time.valueAsNumber = 0;
				before_time.disabled = true;
				controllers.append(before_time);
			let after_date = document.createElement("input");
				after_date.id = "after-date";
				after_date.type = "date";
				after_date.valueAsDate = new Date();
				after_date.required = true;
				after_date.addEventListener("change", pointer_event => {
					after_date.dispatchEvent(controller_obj.after_selection_event);
				});
				controllers.append(after_date);
			let after_time = document.createElement("input");
				after_time.id = "after-time";
				after_time.addEventListener("change", () => {
					after_time.dispatchEvent(controller_obj.after_selection_event);
				});
				after_time.type = "time";
				after_time.valueAsNumber = 0;
				after_time.required = true;
				after_time.addEventListener("change", pointer_event => {
					after_time.dispatchEvent(controller_obj.after_selection_event);
				});
				controllers.append(after_time);
			let time_spam = document.createElement("button");
				time_spam.id = "time-spam";
				time_spam.disabled = true;
			time_spam.innerText = "1d";
			controllers.append(time_spam);
		}
		Array.from(controllers.children).forEach(child => {
			child.style.height = "30px";
			child.style.width = "100px";
			child.style.borderWidth = "3px";
			child.style.borderStyle = "solid";
			child.style.borderColor = "gainsboro gray gray gainsboro";
			child.style.textAlign = "center";
			child.style.background = "#d0bfff69";
		});
		this.dom_element = controllers;
	}

	get_selected_range () {
		return [this.ts_start, this.ts_end];
	}

	get_dom_element () {
		return this.dom_element;
	}

	stop () {
		console.log('stop controller');
		if (this.interval) {
			clearInterval(this.interval);
			this.interval = null;
		} else {
			console.error("Graphic Controller is not running");
		}
	}

	run_engine (speed) {
		console.log('controller: run_engine()');
		this.current_speed = speed;
		if (this.interval) {
			console.error("Graphic Controller is already running");
		} else {
			console.log("Creating interval loop...");
			let self = this;
			this.interval = setInterval(_ => {
				self.loop();
			}, 1e3);
			//	Maybe need to pass this on 3rd parameter, to be used as 'self'
		}
	}

	forward () {
		this.run_engine(this.forward_speed);
	}

	reverse () {
		this.run_engine(this.reverse_speed);
	}

	start () {
		this.run_engine(this.normal_speed);
	}

	loop () {
		if(!this.hasFocus()) {
			this.increment_time();
		}
	}

	increment_time () {
		this.set_end(this.ts_end + this.current_speed);
	}

	hasFocus () {
		return ['after-time', 'after-date', 'before-time', 'before-date', 'time-spam'].includes(document.activeElement.id);
	}

	set_after_selection () {
		let time = this.get_dom_element().querySelector("#after-time").valueAsNumber;
		let date = this.get_dom_element().querySelector("#after-date").valueAsNumber;
		let fix = 6 * 60 * 60 * 1e3;
		let sum = date + time + fix;
		console.log({ fn: "set_after_selection()", time, date, sum });
		this.set_end(sum);
	}

	set_end (new_end) {
		let now = new Date().valueOf();
		console.log({ fn: "set_end()", new_end, now });
		if(new_end > now) {
			console.error("Trying to get future!");
		} else {
			this.ts_end = new_end;
			this.update_start();
		}
	}

	update_start () {
		this.ts_start = this.ts_end - this.spam;
		console.log({ fn: "update_start", start: this.ts_start, end: this.ts_end, spam: this.spam });
		this.update_display();
	}

	update_display () {
		this.update_time_display();
		try {
			console.log({ ts_start: this.ts_start, ts_end: this.ts_end });
			this.new_frame_callback(this.ts_start, this.ts_end);
		} catch (e) {
			console.error("Error while calling new_frame_callback");
			console.error(e);
		}
	}

	update_time_display () {
		console.log('update_display');
		Array.from(this.dom_element.children).forEach(child => {
			let id = child.id;
			if (id == "before-date") {
				let ts = this.get_start();
				child.valueAsNumber = ts;
			} else if (id == "before-time") {
				let ts = this.get_start();
				let value = new Date(ts).toLocaleString().split(', ')[1];
				child.value = value;
			} else if (id == "after-date") {
				let ts = this.get_end();
				child.valueAsNumber = ts;
			} else if (id == "after-time") {
				let ts = this.get_end();
				let value = new Date(ts).toLocaleString().split(', ')[1]
				child.value = value;
			} else if (id == "time-spam") {
			} else if (id == "play") {
			} else if (id == "pause") {
			} else if (id == "forward") {
			} else if (id == "reverse") {
			} else {
				console.error(`id not found for child ${child}`);
			}
		});
	}

	set_spam (new_spam) {
		this.spam = new_spam;
		this.update_start();
	}

	get_start () {
		return this.ts_start;
	}

	get_end () {
		return this.ts_end;
	}

}

export default Time_controller;

