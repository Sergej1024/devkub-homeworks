local p = import '../params.libsonnet';
local params = p.components;

[
    {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
            name: 'backend',
            labels: {
                app: 'backend',
            },
        },
        spec: {
            selector: {
                app: 'backend',
            },
            ports: [
                {
                    port: params.backend.port,
                },
            ],
            type: 'ClusterIP'
        },
    },
    {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
            name: 'frontend',
            labels: {
                app: 'frontend',
            },
        },
        spec: {
            selector: {
                app: 'frontend',
            },
            ports: [
                {
                    port: params.frontend.port,
                },
            ],
            type: 'ClusterIP'
        },
    },
    {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
            name: 'db',
            labels: {
                app: 'db',
            },
        },
        spec: {
            selector: {
                app: 'db',
            },
            ports: [
                {
                    port: params.db.port,
                },
            ],
            type: 'ClusterIP'
        },
    },
]