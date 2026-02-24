const common = require("oci-common");
require('dotenv').config();

async function getProvider() {
    try {
        // Creamos el proveedor usando los datos de la API Key
        const provider = new common.SimpleAuthenticationDetailsProvider(
            process.env.OCI_TENANCY_OCID,
            process.env.OCI_USER_OCID,
            process.env.OCI_FINGERPRINT,
            process.env.OCI_PRIVATE_KEY_PATH,
            null, // No usamos passphrase
            common.Region.fromRegionId(process.env.OCI_REGION)
        );
        return provider;
    } catch (error) {
        console.error("Error al configurar el proveedor con API Key:", error.message);
        throw error;
    }
}

module.exports = getProvider;