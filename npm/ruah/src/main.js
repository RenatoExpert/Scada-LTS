import App from './App.js';

let app = new App();
boot: {
	if (document.currentScript.hasAttribute("boot")) {
		app.print();
	}
}

