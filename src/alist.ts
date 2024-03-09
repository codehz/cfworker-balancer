import { Reactor, attr, classnames, html, on } from "@codehz/mutable-element";
import { nanoid } from "nanoid";
import { create } from "css-in-bun" with { type: "macro" };

export function Alist() {
  const id = nanoid();
  const initial = new Reactor<{ address: string; token: string }>();
  return html`form`(
    html`div.field-row-stacked`(
      html`label[for=${id}-address]`("Alist 地址"),
      html`input#${id}-address[name=address][type=url][required][spellcheck=false]`(
        async function* () {
          for await (const { address } of initial) {
            yield attr({ value: address });
          }
        }
      )
    ),
    html`div.field-row-stacked`(
      html`label[for=${id}-token]`("Alist Token"),
      html`input#${id}-token[name=token][type=text][required][spellcheck=false]`(
        async function* () {
          for await (const { token } of initial) {
            yield attr({ value: token });
          }
        }
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
    }),
    async function () {
      const { data } = (await fetch("/api/get-alist-info.lua").then((x) =>
        x.json()
      )) as { data: { address: string; token: string } };
      initial.push(data);
    }
  );
}

const styles = create({
  SubmitButton: {
    marginTop: 10,
  },
});
