const objectstorage = require("oci-objectstorage");
const getProvider = require("../config/oci");

const namespaceName = "axeteiujatw7";
const bucketName = "music-spotify-clone-bucket";
// Asegúrate de que esta región coincida con donde creaste el bucket (ej: 'us-ashburn-1')
const region = process.env.OCI_REGION || 'us-ashburn-1'; 

async function getClient() {
    const provider = await getProvider();
    return new objectstorage.ObjectStorageClient({
        authenticationDetailsProvider: provider
    });
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

    // URL Estándar de OCI Object Storage
    return `https://objectstorage.${region}.oraclecloud.com/n/${namespaceName}/b/${bucketName}/o/${encodeURIComponent(objectName)}`;
};

module.exports = { uploadFile };