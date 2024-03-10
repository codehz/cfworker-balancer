import {
  KeyedListRenderer,
  empty,
  html,
  list,
  mutate,
  on,
  type MutateAction,
} from "@codehz/mutable-element";
import { nanoid } from "nanoid";
import { aria, dispatchEvent, viewTransitionName } from "./extra";
import { safeViewTransition } from "safe-view-transition";

export function Tabs(
  ...content: {
    title: string;
    content: MutateAction<HTMLElement>;
  }[]
) {
  const id = nanoid();
  const body = html`div.window-body`(
    viewTransitionName(`${id}-content-0`),
    content[0].content
  );
  const initial = getList(0);
  const tabs = list(
    new KeyedListRenderer(
      "title",
      (tab: (typeof initial)[number]) =>
        html`li[role=tab]`(
          viewTransitionName(`${id}-tab-${tab.index}`),
          aria("selected", tab.selected ? "true" : ""),
          on("click", dispatchEvent("tabchange", { index: tab.index })),
          html`a[href=javascript:void(0)]`(tab.title)
        ),
      (range, { selected }) => {
        mutate(
          range.firstChild! as HTMLElement,
          aria("selected", selected ? "true" : "")
        );
      }
    ),
    initial
  );
  return [
    html`menu[role=tablist]`(
      tabs,
      on<Node, CustomEvent<{ index: number }>>("tabchange", (e) => {
        const index = e.detail.index;
        safeViewTransition(async () => {
          await mutate(body, [
            empty(),
            viewTransitionName(`${id}-content-${index}`),
            content[index].content,
          ]);
          tabs.assign(getList(index));
        });
      })
    ),
    html`div.window[role=tabpanel]`(viewTransitionName(`${id}-content`), body),
  ];
  function getList(selected: number) {
    return content.map(
      (props, index) =>
        ({
          ...props,
          index,
          selected: index === selected,
        }) as const
    );
  }
}
