# Update-Plan (Schritt für Schritt, 1 Dependency = 1 Commit)

Stand: 2026-01-02

Grundlage: Ausgabe von `bundle outdated --only-explicit` (im Docker-Container) und die zuletzt priorisierte Reihenfolge.

Ziel
- Jede Abhängigkeit einzeln aktualisieren.
- Nach jedem Update: Testsuite laufen lassen.
- Nur wenn Tests grün sind: nächster Commit.

Voraussetzungen
- Lokales Docker-Setup läuft (siehe README).
- Empfohlen: sauberes Working Tree vor jedem Schritt.

Allgemeines Vorgehen pro Schritt
1. Update genau einer Abhängigkeit (Gemfile/Gemfile.lock).
2. Container neu bauen (damit native Gems sauber neu installiert werden): `docker compose build web`
3. Testsuite laufen lassen: `docker compose run --rm -e RAILS_ENV=test --entrypoint bundle web exec rspec`
4. Commit erstellen (nur die Dateien aus Schritt 1; i.d.R. `Gemfile` und/oder `Gemfile.lock`).

Hinweis zum Test-Command
- Der Testlauf nutzt absichtlich `--entrypoint bundle`, damit der App-Entrypoint (DB-Setup etc.) die Tests nicht „überlagert“.

---

## 0) Vorbereitung (kein Dependency-Commit)

Einmalig vor dem ersten Update:
- `docker compose up -d --build`
- Optional: Baseline-Tests laufen lassen:
  - `docker compose run --rm -e RAILS_ENV=test --entrypoint bundle web exec rspec`

---

## 1) loofah (2.24.1 → 2.25.0)

Status
- Erledigt

Änderung
- `bundle update loofah`

Befehle
- `docker compose run --rm --entrypoint bundle web update loofah`
- `docker compose build web`
- `docker compose run --rm --entrypoint bundle web exec rspec`

Commit
- Message-Vorschlag: `chore(deps): update loofah`
- Dateien: i.d.R. nur `Gemfile.lock`

---

## 2) mini_racer (0.19.1 → 0.19.2)

Status
- Erledigt

Änderung
- `bundle update mini_racer`

Befehle
- `docker compose run --rm --entrypoint bundle web update mini_racer`
- `docker compose build web`
- `docker compose run --rm --entrypoint bundle web exec rspec`

Commit
- `chore(deps): update mini_racer`

---

## 3) ffi (1.15.5 → 1.17.3)

Status
- Erledigt

Änderung
- Gemfile anpassen: `gem 'ffi', '~> 1.17'`
- Dann: `bundle update ffi`

Befehle
- Edit: `Gemfile` (Constraint)
- `docker compose run --rm --entrypoint bundle web update ffi`
- `docker compose build web`
- `docker compose run --rm --entrypoint bundle web exec rspec`

Commit
- `chore(deps): update ffi`
- Dateien: `Gemfile`, `Gemfile.lock`

---

## 4) puma (6.6.1 → 7.1.0) (Major)

Status
- Erledigt

Änderung
- Gemfile anpassen: `gem 'puma', '~> 7.1'`
- Dann: `bundle update puma`

Befehle
- Edit: `Gemfile` (Constraint)
- `docker compose run --rm --entrypoint bundle web update puma`
- `docker compose build web`
- `docker compose run --rm --entrypoint bundle web exec rspec`

Commit
- `chore(deps): update puma`

---

## 5) bootsnap (1.19.0 → 1.20.1)

Status
- Erledigt

Änderung
- `bundle update bootsnap`

Befehle
- `docker compose run --rm --entrypoint bundle web update bootsnap`
- `docker compose build web`
- `docker compose run --rm --entrypoint bundle web exec rspec`

Commit
- `chore(deps): update bootsnap`

---

## 6) bigdecimal (3.3.1 → 4.0.1) (Major)

Status
- Vorerst übersprungen (Updates-only / keine Downgrades): ein Update auf bigdecimal 4.x kollidiert aktuell mit transitativen Constraints im Reporting-Stack. Ein erzwungenes `bigdecimal (~> 4.0)` würde u.a. Downgrades wie `ttfunk 1.8.0 → 1.7.0`, `prawn 2.5.x → 2.4.0` und `pdf-core 0.10.0 → 0.9.0` nach sich ziehen.

