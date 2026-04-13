const require_rolldown_runtime = require('../_virtual/rolldown_runtime.js');
const require_v2_providers_dataconnect_index = require('./providers/dataconnect/index.js');
const require_v2_providers_dataconnect_graphql = require('./providers/dataconnect/graphql.js');

//#region src/v2/dataconnect.doc.ts
var dataconnect_doc_exports = /* @__PURE__ */ require_rolldown_runtime.__export({
	graphql: () => require_v2_providers_dataconnect_graphql.graphql_exports,
	mutationExecutedEventType: () => require_v2_providers_dataconnect_index.mutationExecutedEventType,
	onMutationExecuted: () => require_v2_providers_dataconnect_index.onMutationExecuted
});

//#endregion
Object.defineProperty(exports, 'dataconnect_doc_exports', {
  enumerable: true,
  get: function () {
    return dataconnect_doc_exports;
  }
});
Object.defineProperty(exports, 'graphql', {
  enumerable: true,
  get: function () {
    return require_v2_providers_dataconnect_graphql.graphql_exports;
  }
});
exports.mutationExecutedEventType = require_v2_providers_dataconnect_index.mutationExecutedEventType;
exports.onMutationExecuted = require_v2_providers_dataconnect_index.onMutationExecuted;