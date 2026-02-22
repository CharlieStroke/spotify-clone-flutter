const client = require('../config/oci');
const common = require('oci-common');

const namespaceName = 'axeteiujatw7';
const bucketName = 'music-spotify-clone-bucket';

const uploadSong = async (fileBuffer, objectName, contentType) => {
    const putObjectRequest = {
        namespaceName: namespaceName,
        bucketName: bucketName,
        objectName: objectName,
        putObjectBody: fileBuffer,
        contentType: contentType
    };

    await client.putObject(putObjectRequest);
    return `https://objectstorage.${process.env.OCI_REGION}.oraclecloud.com/n/${namespaceName}/b/${bucketName}/o/${objectName}`;

};

const uploadCoverImage = async (fileBuffer, objectName, contentType) => {
    const putObjectRequest = {
        namespaceName: namespaceName,
        bucketName: bucketName,
        objectName: objectName,
        putObjectBody: fileBuffer,
        contentType: contentType
    };

    await client.putObject(putObjectRequest);
    return `https://objectstorage.${process.env.OCI_REGION}.oraclecloud.com/n/${namespaceName}/b/${bucketName}/o/${objectName}`;
}

module.exports = {
    uploadSong,
    uploadCoverImage
};