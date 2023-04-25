import { useState, useEffect } from "react";
import { ethers } from "ethers";
import {
  useAccount,
  useContractWrite,
  useContractEvent,
  useNetwork,
  usePrepareContractWrite,
  useWaitForTransaction,
} from "wagmi";
import {
  Box,
  Button,
  Center,
  Checkbox,
  Input,
  InputGroup,
  InputLeftAddon,
  VStack,
} from "@chakra-ui/react";
import { CheckCircleIcon, SpinnerIcon } from "@chakra-ui/icons";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import YiJingNft from "@/contracts/YiJingNft.json";

export default function MintForm({ draw, onOpen, info, isOpen }) {
  interface FormState {
    info: string;
    isEncrypted: boolean;
    encryptionHelperMessage: string;
    infoBackup: string;
    date: number;
  }

  const { chain } = useNetwork();
  const { address, isConnected } = useAccount();

  const [form, setForm] = useState<FormState>({
    info: JSON.stringify(info),
    isEncrypted: false,
    encryptionHelperMessage: "",
    infoBackup: JSON.stringify(info),
    date: new Date().getTime(),
  } as FormState);
  const [validated, setValidated] = useState<boolean>(false);

  const [isEncrypted, setIsEncrypted] = useState<boolean>(false);
  const [write, setWrite] = useState<boolean>(false);
  const [isMinting, setIsMinting] = useState<boolean>(false);
  const [minted, setMinted] = useState<boolean>(false);

  useEffect(() => {
    setForm({
      info: isEncrypted ? "" : form.infoBackup,
      isEncrypted: isEncrypted,
      encryptionHelperMessage: "",
      infoBackup: form.info,
      date: form.date,
    });
  }, [isEncrypted]);

  const { config } = usePrepareContractWrite({
    address: YiJingNft[chain?.id.toString()]?.contractAddress,
    abi: YiJingNft.contractAbi,
    functionName: "mint", // NftData memory nftData, address affiliate
    args: [
      {
        hexagram: { lines: draw },
        date: form.date,
        encrypted: false,
        info: JSON.stringify(info),
        encryptionHelperMessage: "",
      },
      ethers.constants.AddressZero,
    ],
    overrides: {
      value: ethers.utils.parseEther("1"),
      gasLimit: 30000000,
    },
    chainId: chain?.id,
    enabled: isOpen,
  });
  const contractWrite = useContractWrite(config);

  useEffect(() => {
    if (!write) return;

    contractWrite.write();
  }, [write]);

  const waitForTransaction = useWaitForTransaction({
    hash: contractWrite.data?.hash,
    enabled: isOpen,
  });

  useEffect(() => {
    if (!waitForTransaction.isSuccess) return;

    setIsMinting(true);
  }, [waitForTransaction.isSuccess]);

  useContractEvent({
    address: YiJingNft[chain?.id.toString()]?.contractAddress,
    abi: YiJingNft.contractAbi,
    eventName: "Transfer",
    listener(from, to, tokenId) {
      console.log(from, to, tokenId);
      if (to === address) {
        setIsMinting(false);
        setMinted(true);
      }
    },
  });

  function renderButton() {
    if (!draw) return;

    if (isConnected) {
      if (!validated) {
        return <Button onClick={() => setValidated(true)}>Validate</Button>;
      }

      return (
        <Button onClick={() => setWrite(true)}>
          {isMinting ? (
            <SpinnerIcon />
          ) : minted ? (
            <span>
              <CheckCircleIcon color={"green"} mr={"1"} />
              Minted
            </span>
          ) : (
            "Mint"
          )}
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

  const inputs = [
    {
      label: "Info",
      input: "info",
      placeholder: isEncrypted ? "paste here your encrypted info" : "...",
    },
    {
      label: "Encryption Helper",
      input: "encryptionHelperMessage",
      placeholder: "to remember encryption process",
    },
  ];

  const outputs = [
    {
      label: "Info",
      input: "info",
    },
    {
      label: "Encryption Helper",
      input: "encryptionHelperMessage",
    },
    {
      label: "Date",
      input: "date",
    },
    {
      label: "Encrypted",
      input: "isEncrypted",
    },
  ];

  return (
    <>
      <VStack justify="center" width="100%" flex={{ base: 1, md: "auto" }} mb="10">
        <Box hidden={!(isOpen && !validated)} width="100%">
          <Checkbox colorScheme="green" onChange={(e) => setIsEncrypted(e.target.checked)}>
            {" "}
            is information encrypted ?
          </Checkbox>
          {inputs.map(({ label, input, placeholder }) => (
            <Box key={label} className="form-group mb-3">
              <InputGroup hidden={!isEncrypted && input === "encryptionHelperMessage"}>
                <InputLeftAddon children={label} />
                <Input
                  type="text"
                  placeholder={placeholder}
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

          <Center>{renderButton()}</Center>
        </Box>
        <Box hidden={!(isOpen && validated)} width="100%">
          {outputs.map(({ label, input }) => (
            <Box key={label} className="form-group mb-3">
              <InputGroup hidden={!isEncrypted && input === "encryptionHelperMessage"}>
                <InputLeftAddon children={label} />
                <Input
                  isDisabled
                  type="text"
                  value={
                    input === "date" ? new Date(form[input]).toLocaleDateString() : form[input]
                  }
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

          <Center>{renderButton()}</Center>
        </Box>
        <Button hidden={!draw || isOpen} onClick={onOpen}>
          Save data on Blockchain
        </Button>
      </VStack>
    </>
  );
}