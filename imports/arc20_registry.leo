program arc20_registry.aleo {

    struct ARC20Account {
        // ARC20 Token Address
        arc20: address,
        // Token Owner
        user: address
    }

    struct ARC20Approval {
        // ARC20 Token Address
        arc20: address,
        // Token Owner
        user: address,
        // Spender Address
        spender: address
    }

    // On-chain storage of an `balances` map, with `(arc20, user)` as the key,
    // and `u64` as the value.
    mapping arc20balances: ARC20Account => u64;

    // On-chain storage of an `approvals` map, with `(arc20, user)` as the key,
    // and `u64` as the value.
    mapping arc20approvals: ARC20Approval => u64;

    record ARC20Token {
        // The token owner.
        owner: address,
        // ARC20 Token Address
        arc20: address,
        // The token amount.
        amount: u64,
    }

    /////////////////////
    //// MINT & BURN ////
    /////////////////////

    // The function `mint_public_to_registry` issues the specified token amount for the token receiver publicly on the network.
    // This function is expected to be called from ARC20 program
    // But calling from any other program should not cause unexpected behavior
    transition mint_public_to_registry(public receiver: address, public amount: u64) {
        // Mint the tokens publicly by invoking the computation on-chain.
        return then finalize(self.caller, receiver, amount);
    }

    finalize mint_public_to_registry(public arc20: address, public receiver: address, public amount: u64) {
        // Increments `arc20balances[(arc20, receiver)]` by `amount`.
        // If `arc20balances[(arc20, receiver)]` does not exist, it will be created.
        // If `arc20balances[(arc20, receiver)] + amount` overflows, the transition is reverted.
        let receiverAccount: ARC20Account = ARC20Account {
            arc20,
            user: receiver
        };
        let receiver_amount: u64 = Mapping::get_or_use(arc20balances, receiverAccount, 0u64);
        Mapping::set(arc20balances, receiverAccount, receiver_amount + amount);
    }

    // The function `mint_private_to_registry` initializes a new ARC20Token record with the specified amount of tokens for the receiver.
    // This function is expected to be called from ARC20 program
    // But calling from any other program should not cause unexpected behavior
    transition mint_private_to_registry(receiver: address, amount: u64) -> ARC20Token {
        return ARC20Token {
            owner: receiver,
            arc20: self.caller,
            amount: amount,
        };
    }

    // The function `burn_public_from_registry` issues the specified token amount for the token receiver publicly on the network.
    transition burn_public_from_registry(public receiver: address, public amount: u64) {
        // Mint the tokens publicly by invoking the computation on-chain.
        return then finalize(self.caller, receiver, amount);
    }

    finalize burn_public_from_registry(public arc20: address, public receiver: address, public amount: u64) {
        // Decrements `arc20balances[(arc20, receiver)]` by `amount`.
        // If `arc20balances[(arc20, receiver)]` does not exist, the transition is reverted.
        // If `arc20balances[(arc20, receiver)] - amount` underflows, the transition is reverted.
        let receiverAccount: ARC20Account = ARC20Account {
            arc20,
            user: receiver
        };
        let receiver_amount: u64 = Mapping::get(arc20balances, receiverAccount);
        Mapping::set(arc20balances, receiverAccount, receiver_amount - amount);
    }

    // The function `burn_private_from_registry` initializes a new record with the specified amount of tokens for the receiver.
    transition burn_private_from_registry(arc20token: ARC20Token) {
        assert_eq(arc20token.arc20, self.caller);
        return;
    }

    ////////////////////
    //// TRANSFERS ////
    ///////////////////

    transition transfer_public_in_registry(public sender: address, public receiver: address, public amount: u64) {
        // Transfer the tokens publicly, by invoking the computation on-chain.
        return then finalize(self.caller, sender, receiver, amount);
    }

    finalize transfer_public_in_registry(public arc20: address, public sender: address, public receiver: address, public amount: u64) {
        // Decrements `arc20balances[(arc20, sender)]` by `amount`.
        // If `arc20balances[(arc20, receiver)]` does not exist, it will be created.
        // If `arc20balances[(arc20, receiver)] - amount` underflows, the transition is reverted.
        let sender_account: ARC20Account = ARC20Account {
            arc20,
            user: sender
        };
        let sender_amount: u64 = Mapping::get(arc20balances, sender_account);
        Mapping::set(arc20balances, sender_account, sender_amount - amount);

        // Increments `arc20balances[(arc20, receiver)]` by `amount`.
        // If `arc20balances[(arc20, receiver)]` does not exist, it will be created.
        // If `arc20balances[(arc20, receiver)] - amount` underflows, the transition is reverted.
        let receiver_account: ARC20Account = ARC20Account {
            arc20,
            user: receiver
        };
        let receiver_amount: u64 = Mapping::get_or_use(arc20balances, receiver_account, 0u64);
        Mapping::set(arc20balances, receiver_account, receiver_amount + amount);
        
    }

    // The function `transfer_private_in_registry` sends the specified token amount to the token receiver from the specified ARC20Token record.
    transition transfer_private_in_registry(sender: ARC20Token, receiver: address, amount: u64) -> (ARC20Token, ARC20Token) {
        // Checks the given ARC20Token record has sufficient balance.
        // This `sub` operation is safe, and the proof will fail if an overflow occurs.
        // `difference` holds the change amount to be returned to sender.
        let difference: u64 = sender.amount - amount;

        // Produce a ARC20Token record with the change amount for the sender.
        let remaining: ARC20Token = ARC20Token {
            owner: sender.owner,
            arc20: sender.arc20,
            amount: difference,
        };

        // Produce a ARC20Token record for the specified receiver.
        let transferred: ARC20Token = ARC20Token {
            owner: receiver,
            arc20: sender.arc20,
            amount: amount,
        };

        // Output the sender's change record and the receiver's record.
        return (remaining, transferred);
    }

    // The function `transfer_private_to_public_in_registry` turns a specified token amount from a ARC20Token record into public tokens for the specified receiver.
    // This function preserves privacy for the sender's record, however it publicly reveals the token receiver and the token amount.
    transition transfer_private_to_public_in_registry(sender: ARC20Token, public receiver: address, public amount: u64) -> ARC20Token {
        // Checks the given ARC20Token record has a sufficient token amount.
        // This `sub` operation is safe, and the proof will fail if an underflow occurs.
        // `difference` holds the change amount for the caller.
        let difference: u64 = sender.amount - amount;

        // Produces a ARC20Token record with the change amount for the caller.
        let remaining: ARC20Token = ARC20Token {
            owner: sender.owner,
            arc20: sender.arc20,
            amount: difference,
        };

        // Output the sender's change record.
        // Increment the token amount publicly for the token receiver.
        return remaining then finalize(sender.arc20, receiver, amount);
    }

    finalize transfer_private_to_public_in_registry(public arc20: address, public receiver: address, public amount: u64) {
        // Increments `arc20balances[(arc20, receiver)]` by `amount`.
        // If `arc20balances[(arc20, receiver)]` does not exist, it will be created.
        // If `arc20balances[(arc20, receiver)] - amount` underflows, the transition is reverted.
        let receiver_account: ARC20Account = ARC20Account {
            arc20,
            user: receiver
        };
        let receiver_amount: u64 = Mapping::get_or_use(arc20balances, receiver_account, 0u64);
        Mapping::set(arc20balances, receiver_account, receiver_amount + amount);
    }

    // The function `transfer_public_in_registry_to_private` turns a specified token amount from `account` into a ARC20Token record for the specified receiver.
    // This function preserves privacy for the receiver's record, however it publicly reveals the caller and the specified token amount.
    transition transfer_public_to_private_in_registry(public arc20: address, public receiver: address, public amount: u64) -> ARC20Token {
        // Produces a ARC20Token record for the token receiver.
        let transferred: ARC20Token = ARC20Token {
            owner: receiver,
            arc20,
            amount: amount,
        };

        // Output the receiver's record.
        // Decrement the token amount of the caller publicly.
        return transferred then finalize(arc20, self.caller, amount);
    }

    finalize transfer_public_to_private_in_registry(public arc20: address, public sender: address, public amount: u64) {
        // Decrements `arc20balances[(arc20, sender)]` by `amount`.
        // If `arc20balances[(arc20, receiver)]` does not exist, it will be created.
        // If `arc20balances[(arc20, receiver)] - amount` underflows, the transition is reverted.
        let sender_account: ARC20Account = ARC20Account {
            arc20,
            user: sender
        };
        let sender_amount: u64 = Mapping::get(arc20balances, sender_account);
        Mapping::set(arc20balances, sender_account, sender_amount - amount);
    }

    // The function `approve_public_in_registry` approves the specified token amount for the spender to be publicly spent on the network.
    // This function is expected to be called from ARC20 program
    // But calling from any other program should not cause unexpected behavior
    transition approve_public_in_registry(public user: address, public spender: address, public amount: u64) {
        return then finalize(self.caller, user, spender, amount);
    }

    finalize approve_public_in_registry(arc20: address, user: address, spender: address, amount: u64) {
        // Increments `arc20approvals[(arc20, user, spender)]` by `amount`.
        // If `arc20approvals[(arc20, user, spender)]` does not exist, it will be created.
        // If `arc20balances[(arc20, user, spender)] + amount` overflows, the transition is reverted.
        let approval: ARC20Approval = ARC20Approval {
            arc20,
            user,
            spender
        };
        let approval_amount: u64 = Mapping::get_or_use(arc20approvals, approval, 0u64);
        Mapping::set(arc20approvals, approval, approval_amount + amount);
    }

    // The function `unapprove_public_in_registry` removes the approval of the specified token amount for the spender.
    // This function is expected to be called from ARC20 program
    // But calling from any other program should not cause unexpected behavior
    transition unapprove_public_in_registry(public user: address, public spender: address, public amount: u64) {
        return then finalize(self.caller, user, spender, amount);
    }

    finalize unapprove_public_in_registry(arc20: address, user: address, spender: address, amount: u64) {
        // Decrements `arc20approvals[(arc20, user, spender)]` by `amount`.
        // If `arc20approvals[(arc20, user, spender)]` does not exist, the transition is created.
        // If `arc20balances[(arc20, user, spender)] - amount` underflows, the transition is reverted.
        let approval: ARC20Approval = ARC20Approval {
            arc20,
            user,
            spender
        };
        let approval_amount: u64 = Mapping::get(arc20approvals, approval);
        Mapping::set(arc20approvals, approval, approval_amount - amount);
    }

    transition transfer_from_public(public arc20: address, public from: address, public to: address, public amount: u64) {
        return then finalize(arc20, from, to, amount, self.caller);
    }

    finalize transfer_from_public(arc20: address, from: address, to: address, amount: u64, spender: address) {
        // Decrements `arc20approvals[(arc20, user, spender)]` by `amount`.
        // If `arc20approvals[(arc20, user, spender)]` does not exist, the transition is created.
        // If `arc20balances[(arc20, user, spender)] - amount` underflows, the transition is reverted.
        let approval: ARC20Approval = ARC20Approval {
            arc20,
            user: from,
            spender
        };

        let approval_amount: u64 = Mapping::get(arc20approvals, approval);
        Mapping::set(arc20approvals, approval, approval_amount - amount);

        // Decrements `arc20balances[(arc20, sender)]` by `amount`.
        // If `arc20balances[(arc20, receiver)]` does not exist, it will be created.
        // If `arc20balances[(arc20, receiver)] - amount` underflows, the transition is reverted.
        let sender_account: ARC20Account = ARC20Account {
            arc20,
            user: from
        };
        let sender_amount: u64 = Mapping::get(arc20balances, sender_account);
        Mapping::set(arc20balances, sender_account, sender_amount - amount);


        // Increments `arc20balances[(arc20, receiver)]` by `amount`.
        // If `arc20balances[(arc20, receiver)]` does not exist, it will be created.
        // If `arc20balances[(arc20, receiver)] - amount` underflows, the transition is reverted.
        let receiver_account: ARC20Account = ARC20Account {
            arc20,
            user: to
        };
        let receiver_amount: u64 = Mapping::get_or_use(arc20balances, receiver_account, 0u64);
        Mapping::set(arc20balances, receiver_account, receiver_amount + amount);
    }

}