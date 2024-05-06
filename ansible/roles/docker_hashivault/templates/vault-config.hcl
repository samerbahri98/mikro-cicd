storage "postgresql" {
  connection_url = "{{ _docker_hashivault_pg_conn }}"
  table          = "{{ docker_hashivault_pgdb_table }}"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

ui = true

api_addr = "http://0.0.0.0:8200"
