import EVM.Assembly

abiCase :: [(Prelude.Integer, Label)] -> Assembly
abiCase xs = do
  push 224; push 2; exp; push 0; calldataload; div
  Prelude.mapM_
    (\(i, t) -> do dup 1; push i; eq; refer t; jumpi)
    xs

contract :: Assembly
contract = mdo
  callvalue; iszero; refer dispatch; jumpi                        -- Skip deposit if no value sent
  push 32; not; sload; callvalue; add                             -- Calculate new total supply
  push 32; not; sstore                                            -- Save new total supply to storage
  caller; sload; callvalue; add                                   -- Calculate new target balance
  caller; sstore                                                  -- Save new target balance to storage

  -- Emit `Join(address indexed, uint)'
  push 0xb4e09949657f21548b58afe74e7b86cd2295da5ff1598ae1e5faecb1cf19ca95
  callvalue; push 0; mstore; caller; swap 1; push 32; push 0; log 2

  dispatch <- label

  abiCase
    [ (0x18160ddd,  totalSupply)
    , (0xdd62ed3e,    allowance)
    , (0x70a08231,    balanceOf)
    , (0x095ea7b3,      approve)
    , (0xa9059cbb,     transfer)
    , (0x23b872dd, transferFrom)
    , (0xd0e30db0,         join)
    , (0x2e1a7d4d,         exit) ]

  fail <- label; revert
  quit <- label; stop

  join <- label; stop

  totalSupply <- label
  push 32; not; sload                                             -- Load supply from storage
  push 0; mstore; push 32; push 0; return                         -- Return total supply

  allowance <- label
  push 4; calldataload; push 36; calldataload                     -- Load owner and spender
  push 0; mstore; push 32; mstore                                 -- Write addresses to memory
  push 64; push 0; keccak256; sload                               -- Load allowance from storage
  push 0; mstore; push 32; push 0; return                         -- Return allowance

  balanceOf <- label
  push 4; calldataload; sload                                     -- Load balance from storage
  push 0; mstore; push 32; push 0; return                         -- Return balance

  approve <- label
  push 36; calldataload; push 4; calldataload                     -- Load spender and new allowance
  caller; push 0; mstore; dup 2; push 32; mstore
  dup 2; push 64; push 0; keccak256; sstore                       -- Write new allowance to storage

  -- Emit `Approval(address indexed, address indexed, uint)'
  push 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
  swap 3; push 0; mstore; caller; swap 1; push 0; push 0; log 3
  push 1; push 0; mstore; push 32; push 0; return                 -- Return true

  transfer <- label
  push 36; calldataload
  push 4; calldataload
  caller
  refer attemptTransfer; jump

  transferFrom <- label
  push 68; calldataload
  push 36; calldataload
  push 4; calldataload

  attemptTransfer <- label
  push 160; push 2; exp; dup 3; dup 3; or; div; refer fail; jumpi -- Abort if garbage in addresses
  dup 2; sload; dup 2; sload                                      -- Load source and target balances
  dup 5; dup 2; lt; refer fail; jumpi                             -- Abort if insufficient balance
  dup 3; caller; eq; refer performTransfer; jumpi                 -- Skip ahead if source is caller
  dup 3; push 0; mstore; caller; push 32; mstore
  push 32; push 0; keccak256                                      -- Determine allowance storage slot
  dup 1; sload                                                    -- Load allowance from storage
  push 32; not; dup 2; eq; refer performTransfer; jumpi           -- Skip ahead if allowance is max
  dup 7; dup 2; lt; refer fail; jumpi                             -- Abort if allowance is too low
  dup 7; swap 2; sub; swap 2; sstore                              -- Save new allowance to storage

  performTransfer <- label
  dup 5; swap 1; sub; dup 3; sstore                               -- Save source balance to storage
  dup 4; add; dup 3; sstore                                       -- Save target balance to storage

  -- Emit `Transfer(address indexed, address indexed, uint)'
  push 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
  swap 3; push 0; mstore; push 32; push 0; log 3
  pop
  push 1; push 0; mstore; push 32; push 0; return                 -- Return true
  pop

  exit <- label
  push 4; calldataload                                            -- Load amount to withdraw
  caller; sload                                                   -- Load source balance from storage
  dup 2; dup 2; sub                                               -- Calculate new source balance
  swap 1; dup 2; gt; refer fail; jumpi                            -- Abort if underflow occurred
  caller; sstore                                                  -- Save new source balance to storage
  push 32; not; sload                                             -- Load total supply from storage
  dup 2; swap 1; sub                                              -- Decrement total supply
  push 32; not; sstore                                            -- Save new total supply to storage
  push 0; push 0; push 0; push 0                                  -- No return data and no calldata
  dup 5; caller                                                   -- Send withdrawal amount to caller
  gaslimit; call; iszero; refer fail; jumpi                       -- Make call, aborting on failure

  -- Emit `Exit(address indexed, uint)'
  push 0x22d324652c93739755cf4581508b60875ebdd78c20c0cff5cf8e23452b299631
  swap 1; push 0; mstore; caller; swap 1; push 32; push 0; log 2

  push 1; push 0; mstore; push 32; push 0; return                 -- Return true
