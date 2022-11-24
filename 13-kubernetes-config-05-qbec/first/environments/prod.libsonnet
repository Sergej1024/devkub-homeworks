// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    db +: {
      replicas: 3,
    },
    backend +: {
      replicas: 3,
    },
    frontend +: {
      replicas: 3,
    },
  }
}
