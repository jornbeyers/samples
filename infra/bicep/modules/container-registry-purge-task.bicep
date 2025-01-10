// MARK: Scope
targetScope = 'resourceGroup'

// MARK: Parameters
param containerRegistryName string
param location string = resourceGroup().location
param purgeTaskName string = 'purge-old-images'
param purgeTimeout int = 3600
param purgeCpuCores int = 2
param purgeDays int = 30
param purgeKeep int = 5
param purgeFilter string = '*:.*'
param purgeSchedule string = '0 0 * * *' // Daily at midnight

// MARK: Variables
var encodedTask = base64(format(task, purgeFilter, purgeDays, purgeKeep, purgeTimeout))
var task = '''
version: v1.1.0
steps:
  - cmd: acr purge --filter {0} --ago {1}d --keep {2} --untagged
    timeout: {3}
    disableWorkingDirectoryOverride: true
'''

// MARK: Resources
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: containerRegistryName
}

resource purgeTask 'Microsoft.ContainerRegistry/registries/tasks@2019-06-01-preview' = {
  parent: containerRegistry
  name: purgeTaskName
  location: location
  properties: {
    status: 'Enabled'
    platform: {
      os: 'linux'
      architecture: 'amd64'
    }
    agentConfiguration: {
      cpu: purgeCpuCores
    }
    timeout: purgeTimeout
    step: {
      type: 'EncodedTask'
      encodedTaskContent: encodedTask
      values: []
    }
    trigger: {
      timerTriggers: [
        {
          schedule: purgeSchedule
          status: 'Enabled'
          name: 'purge-time-trigger'
        }
      ]
    }
    isSystemTask: false
  }
}
