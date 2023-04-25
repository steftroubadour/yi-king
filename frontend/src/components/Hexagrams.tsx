import { useState } from "react";
import { useContractReads, useNetwork } from "wagmi";
import YiJingImagesGenerator from "@/contracts/YiJingImagesGenerator.json";
import {
  Box,
  Card,
  CardBody,
  CardFooter,
  CardHeader,
  Center,
  HStack,
  Image,
} from "@chakra-ui/react";
import { foundry } from "wagmi/chains";

export default function Hexagrams({ draw }: { draw: any} ) {
  const [sources, setSources] = useState<string[3] | null>(null);
  const { chain } = useNetwork();
  const chainId = chain?.id === undefined ? 0 : chain?.id;

  const ImagesGenerator = YiJingImagesGenerator as ContractJson;

  type ContractJson = {
    [key: string]: any;
  };

  const yiJingImageContract = {
    address: ImagesGenerator[chainId.toString()]?.contractAddress,
    abi: ImagesGenerator.contractAbi,
    chainId: chain?.id,
  };

  /*  interface Contract {
    address: string;
    abi: string;
    chainId: number;
    functionName: string;
    args: Array<any | number>;
  }*/

  useContractReads({
    contracts: [
      {
        ...yiJingImageContract,
        functionName: "getHexagramImageForVariation",
        args: [draw, 0],
      },
      {
        ...yiJingImageContract,
        functionName: "getHexagramImageForVariation",
        args: [draw, 1],
      },
      {
        ...yiJingImageContract,
        functionName: "getHexagramImageForVariation",
        args: [draw, 2],
      },
    ],
    enabled: draw !== null, // or draw! in TS
    onSuccess(data: string) {
      console.log("Success", JSON.stringify(data));
      setSources(data);
    },
  });

  if (!sources || sources.length !== 3 || !sources[0] || !sources[1] || !sources[2]) return(<></>);

  return (
    <Box hidden={!draw && !sources}>
      <HStack
        spacing="4"
        width={{ base: "80vw", lg: "100%" }}
        justifyContent={{ base: "space-between", lg: "normal" }}
      >
        {["Draw", "From", "To"].map((variant, index) => (
          <Card key={variant} width={{ base: "30%", lg: "100px" }}>
            <CardHeader p={{ base: "2px", lg: "5px" }}>
              <Center w="100%" h="40px" bg="red" color="white">
                <Box as="span" fontWeight="bold" fontSize="lg">
                  {variant}
                </Box>
              </Center>
            </CardHeader>
            <CardBody p={"none"}>
              <Image src={sources![index][1]} alt="" width={"100%"} />
            </CardBody>
            <CardFooter>
              <Center w="100%" h="40px" bg="blue" color="white">
                <Box as="span" fontWeight="bold" fontSize="lg">
                  {JSON.parse(sources![index][0]) === 0 ? " " : JSON.parse(sources![index][0])}
                </Box>
              </Center>
            </CardFooter>
          </Card>
        ))}
      </HStack>
    </Box>
  );
}
