import { useState } from "react";
import { useContractRead, useNetwork, useAccount } from "wagmi";
import YiJingImagesGenerator from "@/contracts/YiJingImagesGenerator.json";
import { Box, Card, CardBody, CardFooter, Center, Image } from "@chakra-ui/react";

export default function MetadataImage({ draw, isOpen }) {
  const [src, setSrc] = useState<string | null>(null);

  const { chain } = useNetwork();
  const { isConnected } = useAccount();

  useContractRead({
    address: YiJingImagesGenerator[chain?.id.toString()]?.contractAddress,
    abi: YiJingImagesGenerator.contractAbi,
    functionName: "getNftImage",
    args: [draw],
    chainId: chain?.id,
    enabled: draw !== null,
    onSuccess(data) {
      setSrc(data);
    },
  });

  return (
    <Box hidden={!draw && !src} width="100%">
      <Card width={{ base: "100%", lg: "100%" }} alignItems="center">
        <CardBody p={"none"}>
          <Image src={src!} alt="" height="100%" />
        </CardBody>
        <CardFooter justifyContent="space-around"></CardFooter>
      </Card>
    </Box>
  );
}
