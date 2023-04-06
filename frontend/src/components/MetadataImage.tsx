import { useState } from "react";
import { useContractRead } from "wagmi";
import { contractAbi, contractAddress } from "@/contracts/yijingImage";
import { Box, Button, Card, CardBody, CardFooter, Center, Image } from "@chakra-ui/react";
import { foundry } from "wagmi/chains";

export default function MetadataImage({ draw }) {
  const [src, setSrc] = useState<string | null>(null);

  useContractRead({
    address: contractAddress,
    abi: contractAbi,
    functionName: "getImageData",
    args: [draw],
    chainId: foundry.id,
    enabled: draw !== null,
    onSuccess(data) {
      //console.log('Success', JSON.stringify(data));
      setSrc(data);
    },
  });

  function mint() {}

  return (
    <Box hidden={!draw && !src} width={{ base: "100%", lg: "50vw" }}>
      <Card width={{ base: "100%", lg: "100%" }}>
        <CardBody p={"none"}>
          <Image src={src} alt="" height="100%" />
        </CardBody>
        <CardFooter justifyContent="space-around">
          <Center>
            <Button onClick={mint}>Save data on Blockchain</Button>
          </Center>
        </CardFooter>
      </Card>
    </Box>
  );
}
