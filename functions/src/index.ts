import cors from "cors";
import express from "express";
import {onRequest} from "firebase-functions/v2/https";
import authRoutes from "./domains/auth";
import {getStartups} from "./domains/startups";
import userRoutes from "./domains/users";

const app = express();

app.use(cors({origin: true}));
app.use(express.json());
app.use(userRoutes);
app.use(authRoutes);

app.get("/", (_req, res) => {
  res.json({message: "Backend rodando."});
});

export const api = onRequest(
  {region: "southamerica-east1"},
  app,
);

export {getStartups};
