const common = require("oci-identity");

const provider = new common.InstancePrincipalsAuthenticationDetailsProvider();

module.exports = provider;