# import {
#   to = azurerm_lb_backend_address_pool.worker_pool
#   id = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/backendAddressPools/worker_pool"
#   provider = azurerm
# }

# import {
#   to = azurerm_lb_backend_address_pool.control_pool
#   id = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/backendAddressPools/control_pool"
#   provider = azurerm
# }

import {
  to = azurerm_lb.pizza
  id = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer"
}

# import {
#   to = azurerm_lb_probe.lb_probe
#   id = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/probes/ssh_test"
#   provider = azurerm
# }

# import {
#   to = azurerm_lb_rule.control_ssh_rule
#   id = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/loadBalancingRules/ssh_test"
#   provider = azurerm
# }
# import {
#   to = azurerm_lb_rule.worker_ssh_rule
#   id = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/loadBalancingRules/ssh_worker"
#   provider = azurerm
# }
# import {
#   to = azurerm_lb_rule.worker_produktservice_rule
#   id = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/loadBalancingRules/pizza_produktservice"
#   provider = azurerm
# }
# import {
#   to = azurerm_lb_rule.worker_bestellservice_rule
#   id = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/loadBalancingRules/pizza_bestellservice"
#   provider = azurerm
# }