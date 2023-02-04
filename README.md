


# Template Foundry Project

This is my go to template when I'm starting a new project.

## Template Solidity Project vs Template Foundry Project
If you used [Template Solidity Project](https://github.com/0xAtum/template-solidity-project) before here what changed
- Folder Structure (test is outside of src)
- Deployment is completely new (duh, this is no longer hardhat)
- BaseTest is still the same but has more utilities


## Dependencies

- [Foundry/Forge](https://github.com/gakonst/foundry) : Allows you to do native unit tests (in solidity).

## Installation

1. [Follow the Foundry's installation guide](https://book.getfoundry.sh/getting-started/installation.html)
2. `forge install`

Then use the command `make tests` to be sure everything is good to go

## Folder Strucutre

```
.
├── deployment   -> All Deployed Contracts
├── lib          -> All Forge install libraries
├── script       -> Deploy logic script
│   ├── config   -> Config for each of your contracts
│   ├── contract -> Contract Deployment logic
│   └── utils    -> Utilities used by the Template
├── src          -> Your Contracts
└── test         -> Your Tests
```

## Coverage

Coverage isn't production ready, but still quite a nice tool to use.
If you want to use it correctly, install

- Coverage Gutter Extension (vscode)

Then when you run `make coverage-output`, it will generate a file that Coverage Gutter will read. Go to your contract's code and use the vscode command `>Coverage Gutters: Display Coverage`

You will see in red the code that isn't being tested by your tests.

## How to deploy

    deploy :; $(FORGE_CLEAN) && forge script script/contract/$(FILENAME).s.sol --rpc-url $(RPC)
     --sig "run(string)" $(NETWORK) --broadcast --verify -vvvv

FILENAME = The name of your deployment script without extensions. e.g: HelloWorldScript.s.sol will be HelloWorld
RPC = Your RPC 
NETWORK = Name of the network. This is purely for you, it doesn't need to have the same name as the actual network. It is used for your configs & naming the deployment output.

Example
`make deploy FILENAME="HelloWorldScript" RPC="${GOERLI_ARBITRUM_TESTNET}" NETWORK="arbitrumTestnet"`

**Note**: Be sure you prepare your output file. let say you want to deploy on a network called `LocalHost`, you have to create the output file `/deployment/LocalHost.json` first

## Commands script
I'm using
[MakeFile](https://github.com/0xAtum/template-foundry-project/blob/main/Makefile)
for the commands.

e.g: `make tests`
e.g (with args): `make tests EXTRA='-vvv --match-contract HelloWorldTest'`

## Recommendations
- Using VSCode. (Sadly, there's no real support on intellij)
- solidity extention by Juan Blanco (be sure to set forge as its Formatter)


## Resources
- [Decoding JSON](https://book.getfoundry.sh/cheatcodes/parse-json?highlight=json#decoding-json-objects-into-solidity-structs)
- [Fork Testing](https://book.getfoundry.sh/forge/fork-testing?highlight=fork#forking-cheatcodes)
- [Slither](https://github.com/crytic/slither/wiki/Usage)


## Contributions
Feel free to contribute on this template. The PR / your code needs to follow this standard
- Internal Function starts with `_` 
- Function parameters starts with `_`
- use `return` keyword even though the function is doing it when you're naming the returned value.
- new Features needs to be generic.

## License
MIT
