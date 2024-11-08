# Aplicación de ejemplo con React

Esta aplicación de ejemplo muestra como integrar Sentry en una aplicación React.

Basado en https://github.com/getsentry/frontend-tutorial.

## Logging con Sentry

1. Crear un nuevo proyecto en Sentry: seleccionar React y una frecuencia de alertamiento de cada 10 repeticiones en un minuto.

1. Configurar el SDK de acuerdo a la tecnología seleccionada. 

   Para React, instalar el SDK usando

   ```bash
   npm install @sentry/react --save
   ```

   y configurar la aplicación de acuerdo a la documentación de Sentry. Este proyecto ya esta pre-configurado, por lo que solo debe cambiar el DSN de su aplicación en el archivo [index.js](src/index.js) por el de su proyecto en Sentry, p.e.

   ```javascript
   dsn: "https://827643278e178362662.ingest.us.sentry.io/82783612878763",
   ```

## Como probar el servicio

Puede ir a http://localhost:3000 para acceder al frontend web. El panel derecho tiene una acción que permite generar un error en la aplicación.

## Referencias

- [React](https://react.dev/reference/react)
- [Sentry for React](https://docs.sentry.io/platforms/javascript/guides/react/)
