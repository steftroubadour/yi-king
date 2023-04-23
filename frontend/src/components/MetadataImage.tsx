import { useEffect, useState } from "react";
import {
  useContractRead,
  useContractWrite,
  usePrepareContractWrite,
  useWaitForTransaction,
  useNetwork,
} from "wagmi";
import YiJingImagesGenerator from "@/contracts/YiJingImagesGenerator.json";
import YiJingNft from "@/contracts/YiJingNft.json";
import { Box, Button, Card, CardBody, CardFooter, Center, Image } from "@chakra-ui/react";
import { foundry } from "wagmi/chains";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { ethers } from "ethers";

export default function MetadataImage({ draw, setToMint, toMint, isConnected }) {
  const [src, setSrc] = useState<string | null>(null);

  const { chain } = useNetwork();
  useContractRead({
    address: YiJingImagesGenerator[chain?.id.toString()]?.contractAddress,
    abi: YiJingImagesGenerator.contractAbi,
    functionName: "getNftImage",
    args: [draw],
    chainId: chain?.id,
    enabled: draw !== null,
    onSuccess(data) {
      //console.log('Success', JSON.stringify(data));
      setSrc(data);
    },
  });

  const { config } = usePrepareContractWrite({
    address: YiJingNft[chain?.id.toString()]?.contractAddress,
    abi: YiJingNft.contractAbi,
    functionName: "mint", // NftData memory nftData, address affiliate
    args: [
      {
        hexagram: { lines: draw },
        date: Math.floor(new Date().getTime() / 1000),
        encrypted: false,
        info: "info",
        encryptionHelperMessage: "",
      },
      ethers.constants.AddressZero,
    ],
    overrides: {
      value: ethers.utils.parseEther("1"),
      gasLimit: 30000000,
    },
    chainId: chain?.id,
    enabled: toMint,
  });
  const contractWrite = useContractWrite(config);
  const waitForTransaction = useWaitForTransaction({
    hash: contractWrite.data?.hash,
  });

  function mint() {
    if (!toMint) return setToMint(true);
    contractWrite.write();
  }

  return (
    <Box hidden={!draw && !src} width={{ base: "100%", lg: "50vw" }}>
      <Card width={{ base: "100%", lg: "100%" }} alignItems="center">
        <CardBody p={"none"}>
          <Image src={src!} alt="" height="100%" />
        </CardBody>
        <CardFooter justifyContent="space-around">
          <Center>
            <Button onClick={mint}>
              {toMint ? (
                isConnected ? (
                  "Mint"
                ) : (
                  <ConnectButton
                    accountStatus={{
                      smallScreen: "avatar",
                      largeScreen: "full",
                    }}
                    chainStatus={{
                      smallScreen: "none",
                      largeScreen: "full",
                    }}
                  />
                )
              ) : (
                "Save data on Blockchain"
              )}
            </Button>
          </Center>
        </CardFooter>
      </Card>
      {toMint && waitForTransaction.isFetching && <div>Check Wallet</div>}
      {toMint && waitForTransaction.isSuccess && (
        <div>Transaction: {JSON.stringify(waitForTransaction.data)}</div>
      )}
    </Box>
  );
}
