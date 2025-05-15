param vnet string = 'azVnet'
param subnet string = 'azSubnet'
param location string = resourceGroup().location
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetAddressPrefix string = '10.0.1.0/24'
param privateip string = '10.0.1.2'
param storageSuffix string = 'core.windows.net'


resource azVnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnet
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnet
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }

    ]
   
  }
}
resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'azNSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-ssh'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {

        name:'allow-private-endpoint'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix:privateip
          access: 'Allow'
          priority: 200
          direction: 'outbound'
      }
      }
      
      {
        name: 'allow-dns'
        properties: {
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'outbound'
        }
      }
      {
        name: 'deny-all'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'outbound'
        }
      }
    ]
  }
}
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'azstorageacct'
  location: location
  
  sku: {
    name: 'Standard_LRS'
   
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      
      virtualNetworkRules: [
        {
          id: '${azVnet.id}/subnets/${subnet}'
          action: 'Allow'
        }
      ]
      ipRules: []
      defaultAction: 'Deny'
    }
  }
}
resource dns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name:  '${storageAccount.name}.blob.${storageSuffix}'

  location: location
  properties: {
  
  }
}
resource dnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'azPrivateDnsLink'
  parent: dns
  location: location
  properties: {
    virtualNetwork: {
      id: azVnet.id
    }
    registrationEnabled: false
  }
}


  resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: 'azPrivateEndpoint'
  location: location
  properties: {
    subnet: {
      id: azVnet.properties.subnets[0].id
    }
    privateLinkServiceConnections: [
      {
        name: 'azPrivateLinkServiceConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'azPrivateEndpointNic'
    customIpConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: privateip
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
  }
}

