import { Box, Button } from "@chakra-ui/react";
import { useAccount, useConnect, useDisconnect } from "wagmi";

export default function Profile() {
  const { address, connector, isConnected } = useAccount();
  const { connect, connectors, error, isLoading, pendingConnector } = useConnect();
  const { disconnect } = useDisconnect();

  if (isConnected) {
    return (
      <div className="main">
        <div className="title">Connected to {connector?.name}</div>
        <div>{address}</div>
        <Button className="card" onClick={disconnect as any} colorScheme="blue">
          Disconnect
        </Button>
      </div>
    );
  } else {
    return (
      <div className="main">
        {connectors.map((connector) => {
          return (
            <Button
              className="card"
              key={connector.id}
              onClick={() => connect({ connector })}
              colorScheme="blue"
            >
              {connector.name}
            </Button>
          );
        })}
        {error && <div>{error.message}</div>}
      </div>
    );
  }
}
