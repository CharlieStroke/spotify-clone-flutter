const common = require("oci-common");

async function getProvider() {
    try {
        // En las versiones recientes, el constructor se accede así:
        const provider = await new common.auth.InstancePrincipalsAuthenticationDetailsProviderBuilder().build();
        return provider;
    } catch (error) {
        console.error("Error crítico: No se pudo construir el OCI Provider.");
        console.error("Asegúrate de que la VM tenga un Dynamic Group y Policy asignados.");
        throw error;
    }
}

module.exports = getProvider;