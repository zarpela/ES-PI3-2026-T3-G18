// feito por miguel castro
import { onRequest } from "firebase-functions/v2/https";
import express from "express";
import userRoutes from "./routes/userRoutes";
import testRoutes from "./routes/testRoutes";
import { getStartups } from "./startups/getStartups";

const app = express();

app.use((req, res, next) => {
  res.set("Access-Control-Allow-Origin", req.headers.origin || "*");
  res.set("Vary", "Origin");
  res.set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  next();
});

app.use(express.json());

app.get("/", (req, res) => {
  res.send("Backend rodando 🚀");
});

app.use("/api", userRoutes);
app.use("/api", testRoutes);

export const api = onRequest({ region: "southamerica-east1" }, app);
export { getStartups };