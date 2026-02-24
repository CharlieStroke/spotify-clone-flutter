const common = require("oci-common");

async function getProvider() {
    return await common.auth.InstancePrincipalsAuthenticationDetailsProvider.builder().build();
}

module.exports = getProvider;