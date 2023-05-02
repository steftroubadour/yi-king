import "@rainbow-me/rainbowkit/styles.css";

import {
  getDefaultWallets,
  connectorsForWallets,
  RainbowKitProvider,
} from "@rainbow-me/rainbowkit";
import { CreateClientConfig, configureChains, createClient, WagmiConfig } from "wagmi";
import { Chain, sepolia, foundry, polygon, polygonMumbai } from "wagmi/chains";
import { alchemyProvider } from "wagmi/providers/alchemy";
import { publicProvider } from "wagmi/providers/public";
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

const { chains, provider } = configureChains(
  [sepolia, polygon, polygonMumbai, foundry] as Chain[],
  [
    //alchemyProvider({ apiKey: process.env.NEXT_PUBLIC_ALCHEMY_ID! }),
    publicProvider(),
  ]
);

/*const { connectors } = getDefaultWallets({
  appName: "Yi Jing App",
  chains,
});*/

const projectId = "Yi Jing App";

const connectors = connectorsForWallets([
  {
    groupName: "Popular",
    wallets: [
      injectedWallet({ chains }),
      rainbowWallet({ projectId, chains }),
      metaMaskWallet({ projectId, chains }),
      coinbaseWallet({ chains, appName: projectId }),
      walletConnectWallet({ projectId, chains }),
    ],
  },
  {
    groupName: "More",
    wallets: [
      ledgerWallet(projectId, chains),
      argentWallet(projectId, chains),
      trustWallet(projectId, chains),
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
