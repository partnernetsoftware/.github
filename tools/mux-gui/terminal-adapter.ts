import { Terminal } from 'https://esm.sh/@xterm/xterm@5.5.0';
import { FitAddon } from 'https://esm.sh/@xterm/addon-fit@0.10.0';

/** @typedef {{attach(el: HTMLElement): void, write(bytes: Uint8Array): void, onInput(cb: (data: string) => void): void, resize(cols: number, rows: number): void, dispose(): void}} TerminalAdapter */

export class XtermAdapter {
  constructor() {
    this.term = new Terminal({ cursorBlink: true, convertEol: true, scrollback: 10000 });
    this.fit = new FitAddon();
    this.decoder = new TextDecoder();
    this.attached = false;
  }

  attach(el) {
    if (!this.attached) {
      this.term.loadAddon(this.fit);
      this.term.open(el);
      this.attached = true;
    }
    this.fit.fit();
  }

  write(bytes) {
    this.term.write(this.decoder.decode(bytes, { stream: true }));
  }

  onInput(cb) {
    this.term.onData(cb);
  }

  resize(cols, rows) {
    this.term.resize(cols, rows);
  }

  dispose() {
    this.term.dispose();
  }
}
