import { client } from "./apiclient/client.gen";

client.setConfig({
    baseUrl: "http://localhost:4010",
    throwOnError: true,
})
