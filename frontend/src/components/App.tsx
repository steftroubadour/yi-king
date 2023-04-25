import { useState } from "react";
import {
  Box,
  Button,
  Stack,
  VStack,
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalBody,
  ModalCloseButton,
  useDisclosure,
} from "@chakra-ui/react";
import { useAccount } from "wagmi";
import MetadataImage from "@/components/MetadataImage";
import Hexagrams from "@/components/Hexagrams";
import Header from "@/components/Header";
import RandomForm from "@/components/RandomForm";
import MintForm from "@/components/MintForm";

export default function App() {
  type DrawLineValue = 0 | 1 | 2 | 3;
  type Info = { name: string; question: string };
  const [draw, setDraw] = useState<Array<DrawLineValue> | null>(null);
  const [info, setInfo] = useState<Info>({ name: "", question: "" });

  const { isOpen, onOpen, onClose } = useDisclosure();

  const { isConnected } = useAccount();
  /*const provider = useProvider()
  const {data: signerData} = useSigner();*/
  const boxProps = {
    mx: { base: "10", md: "25%" },
    spacing: "10",
  };

  const mint1Props = {
    draw: draw,
    isOpen: isOpen,
    info: info,
    onClose: onClose,
  };

  return (
    <Box pb={{ base: "12", md: "24" }}>
      <Header />
      <Box {...boxProps}>
        <Modal isOpen={isOpen} onClose={onClose} size={"xl"}>
          <ModalOverlay bg="blackAlpha.300" backdropFilter="blur(10px) hue-rotate(90deg)" />
          <ModalContent>
            <ModalHeader />
            <ModalCloseButton />
            <ModalBody>
              <VStack justify="center" flex={{ base: 1, md: "auto" }} mb="10">
                <MetadataImage draw={draw} isOpen={isOpen} />
                <MintForm {...mint1Props} />
              </VStack>
            </ModalBody>
            <ModalFooter />
          </ModalContent>
        </Modal>
        <RandomForm setDraw={setDraw} setInfo={setInfo} />
        <Stack
          direction={{ base: "column", md: "row" }}
          justify="space-between"
          alignItems="center"
        >
          <Hexagrams draw={draw} />
          <VStack justify="center" flex={{ base: 1, md: "auto" }} mb="10">
            <MetadataImage draw={draw} onOpen={onOpen} isOpen={isOpen} />
            <MintForm draw={draw} isOpen={isOpen} info={info} onOpen={onOpen} />
          </VStack>
        </Stack>
      </Box>
    </Box>
  );
}
