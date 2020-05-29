import { Client, Provider, ProviderRegistry, Result } from "@blockstack/clarity";
import { assert } from "chai";
describe("counter contract test suite", () => {
  let conferenceClient: Client;
  let provider: Provider;
  before(async () => {
    provider = await ProviderRegistry.createProvider();
    conferenceClient = new Client("SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB.conference", "conference", provider);
  });
  it("should have a valid syntax", async () => {
    await conferenceClient.checkContract();
  });
  describe("deploying an instance of the contract", () => {
    const execMethod = async (method: string, _args, from) => {
      const tx = conferenceClient.createTransaction({
        method: {
          name: method,
          args: _args,
        },
      });
      await tx.sign(from);
      const receipt = await conferenceClient.submitTransaction(tx);
      return receipt;
    }
    before(async () => {
      await conferenceClient.deployContract();
    });

    it("test conference", async () => {
      const buyer = "ST23V6Z045X6CNXYBVHBSATCHVA24EQ8R2PRAVZH2";
      const owner = "SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7";
      const receipt = await execMethod("init-conference", [1, `u${Date.now()}`, "u300000", "u1", "u1000"], owner);
      assert.equal(receipt.success, true);

      await execMethod("buy-ticket", [1, buyer], owner);
      await execMethod("enter-conference", [1], buyer)
      
    })
  });
  after(async () => {
    await provider.close();
  });
});
