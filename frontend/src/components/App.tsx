import { useState } from "react";
import { Box, Stack } from "@chakra-ui/react";
import MetadataImage from "@/components/MetadataImage";
import Hexagrams from "@/components/Hexagrams";
import Header from "@/components/Header";
import RandomForm from "@/components/RandomForm";

export default function App() {
  type DrawLineValue = 0 | 1 | 2 | 3;
  const [draw, setDraw] = useState<DrawLineValue[6] | null>(null);

  /*const {address, isConnected} = useAccount()
  const provider = useProvider()
  const {data: signerData} = useSigner();*/

  return (
    <Box pb={{ base: "12", md: "24" }}>
      <Header />

      <Box mx={{ base: "10", md: "25%" }} spacing="10">
        <RandomForm setDraw={setDraw} />
        <Stack
          direction={{ base: "column", md: "row" }}
          justify="space-between"
          alignItems="center"
        >
          <Hexagrams draw={draw} />
          <MetadataImage draw={draw} />
        </Stack>
      </Box>
    </Box>
  );
}
