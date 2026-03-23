import apiClient from "../api/client";

export const useCalendarTokens = () => {
  return apiClient.useQuery("get", "/Calendar/has-valid-tokens", {
    retry: false,
  });
};

export const useCalendarList = () => {
  return apiClient.useQuery("get", "/Calendar/list-calendars", {
    retry: false,
  });
};

export const useCalendarSettings = () => {
  return apiClient.useQuery("get", "/Calendar/settings", {
    retry: false,
  });
};
