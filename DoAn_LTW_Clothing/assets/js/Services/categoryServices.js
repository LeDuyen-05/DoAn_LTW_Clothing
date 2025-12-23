import { del, get, patch, post } from "../Utils/request.js";

export const getCategorietList = async () => {
    const result = await get("Categories");
    return result;
}

export const getCategoryDetail = async (id) => {
    const result = await get(`Categories/${id}`);
    return result;
}

export const createCategorie = async (option) => {
    const reasult = await post("Categories", option);
    return reasult;
}

export const deleteCategorie = async (id) => {
    const result = await del(`Categories/${id}`);
    return result;
}

export const editCategorie = async (id, opption) => {
    const result = await patch(`Categories/${id}`, opption)
    return result;
}