// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("APIConsumerModule", (m) => {
  const jobId = "7d80a6386ef543a3abb52817f6707e3d";
  const fee = m.getParameter("fee", (1n * 10n ** 17n).toString()); // 0.1 LINK
  const chainlinkToken = m.getParameter(
    "chainlinkToken",
    "0x779877A7B0D9E8603169DdbD7836e478b4624789"
  );
  const chainlinkOracle = m.getParameter(
    "chainlinkOracle",
    "0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD"
  );

  const apiConsumer = m.contract(
    "APIConsumer",
    [],
    {
      constructorArgs: [],
      properties: {
        jobId,
        fee,
        chainlinkToken,
        chainlinkOracle,
      },
    }
  );

  return { apiConsumer };
});
