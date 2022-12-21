# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

FORGE_CLEAN = forge clean

# How to use $(EXTRA) or $(NETWORK)
# define it with your command. 
# e.g: make test EXTRA='-vvv --match-contract MyContractTest'
# e.g: make deploy-testnet NETWORK='arbitrumTestnet'

# deps
update:; forge update
remappings:; forge remappings > remappings.txt

# commands
coverage :; forge coverage 
coverage-output :; forge coverage --report lcov
build  :; $(FORGE_CLEAN) && forge build 
clean  :; $(FORGE_CLEAN)

# tests
tests   :; export FOUNDRY_PROFILE=unit $(FORGE_CLEAN) && forge test $(EXTRA)
tests-e2e :; export FOUNDRY_PROFILE=e2e $(FORGE_CLEAN) && forge test $(EXTRA)

# Gas Snapshots
snapshot :; $(FORGE_CLEAN) && forge snapshot $(EXTRA)
snapshot-fork :; $(FORGE_CLEAN) && forge snapshot --snap .gas-snapshot-fork $(RPC) $(EXTRA)

#Analytic Tools
slither :; slither --config-file ./slither-config.json src/

deploy :; $(FORGE_CLEAN) && forge script script/contract/$(FILENAME).s.sol --rpc-url $(RPC) --sig "run(string)" $(NETWORK) --broadcast --verify -vvvv
