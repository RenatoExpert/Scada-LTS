
class NAVAPI {
	static goto_id (id, reference, viewId) {
		reference = reference || new URLSearchParams(window.location.search).get("address");
		viewId = viewId || new URLSearchParams(window.location.search).get("viewId");
		let link = `?address=${id}&reference=${reference}&viewId=${viewId}`;
		window.location.href = link;
	}
}

export default NAVAPI;

