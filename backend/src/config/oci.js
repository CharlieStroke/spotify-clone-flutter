const identity = require("oci-identity");

const provider = new identity.InstancePrincipalsAuthenticationDetailsProvider();

module.exports = provider;