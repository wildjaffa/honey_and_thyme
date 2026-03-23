import { useState, useEffect } from "react";
import { useQueryClient } from "@tanstack/react-query";
import apiClient from "../../api/client";
import {
  useCalendarTokens,
  useCalendarList,
  useCalendarSettings,
} from "../../hooks/useCalendar";
import { HoneyButton, HoneyCircularLoader } from "../../components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCalendar,
  faChevronDown,
  faChevronUp,
  faCheckCircle,
  faCircleCheck,
  faCircle,
} from "@fortawesome/free-solid-svg-icons";
import type { CalendarListEntry } from "../../types/api";
import { getEnv } from "../../utils/env";

// Declare google global for GIS
declare global {
  interface Window {
    google?: {
      accounts: {
        oauth2: {
          initCodeClient: (config: {
            client_id: string;
            scope: string;
            ux_mode: "popup";
            callback: (response: { code: string }) => void;
          }) => {
            requestCode: () => void;
          };
        };
      };
    };
  }
}

const CalendarSettings = () => {
  const queryClient = useQueryClient();
  const [isExpanded, setIsExpanded] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);

  // Queries
  const { data: hasValidTokens, isLoading: isLoadingTokens } =
    useCalendarTokens();

  const validTokens = hasValidTokens?.result === true;

  const { data: calendars, isLoading: isLoadingCalendars } = useCalendarList();

  const { data: settings, isLoading: isLoadingSettings } =
    useCalendarSettings();

  // Mutations
  const connectMutation = apiClient.useMutation(
    "post",
    "/Calendar/exchange-auth-code",
  );
  const disconnectMutation = apiClient.useMutation(
    "post",
    "/Calendar/revoke-tokens",
  );
  const updateSettingsMutation = apiClient.useMutation(
    "post",
    "/Calendar/settings",
  );

  const invalidateCalendarQueries = () => {
    queryClient.invalidateQueries({
      queryKey: ["get", "/Calendar/has-valid-tokens"],
    });
    queryClient.invalidateQueries({
      queryKey: ["get", "/Calendar/list-calendars"],
    });
    queryClient.invalidateQueries({
      queryKey: ["get", "/Calendar/settings"],
    });
  };

  // Effect to expand if not configured
  useEffect(() => {
    if (!isLoadingTokens && !isLoadingSettings) {
      if (validTokens && !settings?.preferredCalendarId) {
        setIsExpanded(true);
      }
    }
  }, [validTokens, settings, isLoadingTokens, isLoadingSettings]);

  const requestAuthCode = () => {
    const clientId = getEnv("GOOGLE_CLIENT_ID");
    if (!clientId) {
      console.error("Missing VITE_GOOGLE_CLIENT_ID");
      setIsConnecting(false);
      return;
    }

    if (window.google?.accounts?.oauth2) {
      const client = window.google.accounts.oauth2.initCodeClient({
        client_id: clientId,
        scope:
          "https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/calendar.events",
        ux_mode: "popup",
        callback: (response) => {
          if (response.code) {
            connectMutation.mutate(
              { body: { authCode: response.code } },
              {
                onSuccess: () => {
                  invalidateCalendarQueries();
                  setIsConnecting(false);
                },
                onError: () => {
                  setIsConnecting(false);
                },
              },
            );
          } else {
            setIsConnecting(false);
          }
        },
      });
      client.requestCode();
    } else {
      console.error("Google Identity Services not loaded");
      setIsConnecting(false);
    }
  };

  const handleConnect = () => {
    setIsConnecting(true);

    if (window.google?.accounts?.oauth2) {
      requestAuthCode();
      return;
    }

    const scriptSrc = "https://accounts.google.com/gsi/client";
    let script = document.querySelector(
      `script[src="${scriptSrc}"]`,
    ) as HTMLScriptElement;

    if (!script) {
      script = document.createElement("script");
      script.src = scriptSrc;
      script.async = true;
      script.defer = true;
      document.body.appendChild(script);
    }

    const previousOnload = script.onload;
    script.onload = (ev: Event) => {
      if (previousOnload) {
        (previousOnload as (this: GlobalEventHandlers, ev: Event) => void).call(
          script,
          ev,
        );
      }
      requestAuthCode();
    };

    script.onerror = () => {
      setIsConnecting(false);
      console.error("Failed to load Google Identity Services script");
    };
  };

  const handleDisconnect = () => {
    disconnectMutation.mutate(undefined, {
      onSuccess: () => {
        invalidateCalendarQueries();
      },
    });
  };

  const handleUpdateSettings = (calendarId: string) => {
    // Optimistic update or just wait for refetch
    updateSettingsMutation.mutate(
      { body: { preferredCalendarId: calendarId } },
      {
        onSuccess: () => {
          invalidateCalendarQueries();
        },
      },
    );
  };

  const isLoading = isLoadingTokens || isLoadingCalendars || isLoadingSettings;

  return (
    <div className="rounded-lg border border-gray-200 bg-white p-4 shadow-sm">
      <div
        className="flex cursor-pointer items-center justify-between"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <div className="flex items-center gap-3">
          <FontAwesomeIcon
            icon={faCalendar}
            className="text-gray-500"
            size="lg"
          />
          <h2 className="text-lg font-bold text-gray-800">
            Google Calendar Settings
          </h2>
        </div>
        <FontAwesomeIcon
          icon={isExpanded ? faChevronUp : faChevronDown}
          className="text-gray-500"
        />
      </div>

      {isExpanded && (
        <div className="animate-fade-in mt-4">
          {isLoading ? (
            <div className="flex justify-center py-4">
              <HoneyCircularLoader />
            </div>
          ) : validTokens ? (
            <div className="space-y-4">
              <div className="flex items-center justify-between rounded-md bg-green-50 p-3">
                <div className="flex items-center gap-2 text-green-700">
                  <FontAwesomeIcon icon={faCheckCircle} />
                  <span className="font-medium">Connected</span>
                </div>
                <div className="rounded bg-red-500 text-white">
                  <HoneyButton
                    onClick={handleDisconnect}
                    disabled={disconnectMutation.isPending}
                  >
                    Disconnect
                  </HoneyButton>
                </div>
              </div>

              {calendars && calendars.length > 0 ? (
                <div>
                  <h3 className="mb-2 font-medium text-gray-700">
                    Select Calendar for Publishing Events:
                  </h3>
                  <div className="space-y-2">
                    {calendars.map((calendar: CalendarListEntry) => (
                      <div
                        key={calendar.id}
                        className={`flex cursor-pointer items-center justify-between rounded-md border p-3 transition-colors ${
                          settings?.preferredCalendarId === calendar.id
                            ? "border-blue-500 bg-blue-50"
                            : "border-gray-200 hover:bg-gray-50"
                        }`}
                        onClick={() =>
                          calendar.id && handleUpdateSettings(calendar.id)
                        }
                      >
                        <div className="flex items-center gap-3">
                          <FontAwesomeIcon
                            icon={
                              settings?.preferredCalendarId === calendar.id
                                ? faCircleCheck
                                : faCircle
                            }
                            className={
                              settings?.preferredCalendarId === calendar.id
                                ? "text-blue-500"
                                : "text-gray-300"
                            }
                          />
                          <div>
                            <div className="font-medium text-gray-800">
                              {calendar.summary}
                            </div>
                            {calendar.primary && (
                              <div className="text-xs text-gray-500">
                                Primary Calendar
                              </div>
                            )}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              ) : (
                <div className="text-gray-500">No calendars found.</div>
              )}
            </div>
          ) : (
            <div className="space-y-4">
              <p className="text-gray-600">
                Connect your Google Calendar to automatically publish photo
                shoot events.
              </p>
              <div className="flex w-full justify-center">
                <HoneyButton
                  onClick={handleConnect}
                  disabled={isConnecting || connectMutation.isPending}
                >
                  {isConnecting || connectMutation.isPending
                    ? "Connecting..."
                    : "Connect Calendar"}
                </HoneyButton>
              </div>
            </div>
          )}
        </div>
      )}

      {!isExpanded && validTokens && settings?.preferredCalendarId && (
        <div className="mt-2 flex items-center gap-2 text-sm text-gray-500">
          <FontAwesomeIcon icon={faCheckCircle} className="text-green-500" />
          <span>Calendar connected and configured</span>
        </div>
      )}
    </div>
  );
};

export default CalendarSettings;
