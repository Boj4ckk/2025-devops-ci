# Stage 1: Builder
FROM node:20-alpine AS builder

RUN adduser --system --uid 1001 appuser
RUN npm install -g pnpm

WORKDIR /app


COPY --chown=appuser package.json pnpm-lock.yaml* ./
RUN pnpm install


COPY --chown=appuser . .
RUN pnpm run build

# Stage 2: Runtime
FROM node:20-alpine AS runtime


RUN adduser --system --uid 1001 appuser
RUN npm install -g pnpm

WORKDIR /app


COPY --chown=appuser package.json pnpm-lock.yaml* ./
RUN pnpm install --prod --frozen-lockfile


COPY --from=builder --chown=appuser /app/.output ./.output

USER appuser
EXPOSE 3000
CMD ["sh","-c","pnpm db:push && pnpm dev --host 0.0.0.0" ]