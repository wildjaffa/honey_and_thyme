import apiClient from "../api/client";

function useProducts() {
  const queryResult = apiClient.useQuery("get", "/api/Product/list", {});
  return queryResult;
}

export default useProducts;
