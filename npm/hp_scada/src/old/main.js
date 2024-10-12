import App;

let app = new App();
boot: {
	if(document.currentScript.hasAttribute("boot")) {
		app.print();
	}
}

