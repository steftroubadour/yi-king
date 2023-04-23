import { useState } from "react";
import { Box, Stack } from "@chakra-ui/react";
import { useAccount } from "wagmi";
import MetadataImage from "@/components/MetadataImage";
import Hexagrams from "@/components/Hexagrams";
import Header from "@/components/Header";
import RandomForm from "@/components/RandomForm";

export default function App() {
  type DrawLineValue = 0 | 1 | 2 | 3;
  const [draw, setDraw] = useState<DrawLineValue[6] | null>(null);
  const [toMint, setToMint] = useState<boolean>(false);

  const { address, isConnected } = useAccount();
  /*const provider = useProvider()
  const {data: signerData} = useSigner();*/

  return (
    <Box pb={{ base: "12", md: "24" }}>
      <Header />
      <Box mx={{ base: "10", md: "25%" }} spacing="10">
        {toMint ? renderMintSection() : renderRandomSection()}
      </Box>
    </Box>
  );

  function renderRandomSection() {
    return (
      <>
        <RandomForm setDraw={setDraw} />
        <Stack
          direction={{ base: "column", md: "row" }}
          justify="space-between"
          alignItems="center"
        >
          <Hexagrams draw={draw} />
          <MetadataImage
            draw={draw}
            setToMint={setToMint}
            toMint={toMint}
            isConnected={isConnected}
          />
        </Stack>
      </>
    );
  }

  function renderMintSection() {
    return (
      <>
        <Stack
          direction={{ base: "column", md: "row" }}
          justify="space-between"
          alignItems="center"
        >
          <MetadataImage draw={draw} toMint={toMint} isConnected={isConnected} />
        </Stack>
      </>
    );
  }
}
