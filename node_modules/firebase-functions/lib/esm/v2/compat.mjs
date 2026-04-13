//#region src/v2/compat.ts
const V1_COMPAT_PATCHED = Symbol.for("firebase.functions.v2.compat");
/**
* Patches a CloudEvent with V1 compatibility properties via getters.
* This function ensures idempotency by using a Symbol to mark already patched events.
* @param event The CloudEvent to patch.
* @param getters A map of getters to attach to the event object.
* @returns The patched CloudEvent with V1 compatibility properties.
*/
function addV1Compat(event, getters) {
	if (event[V1_COMPAT_PATCHED]) {
		return event;
	}
	Object.defineProperty(event, V1_COMPAT_PATCHED, {
		value: true,
		enumerable: false,
		writable: false,
		configurable: false
	});
	const memo = {};
	for (const [key, getter] of Object.entries(getters)) {
		Object.defineProperty(event, key, {
			get: () => {
				if (!Object.prototype.hasOwnProperty.call(memo, key)) {
					memo[key] = getter();
				}
				return memo[key];
			},
			configurable: true,
			enumerable: true
		});
	}
	return event;
}

//#endregion
export { addV1Compat };