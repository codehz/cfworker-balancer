import { attr, classnames, html, on } from "@codehz/mutable-element";
import { create } from "css-in-bun" with { type: "macro" };
import { nanoid } from "nanoid";

export async function Alist() {
  const id = nanoid();
  const {
    data: { address, token },
  } = (await fetch("/api/get-alist-info.lua").then((x) => x.json())) as {
    data: { address: string; token: string };
  };
  return html`form`(
    html`div.field-row-stacked`(
      html`label[for=${id}-address]`("Alist 地址"),
      html`input#${id}-address[name=address][type=url][required][spellcheck=false]`(
        attr({ value: address })
      )
    ),
    html`div.field-row-stacked`(
      html`label[for=${id}-token]`("Alist Token"),
      html`input#${id}-token[name=token][type=text][required][spellcheck=false]`(
        attr({ value: token })
      )
    ),
    html`button[type=submit]`(classnames(styles.SubmitButton), "保存"),
    on("submit", (e) => {
      e.preventDefault();
      const data = new FormData(e.currentTarget as HTMLFormElement);
      try {
        fetch("/api/update-alist.lua", {
          method: "POST",
          body: new URLSearchParams(Object.fromEntries(data.entries()) as any),
        });
      } catch (e) {
        alert(e + "");
      }
    })
  );
}

const styles = create({
  SubmitButton: {
    marginTop: 10,
  },
});
