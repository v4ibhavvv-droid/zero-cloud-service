// Zero Cloud Service — Firestore emulator functional verification
const { Firestore } = require("@google-cloud/firestore");
process.env.FIRESTORE_EMULATOR_HOST = "host.docker.internal:8086";
const db = new Firestore({ projectId: "floci-local" });
(async () => {
  const ref = await db.collection("zcs-test").add({ message: "Hello from Zero Cloud Service!", ts: new Date() });
  console.log("✅ doc created:", ref.id);
  const snap = await ref.get();
  console.log("✅ doc read back:", JSON.stringify(snap.data().message));
  const q = await db.collection("zcs-test").where("message", "==", "Hello from Zero Cloud Service!").get();
  console.log("✅ query matched:", q.size, "doc(s)");
  await ref.delete();
  console.log("✅ doc deleted");
  process.exit(0);
})().catch(e => { console.error("❌ FAILED:", e.message); process.exit(1); });
