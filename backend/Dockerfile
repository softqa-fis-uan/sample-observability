# Use the official Python image
FROM python:3.11.10

# Set the working directory in the container
WORKDIR /backend

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app files into the container
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
# CMD ["python", "backend.py"]
# run with uwsgi
CMD ["uwsgi", "--http", "0.0.0.0:5000", "--wsgi-file", "backend.py", "--callable", "app"] 
# run with gunicorn
# CMD ["gunicorn", "-b", "0.0.0.0:5000", "backend:app"] 