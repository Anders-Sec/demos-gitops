# demos-gitops

GitOps for the public demo apps (each React + FastAPI + Postgres) on `*.itpluto.dev`.
Low-management by design: no CI/CD, no Vault/ESO — build images once, pin a tag, plain config.

## Layout
- `charts/webapp/` — shared generic chart (frontend + backend, same-origin `/api` ingress).
- `infra/` — `demos` namespace, one shared Postgres (a database per app), wildcard `*.itpluto.dev` cert.
- `apps/<name>.yaml` — per-app values (host, images, `DATABASE_URL`).
- `appset.yaml` — ApplicationSet: one ArgoCD Application per app in the list.
- `infra-app.yaml` — ArgoCD Application for `infra/`.

## Bootstrap (once)
```
kubectl apply -f infra-app.yaml -f appset.yaml   # into the existing ArgoCD
```

## Add a demo
1. Build + push its two images to GHCR (public), tag e.g. `v1`.
2. `apps/<name>.yaml` (host `<name>.itpluto.dev`, `DATABASE_URL=…/<name>`).
3. Add `CREATE DATABASE <name>;` to `infra/postgres-initdb.yaml` **or**
   `kubectl exec -n demos postgres-0 -- createdb -U postgres <name>`.
4. Add `- name: <name>` to `appset.yaml`.
