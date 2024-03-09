import { getGeneratedCss } from "css-in-bun/build";
export async function build() {
  const result = await Bun.build({
    entrypoints: ["src/index.ts"],
    outdir: "srv",
    format: "esm",
    target: "browser",
    minify: true,
    sourcemap: "external",
    // splitting: true,
  });
  if (!result.success) {
    console.log(...result.logs)
    return;
  }
  await Bun.write("srv/generated.css", getGeneratedCss());
  console.log("built", new Date());
}

if (import.meta.main) {
  await build();
}
