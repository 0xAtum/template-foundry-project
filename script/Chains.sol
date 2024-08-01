// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Chains {
  function getChainName() internal view returns (string memory) {
    uint256 chainId = block.chainid;

    if (chainId == 1) return "ethereum";
    if (chainId == 56) return "bsc";
    if (chainId == 10) return "optimism";
    if (chainId == 42_161) return "arbitrum";
    if (chainId == 137) return "polygon";
    if (chainId == 1101) return "polygonzkEVM";
    if (chainId == 250) return "fantom";
    if (chainId == 252) return "fraxtal";
    if (chainId == 43_114) return "avalanche";
    if (chainId == 100) return "gnosis";
    if (chainId == 1285) return "moonriver";
    if (chainId == 1284) return "moonbeam";
    if (chainId == 42_220) return "celo";
    if (chainId == 1_313_161_554) return "aurora";
    if (chainId == 1_666_600_000) return "harmony";
    if (chainId == 122) return "fuse";
    if (chainId == 25) return "cronos";
    if (chainId == 9001) return "evmos";
    if (chainId == 288) return "boba";
    if (chainId == 7700) return "canto";
    if (chainId == 8453) return "base";
    if (chainId == 5000) return "mantle";
    if (chainId == 314) return "filecoin";
    if (chainId == 534_352) return "scroll";
    if (chainId == 59_144) return "linea";
    if (chainId == 7_777_777) return "zora";
    if (chainId == 42) return "lukso";
    if (chainId == 169) return "mantaPacific";
    if (chainId == 81_457) return "blast";
    if (chainId == 7979) return "DOS";
    if (chainId == 648) return "endurance";
    if (chainId == 2222) return "kava";
    if (chainId == 1088) return "metis";
    if (chainId == 34_443) return "mode";
    if (chainId == 196) return "XLayer";
    if (chainId == 11_155_111) return "sepolia";
    if (chainId == 17_000) return "holesky";
    if (chainId == 97) return "bscTestnet";
    if (chainId == 11_155_420) return "optimismTestnet";
    if (chainId == 421_614) return "arbitrumTestnet";
    if (chainId == 80_002) return "polygonTestnet";
    if (chainId == 1442) return "polygonzkEVMTestnet";
    if (chainId == 4002) return "fantomTestnet";
    if (chainId == 43_113) return "avalancheTestnet";
    if (chainId == 10_200) return "gnosisTestnet";
    if (chainId == 1287) return "moonbeamTestnet";
    if (chainId == 44_787) return "celoTestnet";
    if (chainId == 1_313_161_555) return "auroraTestnet";
    if (chainId == 1_666_700_000) return "harmonyTestnet";
    if (chainId == 123) return "fuseTestnet";
    if (chainId == 338) return "cronosTestnet";
    if (chainId == 9000) return "evmosTestnet";
    if (chainId == 2880) return "bobaTestnet";
    if (chainId == 777) return "cantoTestnet";
    if (chainId == 553) return "mantleTestnet";
    if (chainId == 121) return "sandbox";

    return "localhost";
  }

  function isTestnet() internal view returns (bool) {
    uint256 chainId = block.chainid;

    if (
      chainId == 11_155_111 || chainId == 17_000 || chainId == 97 || chainId == 11_155_420
        || chainId == 421_614 || chainId == 80_002 || chainId == 1442 || chainId == 4002
        || chainId == 43_113 || chainId == 10_200 || chainId == 1287 || chainId == 44_787
        || chainId == 1_313_161_555 || chainId == 1_666_700_000 || chainId == 123
        || chainId == 338 || chainId == 9000 || chainId == 2880 || chainId == 777
        || chainId == 553 || chainId == 121
    ) return true;

    return false;
  }

  function isLocal() internal view returns (bool) {
    return block.chainid == 31_337;
  }
}
