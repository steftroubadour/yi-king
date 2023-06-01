// Wagmi libraries
import { CreateClientConfig, configureChains, createClient, WagmiConfig, Client } from "wagmi";
import { Chain, sepolia, foundry, polygon, polygonMumbai } from "wagmi/chains";
import { alchemyProvider } from "wagmi/providers/alchemy";
import { InjectedConnector } from "wagmi/connectors/injected";
import { CoinbaseWalletConnector } from "wagmi/connectors/coinbaseWallet";
import { WalletConnectConnector } from "wagmi/connectors/walletConnect";
import { publicProvider } from "wagmi/providers/public";

import App from "../components/App";
import Web3AuthConnectorInstance from "./_Web3AuthConnectorInstance";
import Profile from "@/components/Profile";

export default function Home() {
  const { chains, provider, webSocketProvider } = configureChains(
    [sepolia, polygonMumbai] as Chain[],
    //[sepolia, polygon, polygonMumbai, foundry] as Chain[],
    [
      //alchemyProvider({ apiKey: process.env.NEXT_PUBLIC_ALCHEMY_ID! }),
      publicProvider(),
    ]
  );

  // Set up client
  const client = createClient({
    autoConnect: true,
    connectors: [
      /*new CoinbaseWalletConnector({
        chains,
        options: {
          appName: "wagmi",
        },
      }),
      new WalletConnectConnector({
        chains,
        options: {
          projectId: "3314f39613059cb687432d249f1658d2",
          showQrModal: true,
        },
      }),
      new InjectedConnector({
        chains,
        options: {
          name: "Injected",
          shimDisconnect: true,
        },
      }),*/
      Web3AuthConnectorInstance(chains),
    ],
    provider,
    webSocketProvider,
  } as CreateClientConfig);

  return (
    <WagmiConfig client={client}>
      <App />
    </WagmiConfig>
  );
}
