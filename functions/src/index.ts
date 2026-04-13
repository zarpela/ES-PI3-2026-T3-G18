// Importa o Firebase Functions (permite criar funções HTTP - sua API)
import {onRequest} from "firebase-functions/v2/https";
// Importa o Express (framework para criar rotas como /login, /users, etc.)
import express from "express";
import cors from "cors";
// IMPORTAR ROTAS
import userRoutes from "./routes/userRoutes";
import testRoutes from "./routes/testRoutes";

const app = express();

// Cria uma aplicação Express e configura o CORS para permitir requisições de qualquer origem (útil para desenvolvimento)
app.use(cors({origin: true}));
app.use(express.json());


// Define uma rota GET na URL "/"
// Quando acessar no navegador, essa função será executada
app.get("/", (req, res) => {
  // Envia uma resposta simples para testar se a API está funcionando
  res.send("Backend rodando 🚀");
});


// USAR ROTAS
app.use("/api", userRoutes);
app.use("/api", testRoutes);



// Exporta a aplicação Express como uma função HTTP do Firebase
// Isso transforma sua API em uma Cloud Function acessível por URL
export const api = onRequest(
  {region: "southamerica-east1"},
  app
);

export { getStartups } from "./startups/getStartups";