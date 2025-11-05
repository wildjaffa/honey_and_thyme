import createFetchClient from "openapi-fetch";
import createClient from "openapi-react-query";
import type { paths } from "./v1";

const fetchClient = createFetchClient<paths>({
  baseUrl: import.meta.env.VITE_BASE_URL,
});

const apiClient = createClient(fetchClient);

export default apiClient;
