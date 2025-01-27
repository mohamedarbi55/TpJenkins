# Utilisation de l'image Python 3.13.0 alpine
FROM python:3.13.0-alpine3.20

# Définition du répertoire de travail
WORKDIR /app

# Copier le script sum.py dans le conteneur
COPY sum.py /app/

# Définir la commande par défaut du conteneur
CMD ["tail", "-f", "/dev/null"]
