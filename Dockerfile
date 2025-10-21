FROM python:3.13.8-slim-trixie

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
        curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m appuser

COPY --chown=appuser:appuser . /app

USER appuser

RUN pip install --no-cache-dir -r requirements.txt

# Exposition du port de service
EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:4000/ || exit 1

CMD ["python", "main.py"]
