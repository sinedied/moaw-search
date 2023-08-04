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

@description('Storage options')
param options object = {}

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

// Allowed: 'Standard_LRS', 'Standard_GRS', 'Standard_GZRS', 'Standard_RAGRS', 'Standard_RAGZRS', 'Standard_ZRS', 'Premium_LRS', 'Premium_ZRS'
var tier = contains(options, 'tier') ? options.tier : 'Standard_LRS'
// Allowed: 'Hot', 'Cool', 'Premium'
var accessTier = contains(options, 'accessTier') ? options.accessTier : 'Hot'
var allowBlobPublicAccess = contains(options, 'allowBlobPublicAccess') ? options.allowBlobPublicAccess : false
var supportsHttpsTrafficOnly = contains(options, 'supportsHttpsTrafficOnly') ? options.supportsHttpsTrafficOnly : true
var fileShares = contains(options, 'fileShares') ? options.fileShares : []

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

// Azure Storage
// https://docs.microsoft.com/azure/templates/microsoft.storage/storageaccounts?tabs=bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'storage${uid}'
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: tier
  }
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    minimumTlsVersion: 'TLS1_2'
  }
}

resource storageFileShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = [for name in fileShares: {
  #disable-next-line use-parent-property
  name: '${storageAccount.name}/default/${name}'
}]

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output storageName string = storageAccount.name
