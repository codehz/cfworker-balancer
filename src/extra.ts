import { style } from "@codehz/mutable-element";

export function aria(
  name: string,
  value: string
): (element: HTMLElement) => void {
  return (element) => {
    element.setAttribute("aria-" + name, value);
  };
}

export function dispatchEvent(
  name: string,
  detail: any = {}
): (this: HTMLElement) => void {
  return function () {
    this.dispatchEvent(new CustomEvent(name, { detail, bubbles: true }));
  };
}

export function viewTransitionName(name: string) {
  return style({
    viewTransitionName: name,
  });
}
