# Aplicación de ejemplo con Flask

Esta aplicación de ejemplo muestra como integrar Sentry en una aplicación Flask.

## Logging con Sentry

1. Crear un nuevo proyecto en Sentry: seleccionar Flask y una frecuencia de alertamiento de cada 10 repeticiones en un minuto.

1. Configurar el SDK de acuerdo a la tecnología seleccionada. 

   En el caso de Python y Flask instalar los paquetes requeridos,
   
   ```bash
   pip install --upgrade 'sentry-sdk[flask]'
   ```

   y agregar las lineas de código en el proyecto.

   ```python
   import sentry_sdk
   from flask import Flask

   sentry_sdk.init(
      dsn="https://1234567890@jaha1234567890.ingest.us.sentry.io/0987654321",
      # Set traces_sample_rate to 1.0 to capture 100%
      # of transactions for tracing.
      traces_sample_rate=1.0,
      _experiments={
         # Set continuous_profiling_auto_start to True
         # to automatically start the profiler on when
         # possible.
         "continuous_profiling_auto_start": True,
      },
   )

   app = Flask(__name__)
   ```

   Este proyecto ya esta pre-configurado, por lo que solo debe cambiar el DSN de su aplicación en el archivo [backend.py](backend.py) por el de su proyecto en Sentry, p.e.
   
      ```python
      dsn="https://827643278e178362662.ingest.us.sentry.io/82783612878763",
      ```

## Como probar el servicio

Puede ir a http://localhost:5000 para acceder al API del backend. Existen varios endpoints que puede usar:

- (GET /)[http://localhost:5000/] es el home del servicio.
- (GET /api/data)[http://localhost:5000/api/data] retorna datos de ejemplo.
- (POST /api/data)[http://localhost:5000/api/data] procesa datos haciendo echo.
- (POST /api/error)[http://localhost:5000/api/error] genera un error de division de cero en el servicio.

Puede usar cURL o su cliente HTTP preferido para acceder a ellos. Por ejemplo, para generar un error en el servicio puede usar

```bash
curl -X POST http://localhost:5000/api/error -H 'Content-Type: application/json' -d '{"data":"1"}'
```

## Referencias

- [Flask](https://flask.palletsprojects.com/en/stable/)
- [Python Logging](https://docs.python.org/3/library/logging.html)
- [Sentry integration with Flask](https://docs.sentry.io/platforms/python/integrations/flask/)