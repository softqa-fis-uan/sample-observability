const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const { sentryWebpackPlugin } = require("@sentry/webpack-plugin");

module.exports = {
  entry: "./src/index.js",
  output: {
    filename: "main.js",
    path: path.resolve(__dirname, "build"),
  },
    devtool: "source-map",
  plugins: [
    new HtmlWebpackPlugin({
      template: path.join(__dirname, "public", "index.html"),
    }),
    sentryWebpackPlugin({
      // TODO: Replace with your own Sentry ORG and PROJECT
      org: "uan-aw",
      project: "javascript-react",

      // Auth tokens can be obtained by creating an internal integration
      // at https://<organization_id>.sentry.io/settings/developer-settings/
      // and need "Release: Admin" and "Organization: Read & Write" permissions
      authToken: process.env.SENTRY_AUTH_TOKEN,

      // Enable automatically creating releases and associating commits
      release: {
        create: true,
        setCommits: {
          auto: true,
        },
      },
    }),
  ],
  devServer: {
    static: {
      directory: path.join(__dirname, "build"),
    },
    port: 3000,
    // Proxy local /loki requests to the Loki instance to avoid CORS
    // when running the dev server on the host. Docker-compose exposes
    // Loki on localhost:3100, so we forward requests there.
    proxy: {
      '/loki': {
        target: 'http://loki:3100',
        changeOrigin: true,
        secure: false,
        logLevel: 'warn'
      }
    },
  },
  module: {
    // exclude node_modules
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: ["babel-loader"],
      },
      // "url" loader works like "file" loader except that it embeds assets
      // smaller than specified limit in bytes as data URLs to avoid requests.
      // A missing `test` is equivalent to a match.
      {
        test: [/\.bmp$/, /\.gif$/, /\.jpe?g$/, /\.png$/],
        type: "asset",
        parser: {
          dataUrlCondition: {
            // maxSize: 10000,
          },
        },
      },
      {
        test: /\.(css)$/,
        use: ["style-loader", "css-loader"],
      },
    ],
  },
  // pass all js files through Babel
  resolve: {
    extensions: ["*", ".js", ".jsx"],
  },
};
