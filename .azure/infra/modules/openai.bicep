// ---------------------------------------------------------------------------
// Common parameters for all modules
// ---------------------------------------------------------------------------

@minLength(1)
@maxLength(24)
@description('The name of your project')
param projectName string

@minLength(1)
@maxLength(10)
@description('The name of the environment')
param environment string

@description('The Azure region where all resources will be created')
param location string = resourceGroup().location

@description('Tags for the resources')
param tags object = {}

// ---------------------------------------------------------------------------
// Resource-specific parameters
// ---------------------------------------------------------------------------

@description('OpenAI options')
param options object = {}

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)
var modelsConfig = contains(options, 'models') ? options.models : []
var modelsNames = map(modelsConfig, c => c.name)

// Azure Cognitive Services OpenAI 
// https://docs.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts?tabs=bicep

resource openAi 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: 'oai-${projectName}-${environment}-${uid}'
  location: location
  tags: tags
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: uniqueString(uid, 'OpenAI')
    publicNetworkAccess: 'Enabled'
  }
}

resource models 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for model in modelsConfig: {
  parent: openAi
  name: model.name
  sku: {
    name: 'Standard'
    capacity: contains(model, 'capacity') ? model.capacity : 33
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: model.name
      version: model.version
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    raiPolicyName: 'Microsoft.Default'
  }
}]

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output openAiName string = openAi.name
output openAiEndpoint string = openAi.properties.endpoint
output openAiModelNames array = modelsNames
