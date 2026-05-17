// Desenvolvido por Miguel Castro

import { onCall } from "firebase-functions/v2/https";
import { getSellOrders } from "../repositories/exchangeRepository";

export const getSellOrdersHandler = onCall(
    { region: "southamerica-east1" },
    async () => {

        const orders = await getSellOrders();

        return {
            count: orders.length,
            data: orders,
        };
    }
);