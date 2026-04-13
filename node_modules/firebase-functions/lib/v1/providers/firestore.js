const require_rolldown_runtime = require('../../_virtual/rolldown_runtime.js');
const require_params_types = require('../../params/types.js');
const require_params_index = require('../../params/index.js');
const require_common_change = require('../../common/change.js');
const require_v1_cloud_functions = require('../cloud-functions.js');
const require_common_utilities_path = require('../../common/utilities/path.js');
const require_common_providers_firestore = require('../../common/providers/firestore.js');

//#region src/v1/providers/firestore.ts
var firestore_exports = /* @__PURE__ */ require_rolldown_runtime.__export({
	DatabaseBuilder: () => DatabaseBuilder,
	DocumentBuilder: () => DocumentBuilder,
	NamespaceBuilder: () => NamespaceBuilder,
	_databaseWithOptions: () => _databaseWithOptions,
	_documentWithOptions: () => _documentWithOptions,
	_namespaceWithOptions: () => _namespaceWithOptions,
	beforeSnapshotConstructor: () => beforeSnapshotConstructor,
	database: () => database,
	defaultDatabase: () => defaultDatabase,
	document: () => document,
	namespace: () => namespace,
	provider: () => provider,
	service: () => service,
	snapshotConstructor: () => snapshotConstructor
});
/** @internal */
const provider = "google.firestore";
/** @internal */
const service = "firestore.googleapis.com";
/** @internal */
const defaultDatabase = "(default)";
/**
* Select the Firestore document to listen to for events.
* @param path Full database path to listen to. This includes the name of
* the collection that the document is a part of. For example, if the
* collection is named "users" and the document is named "Ada", then the
* path is "/users/Ada".
*/
function document(path) {
	return _documentWithOptions(path, {});
}
function namespace(namespace$1) {
	return _namespaceWithOptions(namespace$1, {});
}
function database(database$1) {
	return _databaseWithOptions(database$1, {});
}
/** @internal */
function _databaseWithOptions(database$1 = defaultDatabase, options) {
	return new DatabaseBuilder(database$1, options);
}
/** @internal */
function _namespaceWithOptions(namespace$1, options) {
	return _databaseWithOptions(defaultDatabase, options).namespace(namespace$1);
}
/** @internal */
function _documentWithOptions(path, options) {
	return _databaseWithOptions(defaultDatabase, options).document(path);
}
var DatabaseBuilder = class {
	constructor(database$1, options) {
		this.database = database$1;
		this.options = options;
	}
	namespace(namespace$1) {
		return new NamespaceBuilder(this.database, this.options, namespace$1);
	}
	document(path) {
		return new NamespaceBuilder(this.database, this.options).document(path);
	}
};
var NamespaceBuilder = class {
	constructor(database$1, options, namespace$1) {
		this.database = database$1;
		this.options = options;
		this.namespace = namespace$1;
	}
	document(path) {
		const normalized = require_params_types.transform(path, require_common_utilities_path.normalizePath);
		const triggerResource = () => {
			if (!process.env.GCLOUD_PROJECT) {
				throw new Error("process.env.GCLOUD_PROJECT is not set.");
			}
			let project = require_params_index.projectID;
			if (process.env.GCLOUD_PROJECT && process.env.FUNCTIONS_CONTROL_API !== "true") {
				project = process.env.GCLOUD_PROJECT;
			}
			let nsPart = "";
			if (this.namespace instanceof require_params_types.Expression) {
				nsPart = new require_params_types.CompareExpression("==", this.namespace, "").thenElse("", require_params_index.expr`@${this.namespace}`);
			} else if (this.namespace) {
				nsPart = `@${this.namespace}`;
			}
			return require_params_index.expr`projects/${project}/databases/${this.database}/documents${nsPart}/${normalized}`;
		};
		return new DocumentBuilder(triggerResource, this.options);
	}
};
function snapshotConstructor(event) {
	return require_common_providers_firestore.createSnapshotFromJson(event.data, event.context.resource.name, event?.data?.value?.readTime, event?.data?.value?.updateTime);
}
function beforeSnapshotConstructor(event) {
	return require_common_providers_firestore.createBeforeSnapshotFromJson(event.data, event.context.resource.name, event?.data?.oldValue?.readTime, undefined);
}
function changeConstructor(raw) {
	return require_common_change.Change.fromObjects(beforeSnapshotConstructor(raw), snapshotConstructor(raw));
}
var DocumentBuilder = class {
	/** @internal */
	constructor(triggerResource, options) {
		this.triggerResource = triggerResource;
		this.options = options;
	}
	/** Respond to all document writes (creates, updates, or deletes). */
	onWrite(handler) {
		return this.onOperation(handler, "document.write", changeConstructor);
	}
	/** Respond only to document updates. */
	onUpdate(handler) {
		return this.onOperation(handler, "document.update", changeConstructor);
	}
	/** Respond only to document creations. */
	onCreate(handler) {
		return this.onOperation(handler, "document.create", snapshotConstructor);
	}
	/** Respond only to document deletions. */
	onDelete(handler) {
		return this.onOperation(handler, "document.delete", beforeSnapshotConstructor);
	}
	onOperation(handler, eventType, dataConstructor) {
		return require_v1_cloud_functions.makeCloudFunction({
			handler,
			provider,
			eventType,
			service,
			triggerResource: this.triggerResource,
			legacyEventType: `providers/cloud.firestore/eventTypes/${eventType}`,
			dataConstructor,
			options: this.options
		});
	}
};

//#endregion
exports.DatabaseBuilder = DatabaseBuilder;
exports.DocumentBuilder = DocumentBuilder;
exports.NamespaceBuilder = NamespaceBuilder;
exports._databaseWithOptions = _databaseWithOptions;
exports._documentWithOptions = _documentWithOptions;
exports._namespaceWithOptions = _namespaceWithOptions;
exports.beforeSnapshotConstructor = beforeSnapshotConstructor;
exports.database = database;
exports.defaultDatabase = defaultDatabase;
exports.document = document;
Object.defineProperty(exports, 'firestore_exports', {
  enumerable: true,
  get: function () {
    return firestore_exports;
  }
});
exports.namespace = namespace;
exports.provider = provider;
exports.service = service;
exports.snapshotConstructor = snapshotConstructor;