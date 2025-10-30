# devopsproeu-bgp
## Example NSO service for BGP provisioning

This is a service for the Cisco Crossworks Network Services Orchestrator (NSO) intended for the provisioning of BGP configurations in target Cisco IOSXR devices.

## Usage

```
module: devopsproeu-bgp
  +--rw devopsproeu-bgp* [device]
     +--rw device       -> /ncs:devices/device/name
     +--rw local-as?    uint32
     +--rw neighbors* [address remote-as]
        +--rw address      inet:ipv4-address
        +--rw remote-as    uint32
```

A cURL request for provisioning using the RESTCONF interface looks like the following:

```
curl --location --request PATCH 'http://localhost:8082/restconf/data' \
--header 'Accept: application/yang-data+json' \
--header 'Content-Type: application/yang-data+json' \
--header 'Authorization: Basic YWRtaW46YWRtaW4=' \
--data '
{
  "data": {
    "devopsproeu-bgp:devopsproeu-bgp": [
      {
        "device": "asr9k-xr-7601",
        "local-as": 65001,
        "neighbors": [
          {
            "address": "192.168.2.6",
            "remote-as": 65002,
            "address-family": {
              "in-policy": "TEST_RPL_01",
              "out-policy": "TEST_RPL_02"
            }
          },
          {
            "address": "192.168.2.7",
            "remote-as": 65003,
            "address-family": {
              "in-policy": "TEST_RPL_01",
              "out-policy": "TEST_RPL_03"
            }
          },
          {
            "address": "192.168.2.8",
            "remote-as": 65004,
            "address-family": {
              "in-policy": "PROD_RPL_01",
              "out-policy": "PROD_RPL_02"
            }
          },
          {
            "address": "192.168.2.9",
            "remote-as": 65005,
            "address-family": {
              "in-policy": "TEST_RPL_01",
              "out-policy": "PROD_RPL_02"
            }
          }
        ]
      },
      {
        "device": "ncs5k-xr-5702",
        "local-as": 65001,
        "neighbors": [
          {
            "address": "192.168.2.6",
            "remote-as": 65002,
            "address-family": {
              "in-policy": "TEST_RPL_03",
              "out-policy": "TEST_RPL_04"
            }
          },
          {
            "address": "192.168.2.7",
            "remote-as": 65003,
            "address-family": {
              "in-policy": "PROD_01",
              "out-policy": "TEST_RPL_02"
            }
          }
        ]
      }
    ]
  }
}
'
```