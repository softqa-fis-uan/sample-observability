# Observabilidad

Este proyecto incluye ejemplos de observabilidad en una aplicación usando Sentry.

- Trazas
- Logs

## Como usar este proyecto

Este proyecto usa contenedores por lo que necesitará tener instalado Docker. **Puede abrir el proyecto usando `dev-containers` en Visual Code**, o seguir los pasos a continuación para ejecutar la aplicación.

1. Genere las imágenes de los contenedores con compose usando el comando

   ```bash
   docker compose build
   ```

1. Inicie la aplicación usando

   ```bash
   docker compose up -d
   ```

1. Cuando termine puede detener los servicios usando

   ```bash
   docker compose down
   ```

La aplicación esta compuesta por dos servicios: 

- Un [backend](backend) construido en Python con la librería Flask que expone un API REST.
- Un [frontend](frontend) web construido en Javascript con el framework React.

Debe modificar estos proyectos antes de iniciar los servicios usando sus propios parámetros de configuración para su cuenta de Sentry.
