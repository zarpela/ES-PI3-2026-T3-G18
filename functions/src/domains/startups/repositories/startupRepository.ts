import {db} from "../../../shared/firebase";

export async function fetchAllStartups(): Promise<Array<Record<string, unknown>>> {
  const snapshot = await db.collection("startups").get();

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));
}
