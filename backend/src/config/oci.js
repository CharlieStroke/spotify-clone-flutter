const common = require("oci-common");

const provider = new common.auth.InstancePrincipalsAuthenticationDetailsProvider();

module.exports = provider;