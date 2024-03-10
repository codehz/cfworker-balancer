import { classnames, html, mount, on } from "@codehz/mutable-element";
import { create } from "css-in-bun" with { type: "macro" };
import { Accounts } from "./accounts";
import { Alist } from "./alist";
import { Help } from "./help";
import { Status } from "./status";
import { Tabs } from "./tab";
import { UpdateSecret } from "./update-secret";

document.fonts.load('12px "Fusion Pixel"').then(() => {
  mount(
    document.body,
    html`header.title-bar`(
      html`div.title-bar-text`("Cloudflare Worker Balancer"),
      html`div.title-bar-controls`(
        html`button[aria-label=Close]`(on("click", () => window.close()))
      )
    ),
    html`div`(
      classnames(styles.Container),
      html`main`(
        classnames("window-body", styles.main),
        Tabs(
          {
            title: "帮助",
            content: Help,
          },
          {
            title: "更新管理员密码",
            content: UpdateSecret,
          },
          {
            title: "Alist 配置",
            content: Alist,
          },
          {
            title: "Cloudflare 账号管理",
            content: Accounts,
          },
          { title: "状态", content: Status }
        )
      )
    )
  );
});

const styles = create({
  Container: {
    flex: 1,
    minHeight: 0,
    overflow: "auto",
  },
  main: {
    backgroundColor: "#c0c0c0",
    display: "flex",
    flexDirection: "column",
  },
});
