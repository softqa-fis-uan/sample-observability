import React from "react";
import { createRoot } from "react-dom/client";
import App from "./components/App";

// Import and init Sentry SDK
import * as Sentry from "@sentry/react";
// Import and init Faro SDK
import { FaroRoutes, initializeFaro } from '@grafana/faro-react';
import { getWebInstrumentations } from '@grafana/faro-web-sdk';
// import { BrowserRouter, Routes, Route } from 'react-router-dom';

Sentry.init({
  // TODO: replace with your own DSN
  dsn: "https://123456789.ingest.sentry.io/123456789",
  integrations: [
    new Sentry.BrowserTracing({}), new Sentry.Replay()
  ],

  // Set tracesSampleRate to 1.0 to capture 100%
  // of transactions for performance monitoring.
  tracesSampleRate: 1.0,

  // Capture Replay for 10% of all sessions,
  // plus for 100% of sessions with an error
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
});

// Use a relative URL so the dev-server proxy (configured in webpack)
// can forward requests to the Loki backend and avoid CORS during dev.
// TODO: This requires to use a Faro collector to transform the data into the Loki format.
// const faro = initializeFaro({
//   url: '/loki/api/v1/push',
//   app: {
//     name: 'frontend-react',
//     version: '1.0.0',
//     environment: 'development',
//   },
//   instrumentations: [...getWebInstrumentations()],
// });

const container = document.getElementById("root");
const root = createRoot(container);
root.render(<App />);