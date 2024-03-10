import { classnames, html, mutate, on } from "@codehz/mutable-element";
import { create } from "css-in-bun" with { type: "macro" };

export function* Status() {
  const output = html`code`(load);
  yield html`button`(
    "刷新",
    on("click", () => mutate(output, load))
  );
  yield html`pre`(classnames(styles.Output), output);
}

const styles = create({
  Output: {
    marginTop: 10,
  },
});

async function load(this: HTMLElement) {
  const res = await fetch("/statusz");
  return await res.text();
}
