import "@rainbow-me/rainbowkit/styles.css";

import {
  getDefaultWallets,
  connectorsForWallets,
  RainbowKitProvider,
} from "@rainbow-me/rainbowkit";
import { CreateClientConfig, configureChains, createClient, WagmiConfig } from "wagmi";
import { Chain, sepolia, foundry, polygon, polygonMumbai } from "wagmi/chains";
//import { alchemyProvider } from "wagmi/providers/alchemy";
import { infuraProvider } from "wagmi/providers/infura";
//import { publicProvider } from "wagmi/providers/public";
//import { jsonRpcProvider } from "@wagmi/core/providers/jsonRpc";

import {
  injectedWallet,
  rainbowWallet,
  metaMaskWallet,
  coinbaseWallet,
  walletConnectWallet,
  ledgerWallet,
  argentWallet,
  trustWallet,
} from "@rainbow-me/rainbowkit/wallets";

import App from "../components/App";

const { chains, provider } = configureChains([sepolia, polygonMumbai] as Chain[], [
  infuraProvider({ apiKey: process.env.NEXT_PUBLIC_INFURA_API_KEY! }),
  //alchemyProvider({ apiKey: process.env.NEXT_PUBLIC_ALCHEMY_ID! }),
  //publicProvider(),
]);

/*const { connectors } = getDefaultWallets({
  appName: "Yi Jing App",
  chains,
});*/

const connectors = connectorsForWallets([
  {
    groupName: "Popular",
    wallets: [
      injectedWallet({ chains }),
      metaMaskWallet({ chains }),
      walletConnectWallet({ chains }),
    ],
  },
  {
    groupName: "More",
    wallets: [
      ledgerWallet({ chains }),
      argentWallet({ chains }),
      trustWallet({ chains }),
      rainbowWallet({ chains }),
      coinbaseWallet({ chains, appName: "Yi Jing App" }),
    ],
  },
]);

const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
} as CreateClientConfig);

export default function Home() {
  return (
    <WagmiConfig client={wagmiClient}>
      <RainbowKitProvider chains={chains}>
        <App />
      </RainbowKitProvider>
    </WagmiConfig>
  );
}
