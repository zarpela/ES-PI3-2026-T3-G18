import {Request, Response} from "express";
import {createUser} from "../services/userService";

export const createAccount = async (req: Request, res: Response) => {
  try {
    const user = await createUser(req.body);

    return res.status(201).json({
      ok: true,
      userId: user.uid,
    });
  } catch (error: any) {
    console.error(error);

    return res.status(400).json({
      ok: false,
      error: "Erro ao criar conta",
    });
  }
};
