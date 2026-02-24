const common = require("oci-common");
require('dotenv').config();

async function getProvider() {
    try {
        // Este es el método más estable del SDK
        const provider = new common.SimpleAuthenticationDetailsProvider(
            process.env.OCI_TENANCY_OCID,
            process.env.OCI_USER_OCID,
            process.env.OCI_FINGERPRINT,
            process.env.OCI_PRIVATE_KEY_PATH,
            null,
            common.Region.fromRegionId(process.env.region)
        );
        return provider;
    } catch (error) {
        console.error("Error fatal en el proveedor OCI:", error.message);
        throw error;
    }
}

module.exports = getProvider;