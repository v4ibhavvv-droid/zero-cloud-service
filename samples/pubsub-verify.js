// Zero Cloud Service — Pub/Sub emulator functional verification
const { PubSub } = require("@google-cloud/pubsub");
(async () => {
  const pubsub = new PubSub({ projectId: "floci-local" });
  const topicName = "zcs-test-topic";
  const [topic] = await pubsub.createTopic(topicName);
  console.log("✅ topic created:", topic.name);
  const [sub] = await pubsub.topic(topicName).createSubscription("zcs-test-sub");
  console.log("✅ subscription created:", sub.name);
  const msgId = await topic.publishMessage({ data: Buffer.from("Hello from Zero Cloud Service!") });
  console.log("✅ message published:", msgId);
  let received = 0;
  const sub2 = pubsub.subscription("zcs-test-sub");
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => resolve(), 8000);
    sub2.on("message", m => { received++; m.ack(); clearTimeout(timer); resolve(); });
    sub2.on("error", reject);
  });
  console.log("✅ message received:", received, "msg(s)");
  process.exit(received > 0 ? 0 : 1);
})().catch(e => { console.error("❌ FAILED:", e.message); process.exit(1); });
