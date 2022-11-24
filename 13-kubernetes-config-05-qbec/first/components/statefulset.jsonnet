local p = import '../params.libsonnet';
local params = p.components;

[
  {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: 'db',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'db',
        },
      },
      serviceName: 'db',
      replicas: params.db.replicas,
      template: {
        metadata: {
          labels: {
            app: 'db',
          },
        },
        spec: {
          containers: [
            {
              name: 'db',
              image: params.db.image,
              ports: [
                {
                  containerPort: params.db.port
                },
              ],
              env: [
                {
                  name: 'POSTGRES_USER',
                  value: params.db.postgres_user
                },
                {
                  name: 'POSTGRES_PASSWORD',
                  value: params.db.postgres_password
                },
                {
                  name: 'POSTGRES_DB',
                  value: params.db.postgres_db
                },
              ],
            },
          ],
        },
      },
      
    },
  },
]