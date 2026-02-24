const objectstorage = require("oci-objectstorage");
const getProvider = require("../config/oci");

const namespaceName = "axeteiujatw7";
const bucketName = "music-spotify-clone-bucket";

async function getClient() {
    const provider = await getProvider();

    const client = new objectstorage.ObjectStorageClient({
        authenticationDetailsProvider: provider
    });

    return client;
    }

    const uploadFile = async (fileBuffer, objectName, contentType) => {
    const client = await getClient();

    const putObjectRequest = {
        namespaceName,
        bucketName,
        objectName,
        putObjectBody: fileBuffer,
        contentType
    };

    await client.putObject(putObjectRequest);

    return `https://objectstorage.${process.env.OCI_REGION}.oraclecloud.com/n/${namespaceName}/b/${bucketName}/o/${objectName}`;
    };

    module.exports = {
    uploadFile
};