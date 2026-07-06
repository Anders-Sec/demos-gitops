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
1. Build + push its two images to GHCR, tag e.g. `v1`.
2. `apps/<name>.yaml` (host `<name>.itpluto.dev`, `DATABASE_URL=…/<name>`).
3. Add `CREATE DATABASE <name>;` to `infra/postgres-initdb.yaml` **or**
   `kubectl exec -n demos postgres-0 -- createdb -U postgres <name>`.
4. Add `- name: <name>` to `appset.yaml`, then `kubectl apply -f appset.yaml`
   (the in-cluster ApplicationSet is static — a git push alone won't register it).
5. Enable the daily reset in `apps/<name>.yaml` with the app's own seed command:
   ```yaml
   reset:
     enabled: true
     schedule: "0 9 * * *"            # UTC unless timeZone is set
     seedCommand: "<how the app seeds>"  # e.g. python seed.py && python seed_demo.py
   ```

## Daily reset
Each demo has an optional CronJob (chart `reset.*`) that runs the backend image
on a schedule and rebuilds its data: **wipe schema → `alembic upgrade head` →
`seedCommand`**. The seed is idempotent, so a wipe is required for renamed/edited
data to reset. Force one now with:
```
kubectl create job -n demos --from=cronjob/<name>-reset <name>-reset-manual
```
