import "@rainbow-me/rainbowkit/styles.css";

import { getDefaultWallets, RainbowKitProvider } from "@rainbow-me/rainbowkit";
import { Client, CreateClientConfig, configureChains, createClient, WagmiConfig } from "wagmi";
import { Chain, mainnet, goerli, sepolia, foundry, polygon, polygonMumbai } from "wagmi/chains";
import { alchemyProvider } from "wagmi/providers/alchemy";
import { publicProvider } from "wagmi/providers/public";

import App from "../components/App";

const { chains, provider } = configureChains(
  [mainnet, goerli, sepolia, polygon, polygonMumbai, foundry] as Chain[],
  [alchemyProvider({ apiKey: process.env.NEXT_PUBLIC_ALCHEMY_ID! }), publicProvider()]
);

const { connectors } = getDefaultWallets({
  appName: "Yi Jing App",
  chains,
});

const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
} as CreateClientConfig) as Client;

export default function Home() {
  return (
    <WagmiConfig client={wagmiClient}>
      <RainbowKitProvider chains={chains}>
        <App />
      </RainbowKitProvider>
    </WagmiConfig>
  );
}
