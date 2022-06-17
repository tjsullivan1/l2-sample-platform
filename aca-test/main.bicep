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
// 
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

resource helloWorldnginx 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'hello-world-nginx'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/8b63fe10-d76a-4f8f-81ce-7a5a8b911779/resourcegroups/rg-core-it/providers/Microsoft.ManagedIdentity/userAssignedIdentities/acrpuller': {
               
    }
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnv.id
    template: {
      containers: [
        {
          name: 'hello-world'
          image: 'tjsacr01.azurecr.io/demos/nginx:latest'
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
    configuration: {
      registries: [
        {
          identity: '/subscriptions/8b63fe10-d76a-4f8f-81ce-7a5a8b911779/resourcegroups/rg-core-it/providers/Microsoft.ManagedIdentity/userAssignedIdentities/acrpuller'
          server: 'tjsacr01.azurecr.io'
        }
      ]
      dapr: {
        enabled: true
        appId: 'hello-world-nginx'
        appProtocol: 'http'
      }
      ingress: {
        external: true
        targetPort: 80
      }
    }
  }
}

resource helloWorldnextJS 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'hello-world-nextjs'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/8b63fe10-d76a-4f8f-81ce-7a5a8b911779/resourcegroups/rg-core-it/providers/Microsoft.ManagedIdentity/userAssignedIdentities/acrpuller': {
               
    }
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnv.id
    template: {
      containers: [
        {
          name: 'hello-world'
          image: 'tjsacr01.azurecr.io/demos/next.js:0.0.1'
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
    configuration: {
      registries: [
        {
          identity: '/subscriptions/8b63fe10-d76a-4f8f-81ce-7a5a8b911779/resourcegroups/rg-core-it/providers/Microsoft.ManagedIdentity/userAssignedIdentities/acrpuller'
          server: 'tjsacr01.azurecr.io'
        }
      ]
      dapr: {
        enabled: true
        appId: 'hello-world-nextjs'
        appProtocol: 'http'
      }
      ingress: {
        external: true
        targetPort: 3000
      }
    }
  }
}

output cappsEnvId string = containerAppsEnv.id
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output defaultDomain string = containerAppsEnv.properties.defaultDomain

