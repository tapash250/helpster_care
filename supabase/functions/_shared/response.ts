// Shared helpers for Helpster Care Edge Functions.
// Enforces the standard API response envelope (AGENTS.md §48) and never leaks
// internal SQL errors to clients.

export interface ApiResponse<T> {
  success: boolean;
  data: T | null;
  message: string;
  error: { code: string } | null;
}

/** Builds a successful response envelope. */
export function ok<T>(data: T, message = ""): Response {
  const body: ApiResponse<T> = {
    success: true,
    data,
    message,
    error: null,
  };
  return json(body, 200);
}

/** Builds a failure response envelope with a stable error code. */
export function fail(code: string, message: string, status = 400): Response {
  const body: ApiResponse<null> = {
    success: false,
    data: null,
    message,
    error: { code },
  };
  return json(body, status);
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
