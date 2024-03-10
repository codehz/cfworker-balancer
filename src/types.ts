import type { StyleWithAtRules } from "css-in-bun";

declare module "css-in-bun/style" {
  interface CustomProperties  {
    "::-webkit-scrollbar": StyleWithAtRules;
  }
}