local p = import '../params.libsonnet';
local params = p.components;

[
    {
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
            name: 'backend',
            labels: {
                app: 'backend',
            },
        },
        spec: {
            replicas: params.backend.replicas,
            selector: {
                matchLabels: {
                    app: 'backend',
                },
            },
            template: {
                metadata: {
                    labels: {
                        app: 'backend',
                    },
                },
                spec: {
                    containers: [
                        {
                            name: 'backend',
                            image: params.backend.image,
                            volumeMounts: [
                                {
                                    name: 'static-storage',
                                    mountPath: params.volumeMounts.mountPath,
                                },
                            ],
                            ports: [
                                {
                                    containerPort: params.backend.port,
                                },
                            ],
                            env: [
                                {
                                    name: 'DATABASE_URL',
                                    value: 'postgres://' + params.db.postgres_user + ':' + params.db.postgres_password + '@db:' + params.db.port + '/' + params.db.postgres_db
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