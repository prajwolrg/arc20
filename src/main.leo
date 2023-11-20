// arc20.aleo must import arc20_registry
import arc20_registry.leo;

// The `program` scope defines the data types, functions, and state associated with the `token` program.
program arc20.aleo {
    // On-chain storage of an `account` map, with `address` as the key,
    // and `u64` as the value.
    mapping account: address => u64;

    record token {
        // The token owner.
        owner: address,
        // The token amount.
        amount: u64,
    }

    /////////////////////
    //// MINT & BURN ////
    /////////////////////

    transition mint_public() {
        // Custom logic for minting ARC20 tokens publicly
    }
    transition mint_private() {
        // Custom logic for minting ARC20 tokens privately
    }
    transition burn_public() {
        // Custom logic for burning ARC20 tokens publicly
    }
    transition burn_private() {
        // Custom logic for burning ARC20 tokens privately
    }

    ////////////////////
    //// TRANSFERS ////
    ///////////////////

    transition transfer_public(public receiver: address, public amount: u64) {
        // Transfer the tokens publicly, by invoking the computation on-chain.
        return then finalize(self.caller, receiver, amount);
    }

    finalize transfer_public(public sender: address, public receiver: address, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `account[sender]` does not exist, it will be created.
        // If `account[sender] - amount` underflows, `transfer_public` is reverted.
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
        
        // Increments `account[receiver]` by `amount`.
        // If `account[receiver]` does not exist, it will be created.
        // If `account[receiver] + amount` overflows, `transfer_public` is reverted.
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    // The function `transfer_private` sends the specified token amount to the token receiver from the specified token record.
    transition transfer_private(sender: token, receiver: address, amount: u64) -> (token, token) {
        // Checks the given token record has sufficient balance.
        // This `sub` operation is safe, and the proof will fail if an overflow occurs.
        // `difference` holds the change amount to be returned to sender.
        let difference: u64 = sender.amount - amount;

        // Produce a token record with the change amount for the sender.
        let remaining: token = token {
            owner: sender.owner,
            amount: difference,
        };

        // Produce a token record for the specified receiver.
        let transferred: token = token {
            owner: receiver,
            amount: amount,
        };

        // Output the sender's change record and the receiver's record.
        return (remaining, transferred);
    }

    // The function `transfer_private_to_public` turns a specified token amount from a token record into public tokens for the specified receiver.
    // This function preserves privacy for the sender's record, however it publicly reveals the token receiver and the token amount.
    transition transfer_private_to_public(sender: token, public receiver: address, public amount: u64) -> token {
        // Checks the given token record has a sufficient token amount.
        // This `sub` operation is safe, and the proof will fail if an underflow occurs.
        // `difference` holds the change amount for the caller.
        let difference: u64 = sender.amount - amount;

        // Produces a token record with the change amount for the caller.
        let remaining: token = token {
            owner: sender.owner,
            amount: difference,
        };

        // Output the sender's change record.
        // Increment the token amount publicly for the token receiver.
        return remaining then finalize(receiver, amount);
    }

    finalize transfer_private_to_public(public receiver: address, public amount: u64) {
        // Increments `account[receiver]` by `amount`.
        // If `account[receiver]` does not exist, it will be created.
        // If `account[receiver] + amount` overflows, `transfer_private_to_public` is reverted.
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    // The function `transfer_public_to_private` turns a specified token amount from `account` into a token record for the specified receiver.
    // This function preserves privacy for the receiver's record, however it publicly reveals the caller and the specified token amount.
    transition transfer_public_to_private(public receiver: address, public amount: u64) -> token {
        // Produces a token record for the token receiver.
        let transferred: token = token {
            owner: receiver,
            amount: amount,
        };

        // Output the receiver's record.
        // Decrement the token amount of the caller publicly.
        return transferred then finalize(self.caller, amount);
    }

    finalize transfer_public_to_private(public sender: address, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `account[sender]` does not exist, it will be created.
        // If `account[sender] - amount` underflows, `transfer_public_to_private` is reverted.
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
    }

    ///////////////////////
    //// WRAP & UNWRAP ////
    ///////////////////////

    // The function `wrap_public` mints wrapped ARC20 token in the registry by burning tokens here publicly.
    transition wrap_public(public amount: u64) {
        // In the registry program, increments `arc20account[(arc20, receiver)]` by `amount`.
        // If `arc20account[(arc20, receiver)]` does not exist, it will be created.
        // If `arc20account[(arc20, receiver)] + amount` overflows, the transition is reverted.
        arc20_registry.leo/mint_public_to_registry(self.caller, amount);

        return then finalize(self.caller, amount);
    }

    finalize wrap_public(public sender: address, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `account[sender]` does not exist, it will be created.
        // If `account[sender] - amount` underflows, `transfer_public` is reverted.
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
    }

    // The function `wrap_private` mints wrapped ARC20 record in the registry by burning tokens here privately.
    transition wrap_private(sender: token, amount: u64) -> (token, arc20_registry.leo/ARC20Token.record) {
        // Checks the given token record has sufficient balance.
        // This `sub` operation is safe, and the proof will fail if an overflow occurs.
        // `difference` holds the unwrapped sender.
        let difference: u64 = sender.amount - amount;

        // Produce a token record with the unwrapped amount for the sender.
        let unwrapped: token = token {
            owner: sender.owner,
            amount: difference,
        };

        // Produce a Wrapped ARC20 token record at the registry.
        let arc20wrapped: ARC20Token = arc20_registry.leo/mint_private_to_registry(self.caller, amount);

        // Output the sender's unwrapped and wrapped token.
        return (unwrapped, arc20wrapped);
    }

    // The function `unwrap_public` burns wrapped ARC20 record in the registry and mints tokens here publicly.
    transition unwrap_public(public amount: u64) {
        // Wrap the tokens to the registry publicly.
        // Decrements `arc20account[receiver]` by `amount` on the **token_registry**.
        // If `arc20account[receiver]` does not exist, it will be created.
        // If `arc20account[receiver] + amount` overflows, `arc20registry/mint` is reverted.
        arc20_registry.leo/mint_public_to_registry(self.caller, amount);

        return then finalize(self.caller, amount);
    }

    finalize unwrap_public(public sender: address, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `account[sender]` does not exist, it will be created.
        // If `account[sender] - amount` underflows, `transfer_public` is reverted.
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
    }

    // The function `unwrap_public` burns wrapped ARC20 record in the registry and mints tokens here privately.
    transition unwrap_private(sender: arc20_registry.leo/ARC20Token.record) -> token {
        // Produce a token record for the specified receiver.
        arc20_registry.leo/burn_private_from_arc20(sender);

        let unwrapped: token = token {
            owner: sender.owner,
            amount: sender.amount,
        };

        // Output the sender's change record and the receiver's record.
        return unwrapped;
    }


}