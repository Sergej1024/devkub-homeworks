local p = import '../params.libsonnet';
local params = p.components;

[
    {
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
            name: 'frontend',
            labels: {
                app: 'frontend',
            },
        },
        spec: {
            replicas: params.frontend.replicas,
            selector: {
                matchLabels: {
                    app: 'frontend',
                },
            },
            template: {
                metadata: {
                    labels: {
                        app: 'frontend',
                    },
                },
                spec: {
                    containers: [
                        {
                            name: 'frontend',
                            image: params.frontend.image,
                            volumeMounts: [
                                {
                                    name: 'static-storage',
                                    mountPath: params.volumeMounts.mountPath,
                                },
                            ],
                            ports: [
                                {
                                    containerPort: params.frontend.port,
                                },
                            ],
                            env: [
                                {
                                    name: 'BASE_URL',
                                    value: params.frontend.BASE_URL
                                },
                            ],
                        },
                    ],
                    volumes: [
                            {
                                name: 'static-storage',
                                persistentVolumeClaim: {
                                    claimName: params.pvc.claimName,
                                },
                            },
                        ],
                },
            },

        },
    },
]