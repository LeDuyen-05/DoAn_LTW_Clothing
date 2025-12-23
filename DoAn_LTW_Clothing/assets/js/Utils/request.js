const API_DOMAIN = "https://localhost:44328/api/";

export const get = async (path) => {
    const response = await fetch(API_DOMAIN + path);
    const result = await response.json();
    return result;
}

export const post = async (path, option) => {
    const response = await fetch(API_DOMAIN + path, {
        method: "POST",
        headers: {
            Accept: "application/json",
            "Content-type": "application/json",
        },
        body: JSON.stringify(option)
    });
    const reasult = await response.json();
    return reasult;
}

export const del = async (path) => {
    const response = await fetch(API_DOMAIN + path, {
        method: "DELETE",
    })
    const result = await response.json();
    return result;
}

export const patch = async (path, opption) => {
    const response = await fetch(API_DOMAIN + path, {
        method: "PUT",
        headers: {
            Accept: "application/json",
            "Content-type": "application/json",
        },
        body: JSON.stringify(opption)
    })
    const result = response.json();
    return result;
}