const common = require("oci-common");
const fs = require("fs");
require('dotenv').config();

async function getProvider() {
    try {
        // Leemos el archivo físico usando la ruta del .env
        const privateKey = fs.readFileSync(process.env.OCI_PRIVATE_KEY_PATH, 'utf8');

        return new common.SimpleAuthenticationDetailsProvider(
            process.env.OCI_TENANCY_OCID,
            process.env.OCI_USER_OCID,
            process.env.OCI_FINGERPRINT,
            privateKey, // Pasamos el contenido de la llave, no la ruta
            null,
            common.Region.fromRegionId(process.env.OCI_REGION)
        );
    } catch (error) {
        console.error("Error al configurar OCI Provider:", error.message);
        throw error;
    }
}

module.exports = getProvider;