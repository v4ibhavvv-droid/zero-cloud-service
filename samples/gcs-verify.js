// Zero Cloud Service — fake-gcs functional verification
const { Storage } = require("@google-cloud/storage");
const storage = new Storage({ projectId: "floci-local", apiEndpoint: "http://host.docker.internal:4443" });
(async () => {
  const [bucket] = await storage.createBucket("zcs-verify-bucket");
  console.log("✅ bucket created:", bucket.name);
  await bucket.file("hello.txt").save("Hello from Zero Cloud Service!");
  console.log("✅ object uploaded: hello.txt");
  const [content] = await bucket.file("hello.txt").download();
  console.log("✅ object read back:", JSON.stringify(content.toString()));
  const [buckets] = await storage.getBuckets();
  console.log("✅ buckets listed:", buckets.map(b => b.name).join(", "));
  process.exit(0);
})().catch(e => { console.error("❌ FAILED:", e.message); try { console.error("URL:", e.response?.request?.url || e.response?.request?.href || "n/a"); console.error("BODY:", JSON.stringify(e.response?.data || e.errors || "").slice(0, 400)); } catch (_) {} process.exit(1); });
