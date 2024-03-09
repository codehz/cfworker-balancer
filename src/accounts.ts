import {
  KeyedListRenderer,
  Reactor,
  attr,
  classnames,
  dataset,
  html,
  list,
  on,
} from "@codehz/mutable-element";
import { create } from "css-in-bun" with { type: "macro" };
import { produce } from "immer";
import { nanoid } from "nanoid";
import { dispatchEvent } from "./extra";

export function Accounts() {
  const id = nanoid();
  const dynamic = list(new KeyedListRenderer("email", renderPair));
  const selectedAccount = new Reactor<
    { email: string; key: string } | undefined
  >();
  update();
  return html`div`(
    classnames(styles.Accounts),
    html`div`(
      classnames("sunken-panel", styles.Table),
      html`table`(
        html`thead`(html`tr`(html`th`("Email"), html`th`("API Token"))),
        html`tbody`(dynamic)
      )
    ),
    html`div`(
      classnames(styles.Toolbar),
      html`button`("刷新", on("click", update)),
      html`button[disabled]`(
        "删除帐号",
        on("click", async function () {
          try {
            await fetch("/api/delete-account.lua", {
              method: "POST",
              body: new URLSearchParams({ email: this.dataset["email"]! }),
            });
            update();
          } catch (e) {
            alert(e + "");
          }
        }),
        async function* () {
          for await (const selected of selectedAccount) {
            yield attr({ disabled: !selected?.email });
            yield dataset({ email: selected?.email });
          }
        }
      )
    ),
    html`form`(
      html`fieldset`(
        html`legend`("添加/编辑帐号"),
        html`div`(
          classnames(styles.EditFieldSet),
          html`div.field-row-stacked`(
            html`label[for=${id}-email]`("Email"),
            html`input#${id}-email[name=email][type=email][required][spellcheck=false]`(
              async function* () {
                for await (const selected of selectedAccount) {
                  yield attr({ value: selected?.email ?? "" });
                }
              }
            )
          ),
          html`div.field-row-stacked`(
            html`label[for=${id}-key]`("API Token"),
            html`input#${id}-key[name=key][type=text][required][spellcheck=false]`(
              async function* () {
                for await (const selected of selectedAccount) {
                  yield attr({ value: selected?.key ?? "" });
                }
              }
            )
          )
        ),
        html`div`(
          classnames(styles.ButtonBar),
          html`button[type=reset]`("重置"),
          html`button[type=submit]`("保存")
        )
      ),
      on("submit", async function (e) {
        e.preventDefault();
        const data = new FormData(e.currentTarget as HTMLFormElement);
        try {
          await fetch("/api/put-account.lua", {
            method: "POST",
            body: new URLSearchParams(
              Object.fromEntries(data.entries()) as any
            ),
          });
          update();
        } catch (e) {
          alert(e + "");
        }
      })
    ),
    on<HTMLElement, CustomEvent<{ email: string; key: string }>>(
      "select",
      (e) => {
        const selected = e.detail.email;
        const final = produce(dynamic.data, (draft) => {
          for (const item of draft) {
            if (item.email === selected) {
              item.selected = true;
            } else {
              delete item.selected;
            }
          }
        });
        dynamic.assign(final);
        selectedAccount.push(e.detail);
      }
    )
  );
  async function update() {
    const { data } = (await fetch("/api/get-accounts.lua").then((x) =>
      x.json()
    )) as {
      data: { email: string; key: string }[];
    };
    dynamic.assign(data);
    selectedAccount.push(undefined);
  }
}

function renderPair(input: { email: string; key: string; selected?: true }) {
  return html`tr`(
    classnames({ highlighted: !!input.selected }),
    html`td`(input.email),
    html`td`(input.key),
    on("pointerdown", dispatchEvent("select", input))
  );
}

const styles = create({
  Accounts: {
    display: "flex",
    flexDirection: "column",
    gap: 10,
  },
  Table: {
    width: "100%",
    resize: "vertical",
    minHeight: 200,
    overflowY: "scroll",
  },
  Toolbar: { display: "flex", flexWrap: "wrap", gap: 10 },
  EditFieldSet: {
    "@media screen and (min-width: 400px)": {
      columnCount: 2,
      columnGap: 10,
    },
  },
  ButtonBar: {
    display: "flex",
    gap: 10,
    marginTop: 10,
    justifyContent: "flex-end",
  },
});
