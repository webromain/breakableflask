# ================================
# Étape 1 : Build (construction)
# ================================
FROM python:3.11-slim AS builder

# Variables d'environnement pour durcissement
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Répertoire de travail
WORKDIR /app

# Mise à jour et installation minimale des dépendances
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Copie du fichier de dépendances
COPY --chown=root:root requirements.txt .

# Installation des dépendances Python avec versions figées
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ================================
# Étape 2 : Runtime (exécution)
# ================================
FROM python:3.11-slim

# Variables d’environnement
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Crée un utilisateur non-root pour exécuter l’app
RUN useradd --create-home --shell /bin/bash appuser && \
    mkdir -p /app && chown -R appuser /app

# Copie les fichiers applicatifs depuis le builder
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --chown=appuser:appuser . .

USER appuser

# Exposition du port
EXPOSE 4000

# Vérifie la santé de l’application
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:4000/health || exit 1

# Lancement de l’application
CMD ["python", "main.py"]
