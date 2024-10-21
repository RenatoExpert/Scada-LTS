function getCurrentParameter (key) {
	return new URLSearchParams(window.location.search).get(key);
}

function getCurrentAddress () {
	return getCurrentParameter("address");
}

function getCurrentViewId () {
	return getCurrentParameter("viewId");
}

function getCurrentPage () {
	return getCurrentParameter("page");
}

function makeURL (newAddress, reference, viewId, page) {
	reference = reference || getCurrentAddress();
	viewId = viewId || new URLSearchParams(window.location.search).get("viewId");
	page = page || getCurrentPage();
	let link = `?address=${newAddress}&reference=${reference}&viewId=${viewId}&page=${page}`;
}

class NAVAPI {
	static goto_id (id, reference, viewId) {
		window.location.href = makeURL(id, reference, viewId, null);
	}

	static page_url (pageIndex) {
		return makeURL(null, null, null, pageIndex);
	}
}

export default NAVAPI;

