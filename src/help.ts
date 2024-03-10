import { html } from "@codehz/mutable-element";
import { create } from "css-in-bun" with { type: "macro" };
import { micromark } from "micromark";

export async function Help() {
  const res = await fetch("/help.txt");
  const help = await res.text();
  const source = micromark(help);
  return html`div.${styles.Container}`(function () {
    this.innerHTML = source;
  });
}

const styles = create({
  Container: {
    whiteSpace: "pre-wrap",
  },
});
