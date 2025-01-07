function getCurrentParameter (key) {
	return new URLSearchParams(window.location.search).get(key);
}

function getCurrentAddress () {
	return getCurrentParameter("address");
}

function getCurrentReference () {
	return getCurrentParameter("reference");
}

function getCurrentViewId () {
	return getCurrentParameter("viewId");
}

function getCurrentPage () {
	return getCurrentParameter("page");
}

function makeURL (address, reference, viewId, page) {
	let link = `?address=${address}&reference=${reference}&viewId=${viewId}&page=${page}`;
	return link;
}

class NAVAPI {
	static goto_id (newAddress, reference, viewId) {
		reference = reference || getCurrentAddress();
		viewId = viewId || getCurrentViewId();
		window.location.href = makeURL(newAddress, reference, viewId, null);
	}

	static append_address (childName) {
		let newAddress = getCurrentAddress() + ":" + childName;
		console.log({ append_address: { childName, newAddress } });
		this.goto_id(newAddress);
	}

	static page_url (pageIndex) {
		let address = getCurrentAddress();
		let reference = getCurrentReference();
		let viewId = getCurrentViewId();
		return makeURL(address, reference, viewId, pageIndex);
	}
}

export default NAVAPI;

