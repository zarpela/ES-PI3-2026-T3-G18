// Importa o Firebase Functions (permite criar funções HTTP - sua API)
import * as functions from "firebase-functions";

// Importa o Express (framework para criar rotas como /login, /users, etc.)
import express from "express";

// Cria uma aplicação Express
const app = express();

// Middleware que permite receber dados em formato JSON (req.body)
app.use(express.json());




// Define uma rota GET na URL "/"
// Quando acessar no navegador, essa função será executada
app.get("/", (req, res) => {
  
  // Envia uma resposta simples para testar se a API está funcionando
  res.send("Backend rodando 🚀");
});



// Define uma rota POST chamada "/login"
// POST é usado quando enviamos dados (como email e senha)
app.post("/login", (req, res) => {
  
  // Extrai email e senha do corpo da requisição (JSON)
  const { email, senha } = req.body;

  // Verifica se os dados enviados são iguais aos definidos
  if (email === "admin@test.com" && senha === "123") {
    
    // Retorna sucesso em formato JSON
    return res.json({ message: "Login ok" });
  }

  // Caso os dados estejam errados, retorna erro 401 (não autorizado)
  return res.status(401).json({ error: "Credenciais inválidas" });
});



// Exporta a aplicação Express como uma função HTTP do Firebase
// Isso transforma sua API em uma Cloud Function acessível por URL
export const api = functions.https.onRequest(app);

export { getStartups } from "./startups/getStartups";