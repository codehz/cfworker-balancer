import { html } from "@codehz/mutable-element";
import { nanoid } from "nanoid";

export function UpdateSecret() {
  const id = nanoid();
  return html`form[action=/update-secret.lua]`(
    html`div.field-row-stacked`(
      html`label[for=${id}]`("新管理员密码"),
      html`input#${id}[name=secret][type=password][required]`(),
      html`button[type=submit]`("更新密码")
    )
  );
}
