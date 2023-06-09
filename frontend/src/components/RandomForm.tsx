import { useState, useEffect } from "react";
import { ethers } from "ethers";
import { useAccount, useBlockNumber, useContractRead, useNetwork } from "wagmi";
import YiJingRandom from "@/contracts/YiJingRandom.json";
import { Box, Button, Heading, Input, InputGroup, InputLeftAddon, VStack } from "@chakra-ui/react";
import { sepolia, foundry } from "wagmi/chains";
import { ConnectButton } from "@rainbow-me/rainbowkit";

// Form to Mint NFT w/encrypted description
export default function RandomForm({ setDraw, setInfo }: { setDraw: any; setInfo: any }) {
  const [enabled, setEnabled] = useState(false);
  const [blockNumberDraw, setBlockNumberDraw] = useState<number | null>(null);
  const [blockNumber, setBlockNumber] = useState<number | null>(null);
  const [seed, setSeed] = useState<string | null>(null);

  interface FormState {
    name: string;
    question: string;
  }

  type Form = {
    [key: string]: any;
  };

  const [form, setForm] = useState<Form>({
    name: "",
    question: "",
  } as FormState);

  useBlockNumber({
    chainId: sepolia.id,
    onSuccess(blockNumber) {
      // first time
      console.log("New block", blockNumber);
      setBlockNumber(blockNumber);
    },
    onBlock(blockNumber) {
      // other times
      console.log("New block", blockNumber);
      setBlockNumber(blockNumber);
    },
    watch: true,
  });

  const abiCoder = ethers.utils.defaultAbiCoder;
  const length = 6;
  const min = 0;
  const max = 3;

  function enableUseContractReadHook() {
    if (blockNumberDraw === blockNumber) {
      console.log("Wait next block !");
      return;
    }

    setEnabled(true);
  }

  useEffect(() => {
    setSeed(
      ethers.utils.keccak256(abiCoder.encode(["string", "string"], [form.name, form.question]))
    );
    setInfo({ name: form.name, question: form.question });
  }, [form]);

  type DrawLineValue = 0 | 1 | 2 | 3;

  const { isConnected } = useAccount();
  const { chain } = useNetwork();
  const chainId = chain?.id === undefined ? 0 : chain?.id;
  const contractJson = YiJingRandom as ContractJson;

  type ContractJson = {
    [key: string]: any;
  };

  useContractRead({
    address: contractJson[chainId.toString()]?.contractAddress,
    abi: contractJson.contractAbi,
    functionName: "getNumbers",
    args: [seed!, length, min, max],
    chainId: chain?.id,
    enabled: enabled,
    onSuccess(data) {
      const draw = [];
      for (let i = 0; i < data.length; i++) {
        draw.push(JSON.parse(data[i] as string) as DrawLineValue);
      }
      //console.log('New draw', JSON.stringify(draw));

      setEnabled(false);
      setDraw(draw);
      setBlockNumberDraw(blockNumber);
    },
  });

  const inputs = [
    { label: "Name", input: "name" },
    { label: "Question", input: "question" },
  ];

  function renderButton() {
    if (!blockNumber) return;

    if (isConnected) {
      return (
        <Button
          isDisabled={blockNumberDraw === blockNumber}
          onClick={enableUseContractReadHook}
          colorScheme="blue"
        >
          Get your Hexagram
          {/*Hexagram (#{blockNumber}@{sepolia.name})*/}
        </Button>
      );
    }

    return (
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
    );
  }

  return (
    <>
      <VStack justify="center" flex={{ base: 1, md: "auto" }} mb="10">
        <Box>
          <Heading my={6}>
            {isConnected ? "Enter your name and your question" : "First connect your wallet"}
          </Heading>
          {inputs.map(({ label, input }) => (
            <Box key={label} className="form-group" mb={3}>
              <InputGroup>
                <InputLeftAddon children={label} />
                <Input
                  type="text"
                  placeholder="..."
                  value={form[input]}
                  onChange={(e) => {
                    setForm({
                      ...form,
                      [input]: e.target.value,
                    });
                  }}
                />
              </InputGroup>
            </Box>
          ))}

          {renderButton()}
        </Box>
      </VStack>
    </>
  );
}
