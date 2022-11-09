[all]
${master_node}
${works_node}

[kube_control_plane]
${list_master}

[kube_node]
${list_works}

[etcd]
${list_master}

[k8s_cluster:children]
kube_node
kube_control_plane