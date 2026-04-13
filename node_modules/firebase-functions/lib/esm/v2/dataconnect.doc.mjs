import { __export } from "../_virtual/rolldown_runtime.mjs";
import { mutationExecutedEventType, onMutationExecuted } from "./providers/dataconnect/index.mjs";
import { graphql_exports } from "./providers/dataconnect/graphql.mjs";

//#region src/v2/dataconnect.doc.ts
var dataconnect_doc_exports = /* @__PURE__ */ __export({
	graphql: () => graphql_exports,
	mutationExecutedEventType: () => mutationExecutedEventType,
	onMutationExecuted: () => onMutationExecuted
});

//#endregion
export { dataconnect_doc_exports, graphql_exports as graphql, mutationExecutedEventType, onMutationExecuted };