import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new goal",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("arctide-core", "create-goal", 
        [types.utf8("Learn Clarity")], 
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), "u0");
    
    let goal = chain.callReadOnlyFn(
      "arctide-core",
      "get-goal",
      [types.uint(0)],
      wallet_1.address
    );
    
    goal.result.expectSome().expectTuple()["status"].expectAscii("active");
  },
});

Clarinet.test({
  name: "Can complete goal and receive tokens",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("arctide-core", "create-goal", 
        [types.utf8("Learn Clarity")], 
        wallet_1.address
      ),
      Tx.contractCall("arctide-core", "complete-goal",
        [types.uint(0)],
        wallet_1.address
      )
    ]);
    
    block.receipts[1].result.expectOk();
    
    let balance = chain.callReadOnlyFn(
      "atide-token",
      "get-balance",
      [types.principal(wallet_1.address)],
      wallet_1.address
    );
    
    balance.result.expectOk().expectUint(100);
  },
});
