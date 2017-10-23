#!/bin/bash
set -e

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"

get_cluster_ip_from_dns() {
    local cluster_ip=$( \
        /usr/local/bin/elixir -e ":inet_res.lookup('${EJABBERD_CLUSTER_DNS_NAME}', :in, :a) |> Enum.map(fn {a,b,c,d} -> IO.puts(\"#{a}.#{b}.#{c}.#{d}\") end)" \
        | grep -v ${HOSTIP} \
        | head -1)
    echo "${cluster_ip}"
}


file_exist ${FIRST_START_DONE_FILE} \
    && exit 0

is_zero ${EJABBERD_CLUSTER_DNS_NAME} \
    && exit 0

cluster_ip=$(get_cluster_ip_from_dns)

if [ -n "$cluster_ip" ]; then
    echo "Found other IP ${cluster_ip} for cluster ${EJABBERD_CLUSTER_DNS_NAME}, attempting to join"
    join_cluster "${cluster_ip}"
else
    echo "No other IP found for cluster ${EJABBERD_CLUSTER_DNS_NAME}, assuming I'm the master"
fi

exit 0
