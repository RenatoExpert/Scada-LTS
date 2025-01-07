const serveStatic = require("serve-static");
const express = require("express");
const path = require("path");
const app = express();
const port = process.env.PORT || 8080;

const api_router = require("./api_router.cjs");

const root_router = express.Router();
let html_path = path.join(__dirname, "../html");
root_router.use(express.static(html_path));
root_router.use("/api", api_router);

function logger (req, res, next) {
	console.log({
		from: req.get("X-Forwarded-For"),
		method: req.method,
		url: req.originalUrl,
		auth: req.get("Authorization")
	});
	next();
}

app.use(logger);
app.get("/", (req, res) => {
	res.redirect("/argos");
});
app.use("/argos", root_router);
app.use((err, req, res, next) => {
	console.error(err);
});

app.listen(port, () => {
	console.log(`Server listen into port ${port}!!!`);
});

