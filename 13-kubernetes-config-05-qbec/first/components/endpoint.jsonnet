[
  {
    kind: 'Endpoints',
    apiVersion: 'v1',
    metadata: {
      name: 'external-api',
    },
    subsets: [
      {
        addresses: [
          {
            ip: '158.160.46.9',
          },
        ],
        ports: [
          {
            port: 443,
          },
        ],
      },
    ],
  },
]