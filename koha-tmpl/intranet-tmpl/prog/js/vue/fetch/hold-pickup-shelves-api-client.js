import HttpClient from "./http-client";

export class HoldPickupShelvesAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/holds/pickup_shelves",
        });
    }

    get hold_pickup_shelves() {
        return {
            create: hold_pickup_shelf =>
                this.post({
                    endpoint: "",
                    body: hold_pickup_shelf,
                }),
            delete: id =>
                this.delete({
                    endpoint: "/" + id,
                }),
            update: (hold_pickup_shelf, id) =>
                this.put({
                    endpoint: "/" + id,
                    body: hold_pickup_shelf,
                }),
            patch: (id, body) =>
                this.patch({
                    endpoint: "/" + id,
                    body,
                }),
            get: id =>
                this.get({
                    endpoint: "/" + id,
                }),
            getAll: (query, params) =>
                this.getAll({
                    endpoint: "/",
                    query,
                    params,
                    headers: {},
                }),
        };  
    }
    get available() {
        return {
            getAll: (query, params) =>
                this.getAll({
                    endpoint: "/available",
                    query,
                    params,
                    headers: {},
                }),
        }
    }
    get biblio_level_itemtypes() {
        return {
            getAll: (query, params) =>
                this.getAll({
                    endpoint: "/biblio_level_itemtypes",
                    query,
                    params,
                    headers: {},
                }),
        }
    }
}

export default HoldPickupShelvesAPIClient;
