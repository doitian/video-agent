import { test } from "node:test";
import assert from "node:assert/strict";
import { localTtsGenerate } from "./tts-local-provider.mjs";

test("win32: spawns bunx hyperframes tts", async () => {
  const captured = [];
  const fakeExec = (cmd, args, opts) => {
    captured.push({ cmd, args, opts });
  };

  await localTtsGenerate("hello there", { voice: "am_michael" }, "win32", fakeExec, {}, () => false);

  assert.equal(captured.length, 1);
  assert.equal(captured[0].cmd, "bunx");
  assert.deepEqual(captured[0].args.slice(0, 3), ["hyperframes", "tts", "hello there"]);
  assert.ok(captured[0].args.includes("--voice"));
  assert.deepEqual(captured[0].opts.stdio, ["ignore", "pipe", "pipe"]);
});

test("non-win32: spawns bunx hyperframes tts", async () => {
  const captured = [];
  const fakeExec = (cmd, args) => captured.push({ cmd, args });

  await localTtsGenerate("hola", { lang: "es" }, "darwin", fakeExec, {}, () => false);

  assert.equal(captured.length, 1);
  assert.equal(captured[0].cmd, "bunx");
  assert.deepEqual(captured[0].args.slice(0, 3), ["hyperframes", "tts", "hola"]);
  assert.ok(captured[0].args.includes("--lang"));
});
