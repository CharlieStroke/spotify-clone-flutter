const common = require("oci-common");

async function getProvider() {
    try {
        // Accedemos directamente a la clase desde el namespace de auth
        const provider = await new common.auth.InstancePrincipalsAuthenticationDetailsProviderBuilder().build();
        return provider;
    } catch (error) {
        console.error("Error construyendo el provider de OCI:", error);
        throw error;
    }
}

module.exports = getProvider;