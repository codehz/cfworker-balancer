import {
  KeyedListRenderer,
  Reactor,
  classnames,
  html,
  list,
  mutate,
  on,
} from "@codehz/mutable-element";
import { create } from "css-in-bun" with { type: "macro" };
import { dispatchEvent } from "./extra";
import { produce } from "immer";

const format = new Intl.DateTimeFormat("zh-CN", {
  year: "numeric",
  month: "numeric",
  day: "numeric",
  hour: "numeric",
  minute: "numeric",
  second: "numeric",
  fractionalSecondDigits: 3,
});

export function StatusPage() {
  return html`div`(
    classnames(styles.Container),
    html`fieldset`(html`legend`("域名信息"), DomainInfo()),
    html`fieldset`(html`legend`("服务器信息"), ServerInfo())
  );
}

async function DomainInfo() {
  const dynamic = list(new KeyedListRenderer("email", renderPair));
  const selectedAccount = new Reactor<string | undefined>();
  await update();
  return html`div`(
    html`div`(
      classnames(styles.Toolbar),
      html`button`("刷新", on("click", update))
    ),
    html`div`(
      classnames("sunken-panel", styles.Table),
      html`table`(
        html`thead`(
          html`tr`(
            html`th`("Email"),
            html`th`("域名"),
            html`th`("用量"),
            html`th`("上次检查时间")
          )
        ),
        html`tbody`(dynamic)
      ),
      on<HTMLElement, CustomEvent<string>>("select", (e) => {
        const selected = e.detail;
        const final = produce(dynamic.data, (draft) => {
          for (const item of draft) {
            if (item.domain === selected) {
              item.selected = true;
            } else {
              delete item.selected;
            }
          }
        });
        dynamic.assign(final);
        selectedAccount.push(e.detail);
      })
    )
  );

  async function update() {
    const { data } = (await fetch("/api/get-domains.lua").then((x) =>
      x.json()
    )) as {
      data: {
        email: string;
        domain: string;
        usage?: number;
        updated_at?: number;
      }[];
    };
    dynamic.assign(data);
    selectedAccount.push(undefined);
  }
}

function renderPair(input: {
  email: string;
  domain: string;
  usage?: number;
  updated_at?: number;
  selected?: boolean;
}) {
  return html`tr`(
    classnames({ highlighted: !!input.selected }),
    html`td`(input.email),
    html`td`(input.domain),
    html`td`((input.usage ?? -1) + ""),
    html`td`(
      input.updated_at
        ? format.format(new Date(input.updated_at * 1000))
        : "<NULL>"
    ),
    on("pointerdown", dispatchEvent("select", input.domain))
  );
}

function* ServerInfo() {
  const output = html`code`(Statusz);
  yield html`button`(
    "刷新",
    on("click", () => mutate(output, Statusz))
  );
  yield html`pre`(classnames(styles.Output), output);
}

const styles = create({
  Container: {
    display: "flex",
    flexDirection: "column",
    gap: 10,
  },
  Output: {
    marginTop: 10,
  },
  Table: {
    width: "100%",
    overflow: "hidden",
  },
  Toolbar: { display: "flex", flexWrap: "wrap", gap: 10, marginBottom: 10 },
});

async function Statusz(this: HTMLElement) {
  const res = await fetch("/statusz");
  return await res.text();
}
