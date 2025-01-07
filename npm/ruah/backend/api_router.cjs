const express = require("express");

const point_value_router = express.Router();

point_value_router.use((req, res, next) => {
	console.log("/point_value router activated");
	next();
});

point_value_router.get("/getValue/:xid", (req, res) => {
	console.log("Work on getValue");
	res.json({
	});
});

point_value_router.get("/getValuesFromTimePeriod/xid/:xid/:start/:end", (req, res) => {
	console.log("Work on getValuesFromTimePeriod");
	res.json({
	});
});

point_value_router.get("/getDistributedPointValues/:xid/:start/:end/:points", (req, res) => {
	console.log("Work on getDistributedPointValues");
	res.json({
		name: "random variable name",
		values: [
			{
				ts: new Date(),
				value: Math.random() * 100
			},
			{
				ts: new Date() - 1e3,
				value: Math.random() * 100
			},
			{
				ts: new Date() - 2e3,
				value: Math.random() * 100
			},
			{
				ts: new Date() - 3e3,
				value: Math.random() * 100
			}
		]
	});
});

const router = express.Router();
//	Just in case express.Router({ mergeParams: true })
//	Routes based on /api/
router.use((req, res, next) => {
	console.log("/api router activated");
	next();
});
router.use("/point_value", point_value_router);

module.exports = router;

