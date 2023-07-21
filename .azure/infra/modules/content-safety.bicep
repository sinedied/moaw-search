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

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

// Azure Cognitive Services Content Safety 
// https://docs.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts?tabs=bicep

resource contentSafety 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: 'acs-${projectName}-${environment}-${uid}'
  location: location
  tags: tags
  sku: {
    name: 'S0'
  }
  kind: 'ContentSafety'
  properties: {
    customSubDomainName: uniqueString(uid, 'ContentSafety')
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output contentSafetyName string = contentSafety.name
output contentSafetyEndpoint string = contentSafety.properties.endpoint
