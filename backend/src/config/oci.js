const common = require("oci-common");
const objectStorage = require("oci-objectstorage");

const provider = new common.ConfigFileAuthenticationDetailsProvider(
    "C:/Users/Carlos/.oci/config", // Path to your OCI config file
    "DEFAULT"
);

const client = new objectStorage.ObjectStorageClient({
    authenticationDetailsProvider: provider
});

module.exports = client;