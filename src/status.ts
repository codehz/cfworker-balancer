import { classnames, html, on } from "@codehz/mutable-element";
import { create } from "css-in-bun" with { type: "macro" };

export function* Status() {
  const iframe = html`iframe[src=/statusz]`(
    classnames(styles.iframe),
    on("load", () => {
      const content = iframe.contentDocument!;
      iframe.style.height = content.documentElement.scrollHeight + "px";
    })
  ) as HTMLIFrameElement;
  yield html`button`(
    "刷新",
    on("click", () => iframe.contentWindow?.location.reload())
  );
  yield iframe;
}

const styles = create({
  iframe: {
    width: "100%",
    height: 600,
    marginTop: 10,
    transition: "height 0.1s ease",
  },
});
