// MARK: Parameters
param containerRegistryName string
param resourceGroupName string
param actionGroupId string
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuName string
param storageThresholdPercentage int = 80
param storageUsedEnabled bool = true
param storageUsedSeverity int = 2
param storageUsedWindowSize string = 'PT1H'
param storageUsedFrequency string = 'PT1H'

// MARK: Variables
var alertActions = [
  {
    actionGroupId: actionGroupId
  }
]

var maxStorageThresholdGb = sku == 'Basic' ? 10 : sku == 'Standard' ? 100 : 500
var storageUsedThreshold = maxStorageThresholdGb * storageThresholdPercentage / 100 * 1024 * 1024 * 1024

// MARK: Existing Resources
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2024-11-01-preview' existing = {
  name: containerRegistryName
  scope: az.resourceGroup(resourceGroupName)
}

// MARK: Resources
module storageUsedAlert 'br/public:avm/res/insights/metric-alert:0.1.2' = {
  name: take('${containerRegistryName}-storage-used', 64)
  params: {
    name: '${containerRegistryName}-storage-used-alert'
    alertDescription: ''
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        metricName: 'StorageUsed'
        name: 'StorageUsed'
        operator: 'GreaterThanOrEqual'
        threshold: storageUsedThreshold
        timeAggregation: 'Average'
      }
    ]
    actions: alertActions
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    location: 'Global'
    windowSize: storageUsedWindowSize
    evaluationFrequency: storageUsedFrequency
    severity: storageUsedSeverity
    enabled: storageUsedEnabled
    scopes: [containerRegistry.id]
  }
}
