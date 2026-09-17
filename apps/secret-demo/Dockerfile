FROM python:3.13-alpine

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt \
    && addgroup -S  -g 10001 app \
    && adduser -S -D -H -u 10001 -G app app

COPY --chown=10001:10001 app.py .

USER 10001:10001

EXPOSE 8080

ENV SECRET_FILE=/mnt/secrets-store/demo-api-key

CMD ["gunicorn", \
     "--bind", "0.0.0.0:8080", \
     "--workers", "2", \
     "--access-logfile", "-", \
     "app:app"]
