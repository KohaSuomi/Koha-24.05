import HttpClient from "./http-client";

export class PatronAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/",
        });
    }

    get patrons() {
        return {
            get: id =>
                this.get({
                    endpoint: "patrons/" + id,
                }),
        };
    }
    get patron_categories() {
        return {
            getAll: (query, params) =>
                this.getAll({
                    endpoint: "patron_categories",
                    query,
                    params,
                    headers: {},
                }),
        };
    }
}

export default PatronAPIClient;
