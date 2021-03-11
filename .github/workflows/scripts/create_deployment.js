//
// Creates a Deployment using the provided data
//

module.exports = async (payload) => {

  const environment = validateParameter(payload, 'environment'),
    context = validateParameter(payload, 'context'),
    github = validateParameter(payload, 'github'),
    containerRegistry = validateParameter(payload, 'containerRegistry'),
    appContainerImage = validateParameter(payload, 'appContainerImage'),
    appContainerVersion = validateParameter(payload, 'appContainerVersion'),
    sha = validateParameter(payload, 'sha'),
    head = validateParameter(payload, 'head');

  deploymentEnvironment = environment;
  transient_environment = false;
  production_environment = false;
  switch (environment) {
    case 'dev':
      deploymentEnvironment = `dev-${head}`;
      transient_environment = true;
      production_environment = false;
      break;
    case 'qa':
      transient_environment = false;
      production_environment = false;
      break;
    case 'prod':
      transient_environment = false;
      production_environment = true;
      break;
    default:
      throw new Error(`Environment '${environment}' is not supported.`);
  }

  // A deployment payload for passing information of the components for the deployment
  const deploymentPayload = {
    container_registry: containerRegistry,
    app_container: {
      image: appContainerImage,
      version: appContainerVersion,
    },
    sha: sha,
    environment: deploymentEnvironment,
    ref: context.ref,
  };

  console.log(JSON.stringify(deploymentPayload, null, 2));

  await github.repos.createDeployment({
    ...context.repo,
    ref: head,
    auto_merge: false,
    required_contexts: [],
    payload: JSON.stringify(deploymentPayload),
    environment: deploymentEnvironment,
    description: `Deploy to ${environment}`,
    transient_environment: transient_environment,
    production_environment: production_environment,
    mediaType: { previews: ["flash", "ant-man"] }
  });
}

function validateParameter(payload, name) {
  const value = payload[name];

  if (!value) {
    throw new Error(`Required Parameter '${name}' was not provided.`);
  }
  return value;
}