# Rust Todo App (WebAssembly)

Eine kleine To-Do-Anwendung, die vollständig in Rust geschrieben ist und mittels
[wasm-bindgen](https://github.com/rustwasm/wasm-bindgen) ins Web gebracht wird.

## Voraussetzungen

* [Rust](https://www.rust-lang.org/)
* [wasm-pack](https://rustwasm.github.io/wasm-pack/installer/)
* Ein einfacher HTTP-Server (z. B. `basic-http-server`, `python -m http.server`, ...)

## Projekt bauen

```bash
cd rust-todo-wasm
wasm-pack build --target web --out-dir static/pkg
```

Der Befehl erzeugt direkt im Verzeichnis `static/pkg/` das WebAssembly-Modul
inklusive JavaScript-Bridge. Das `static/`-Verzeichnis kann anschließend von
einem beliebigen Webserver ausgeliefert werden.

## App starten

```bash
cd rust-todo-wasm/static
python -m http.server 8080
```

Anschließend kann die Anwendung unter <http://localhost:8080> geöffnet werden.

## Funktionen

* Aufgaben hinzufügen
* Aufgaben abhaken
* Automatische Anzeige eines leeren Zustands
