param containerAppsEnvName string ='tjscatest'
param logAnalyticsWorkspaceName string ='law-tjscatest'
param appInsightsName string ='ai-tjscatest'
param location string = 'eastus'


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
  }
}

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: containerAppsEnvName
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

resource helloWorld 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'hello-world'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnv.id
    template: {
      containers: [
        {
          name: 'hello-world'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
    configuration: {
      dapr: {
        enabled: true
        appId: 'hello-world'
        appProtocol: 'http'
      }
      ingress: {
        external: true
        targetPort: 80
      }
    }
  }
}

  
output cappsEnvId string = containerAppsEnv.id
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output defaultDomain string = containerAppsEnv.properties.defaultDomain