Unblock-Versuch (Updates-only)
- Konservative Updates für `ttfunk`, `prawn`, `pdf-core` und `thinreports` brachten keine Versionsänderung (Bundler: "version stayed the same"). Damit bleibt `bigdecimal` 4.x ohne Downgrades aktuell nicht erreichbar.

Änderung
- `bundle update bigdecimal`

Befehle
- `docker compose run --rm --entrypoint bundle web update bigdecimal`
- `docker compose build web`
- `docker compose run --rm --entrypoint bundle web exec rspec`

Commit
- `chore(deps): update bigdecimal`

---

## 7) test-unit (3.7.3 → 3.7.7)

Status
- Erledigt

Änderung
- `bundle update test-unit`

Befehle
- `docker compose run --rm --entrypoint bundle web update test-unit`
- `docker compose build web`
- `docker compose run --rm --entrypoint bundle web exec rspec`

Commit
- `chore(deps): update test-unit`

---

## 8) sorbet (0.6.12846 → 0.6.12872)

Status
- Erledigt (als sorbet-* Stack). Hinweis: Das initiale „ändert sich nicht“ lag an Bundler-Konfiguration im Container (`without` schließt `development` aus). Mit neutraler Bundler-App-Config ließ sich der Stack sauber aktualisieren.

Änderung
- `bundle update sorbet sorbet-runtime sorbet-static sorbet-static-and-runtime`

Befehle
- `docker compose run --rm -e BUNDLE_APP_CONFIG=/tmp/bundle-config --entrypoint bundle web update sorbet sorbet-runtime sorbet-static sorbet-static-and-runtime`
- `docker compose build web`
- `docker compose run --rm --entrypoint bundle web exec rspec`

Commit
- `chore(deps): update sorbet`

---

## 9) sorbet-runtime (0.6.12846 → 0.6.12872)

Status
- Erledigt (zusammen mit Schritt 8 / sorbet-* Stack).

Änderung
- Keine separate Änderung nötig (wird im sorbet-* Stack mitgezogen).

Befehle
- Siehe Schritt 8.

Commit
- Siehe Schritt 8.

---

## 10) spring (2.1.1 → 4.4.0) (Major, dev)

Status
- Erledigt

Änderung
- Gemfile anpassen: `gem 'spring', '~> 4.4'`
- Dann: `bundle update spring`

Befehle
- Edit: `Gemfile` (Constraint)
- `docker compose run --rm --entrypoint bundle web update spring`
- `docker compose build web`
- `docker compose run --rm --entrypoint bundle web exec rspec`

Commit
- `chore(deps): update spring`

---

## 11) rspec-rails (6.1.5 → 8.0.2) (Major, dev/test)

Status
- Erledigt

Änderung
- Gemfile anpassen: `gem 'rspec-rails', '~> 8.0'`
- Dann: `bundle update rspec-rails`

Befehle
- Edit: `Gemfile` (Constraint)
- `docker compose run --rm --entrypoint bundle web update rspec-rails`
- `docker compose build web`
- `docker compose run --rm --entrypoint bundle web exec rspec`

Commit
- `chore(deps): update rspec-rails`

---

## Troubleshooting (kurz)

- Wenn `bundle update ...` sehr lange braucht: einmal `docker compose run --rm --entrypoint bundle web config set without 'development'` ist NICHT empfohlen; lieber beim aktuellen Setup bleiben.
- Wenn Bundler meldet, dass Gems in der Gruppe `development` nicht aktualisiert wurden: einmalig für den Update-Command eine neutrale Bundler-App-Config nutzen, z.B. `docker compose run --rm -e BUNDLE_APP_CONFIG=/tmp/bundle-config --entrypoint bundle web update <gem>`.
- Wenn native Gems (z.B. `ffi`, `mini_racer`) Probleme machen: `docker compose build --no-cache web` für genau diesen Schritt.
- Wenn Tests DB benötigen: vor `rspec` sicherstellen, dass `db` läuft: `docker compose up -d db`.
