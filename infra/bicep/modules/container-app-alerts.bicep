// MARK: Parameters
param containerAppName string
param resourceGroupName string
param actionGroupId string

param cpuPercentageThreshold int = 90
param cpuPercentageEnabled bool = true
param cpuPercentageSeverity int = 1
param cpuPercentageWindowSize string = 'PT5M'
param cpuPercentageFrequency string = 'PT1M'

param memoryPercentageThreshold int = 90
param memoryPercentageEnabled bool = true
param memoryPercentageSeverity int = 1
param memoryPercentageWindowSize string = 'PT5M'
param memoryPercentageFrequency string = 'PT1M'

param replicaRestartThreshold int = 3
param replicaRestartEnabled bool = true
param replicaRestartSeverity int = 1
param replicaRestartWindowSize string = 'PT5M'
param replicaRestartFrequency string = 'PT1M'

param connectionTimeoutThreshold int = 5
param connectionTimeoutEnabled bool = true
param connectionTimeoutSeverity int = 1
param connectionTimeoutWindowSize string = 'PT5M'
param connectionTimeoutFrequency string = 'PT1M'

// MARK: Variables
var alertActions = [
  {
    actionGroupId: actionGroupId
  }
]

// MARK: Existing Resources
resource aca 'Microsoft.App/containerApps@2024-03-01' existing = {
  name: containerAppName
  scope: az.resourceGroup(resourceGroupName)
}

// MARK: Resources
module cpuPercentageAlert 'br/public:avm/res/insights/metric-alert:0.1.2' = {
  name: take('${containerAppName}-cpu-percentage', 64)
  params: {
    name: '${containerAppName}-cpu-percentage-alert'
    alertDescription: ''
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        metricName: 'CpuPercentage'
        name: 'CpuPercentage'
        operator: 'GreaterThanOrEqual'
        threshold: cpuPercentageThreshold
        timeAggregation: 'Average'
      }
    ]
    actions: alertActions
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    location: 'Global'
    windowSize: cpuPercentageWindowSize
    evaluationFrequency: cpuPercentageFrequency
    severity: cpuPercentageSeverity
    enabled: cpuPercentageEnabled
    scopes: [aca.id]
  }
}

module memoryPercentageAlert 'br/public:avm/res/insights/metric-alert:0.1.2' = {
  name: take('${containerAppName}-memory-percentage', 64)
  params: {
    name: '${containerAppName}-memory-percentage-alert'
    alertDescription: ''
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        metricName: 'MemoryPercentage'
        name: 'MemoryPercentage'
        operator: 'GreaterThanOrEqual'
        threshold: memoryPercentageThreshold
        timeAggregation: 'Average'
      }
    ]
    actions: alertActions
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    location: 'Global'
    windowSize: memoryPercentageWindowSize
    evaluationFrequency: memoryPercentageFrequency
    severity: memoryPercentageSeverity
    enabled: memoryPercentageEnabled
    scopes: [aca.id]
  }
}

module replicaRestartAlert 'br/public:avm/res/insights/metric-alert:0.1.2' = {
  name: take('${containerAppName}-replica-restart', 64)
  params: {
    name: '${containerAppName}-replica-restart-alert'
    alertDescription: ''
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        metricName: 'RestartCount'
        name: 'ReplicaRestartCount'
        operator: 'GreaterThanOrEqual'
        threshold: replicaRestartThreshold
        timeAggregation: 'Maximum'
      }
    ]
    actions: alertActions
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    location: 'Global'
    windowSize: replicaRestartWindowSize
    evaluationFrequency: replicaRestartFrequency
    severity: replicaRestartSeverity
    enabled: replicaRestartEnabled
    scopes: [aca.id]
  }
}

module connectionTimeoutAlert 'br/public:avm/res/insights/metric-alert:0.1.2' = {
  name: take('${containerAppName}-connection-timeout', 64)
  params: {
    name: '${containerAppName}-connection-timeout-alert'
    alertDescription: ''
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        metricName: 'ResiliencyConnectTimeouts'
        name: 'ConnectionCount'
        operator: 'GreaterThanOrEqual'
        threshold: connectionTimeoutThreshold
        timeAggregation: 'Total'
      }
    ]
    actions: alertActions
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    location: 'Global'
    windowSize: connectionTimeoutWindowSize
    evaluationFrequency: connectionTimeoutFrequency
    severity: connectionTimeoutSeverity
    enabled: connectionTimeoutEnabled
    scopes: [aca.id]
  }
}
