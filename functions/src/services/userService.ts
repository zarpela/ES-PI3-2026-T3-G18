import {auth, db} from "../config/firebase";

export const createUser = async (data: any) => {
  const {email, senha, nome, cpf, telefone} = data;

  // cria no Firebase Auth
  const userRecord = await auth.createUser({
    email,
    password: senha,
  });

  // salva dados no Firestore
  await db.collection("users").doc(userRecord.uid).set({
    nome,
    cpf,
    telefone,
    email,
    createdAt: new Date(),
  });

  return userRecord;
};
