// Zero Cloud Service — Azurite functional verification (Blob create/upload/read/list)
const { BlobServiceClient } = require("@azure/storage-blob");
const cs = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://host.docker.internal:10000/devstoreaccount1;";
(async () => {
  const svc = BlobServiceClient.fromConnectionString(cs);
  await svc.createContainer("zcs-verify");
  console.log("✅ container 'zcs-verify' created");
  const b = svc.getContainerClient("zcs-verify").getBlockBlobClient("hello.txt");
  await b.upload("Hello from Zero Cloud Service!", 31);
  console.log("✅ blob 'hello.txt' uploaded");
  const dl = await b.downloadToBuffer();
  console.log("✅ blob read back:", JSON.stringify(dl.toString()));
  const names = [];
  for await (const c of svc.listContainers()) names.push(c.name);
  console.log("✅ containers listed:", names.join(", "));
  process.exit(0);
})().catch(e => { console.error("❌ FAILED:", e.message); process.exit(1); });
