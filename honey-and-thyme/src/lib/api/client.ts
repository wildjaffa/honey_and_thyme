import createFetchClient, { type Middleware } from "openapi-fetch";
import createClient from "openapi-react-query";
import type { paths } from "./v1";

const bearerTokenMiddleware: Middleware = {
  async onRequest({ request }) {
    const token = localStorage.getItem("bearerToken");
    if (token) {
      request.headers.set("Authorization", `Bearer ${token}`);
    }
    return request;
  },
};

const fetchClient = createFetchClient<paths>({
  baseUrl: import.meta.env.VITE_BASE_URL,
  credentials: "include",
});

fetchClient.use(bearerTokenMiddleware);

const apiClient = createClient(fetchClient);

export default apiClient;
