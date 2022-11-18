require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("./tasks");
require("dotenv").config();

const MAINNET_RPC_URL =
  process.env.QUICKNODE_API_KEY_MAINNET ||
  process.env.ALCHEMY_MAINNET_RPC_URL ||
  "https://eth-mainnet.alchemyapi.io/v2/your-api-key";
const POLYGON_MAINNET_RPC_URL =
  process.env.POLYGON_MAINNET_RPC_URL ||
  "https://polygon-mainnet.alchemyapi.io/v2/your-api-key";
const GOERLI_RPC_URL =
  process.env.GOERLI_RPC_URL ||
  "https://eth-goerli.alchemyapi.io/v2/your-api-key";
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PRIVATE_KEY_CONTRIBUTOR = process.env.PRIVATE_KEY_CONTRIBUTOR || "0x";
const POLYGON_MUMBAI_RPC_URL = `https://polygon-mumbai.g.alchemy.com/v2/${
  process.env.POLYGON_MUMBAI_API_KEY ?? ""
}`;
// optional
const MNEMONIC = process.env.MNEMONIC || "Your mnemonic";
const FORKING_BLOCK_NUMBER = process.env.FORKING_BLOCK_NUMBER;

// Your API key for Etherscan, obtain one at https://etherscan.io/
const ETHERSCAN_API_KEY =
  process.env.ETHERSCAN_API_KEY || "Your etherscan API key";
const POLYGONSCAN_API_KEY =
  process.env.POLYGONSCAN_API_KEY || "Your polygonscan API key";
const REPORT_GAS = process.env.REPORT_GAS || false;
const test = "";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.16",
      },
      {
        version: "0.8.7",
      },
      {
        version: "0.6.6",
      },
      {
        version: "0.4.24",
      },
    ],
  },
  networks: {
    hardhat: {
      hardfork: "merge",
      //If you want to do some forking set `enabled` to true
      forking: {
        url: `${process.env.QUICKNODE_API_KEY_MAINNET}`,
        //blockNumber: FORKING_BLOCK_NUMBER,
        enabled: true,
      },
      chainId: 31337,
    },
    localhost: {
      chainId: 31337,
    },
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      //   accounts: {
      //     mnemonic: MNEMONIC,
      //   },
      chainId: 5,
    },
    mainnet: {
      url: MAINNET_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      //   accounts: {
      //     mnemonic: MNEMONIC,
      //   },
      chainId: 1,
    },
    polygon: {
      url: POLYGON_MAINNET_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 137,
    },
    mumbai: {
      url: POLYGON_MUMBAI_RPC_URL,
      accounts:
        PRIVATE_KEY !== undefined ? [PRIVATE_KEY, PRIVATE_KEY_CONTRIBUTOR] : [],
      chainId: 80001,
    },
  },
  defaultNetwork: "hardhat",
  etherscan: {
    // yarn hardhat verify --network <NETWORK> <CONTRACT_ADDRESS> <CONSTRUCTOR_PARAMETERS>
    apiKey: {
      polygon: POLYGONSCAN_API_KEY,
      goerli: ETHERSCAN_API_KEY,
      polygonMumbai: POLYGONSCAN_API_KEY,
    },
  },
  gasReporter: {
    enabled: REPORT_GAS,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },
  contractSizer: {
    runOnCompile: false,
    only: [
      "APIConsumer",
      "AutomationCounter",
      "NFTFloorPriceConsumerV3",
      "PriceConsumerV3",
      "RandomNumberConsumerV2",
    ],
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./build/cache",
    artifacts: "./build/artifacts",
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
      4: "0xA296a3d5F026953e17F472B497eC29a5631FB51B", // but for rinkeby it will be a specific address
      goerli: "0x84b9514E013710b9dD0811c9Fe46b837a4A0d8E0", //it can also specify a specific netwotk name (specified in hardhat.config.js)
    },
  },
  mocha: {
    timeout: 200000, // 200 seconds max for running tests
  },
};
