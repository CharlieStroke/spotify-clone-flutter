const common = require("oci-common");

async function getProvider() {
    try {
        // Esta ruta suele ser la más estable en versiones recientes
        const provider = new common.auth.InstancePrincipalsAuthenticationDetailsProviderBuilder().build();
        return provider;
    } catch (error) {
        console.error("Error al construir provider:", error.message);
        throw error;
    }
}

module.exports = getProvider;