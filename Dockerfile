# Etapa de construção do frontend
FROM node:20-alpine AS builder

WORKDIR /app

# Copia os arquivos de configuração primeiro
COPY package*.json ./

# Instala as dependências
RUN npm install

# Copia o restante do código fonte
COPY . .

# Build da aplicação React
RUN npm run build

# Etapa de produção
FROM node:20-alpine AS runner

WORKDIR /app

# Copia apenas os arquivos necessários
COPY package*.json ./

# Instala apenas dependências de produção
RUN npm install --production

# Copia os arquivos do servidor
COPY --from=builder /app/addon ./addon

# Copia os arquivos buildados do React
COPY --from=builder /app/dist ./dist

# Copia a pasta public com as imagens
COPY --from=builder /app/public ./public

# Exposição da porta
EXPOSE 1337

# --- Forçar Variáveis de Entorno ---
# Estas variáveis serão "queimadas" (baked in) na imagem do Docker.
ENV MONGODB_URI="mongodb+srv://USUARIO:PASSWORD@tu-cluster.mongodb.net/"
ENV FANART_API="FANART_KEY_REMOVED"
ENV TMDB_API="TMDB_KEY_REMOVED"
ENV HOST_NAME="4c78f89d232e-tmdb-addon-es.baby-beamup.club"
ENV TRAKT_CLIENT_ID="TRAKT_ID_REMOVED"
ENV TRAKT_CLIENT_SECRET="TRAKT_SECRET_REMOVED"

# ------------------------------------

# Comando para iniciar o servidor
ENTRYPOINT ["node", "addon/server.js"]
