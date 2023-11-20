program arc20_registry.aleo {

    struct Arc20User {
        // ARC20 Token Address
        arc20: address,
        // Token Owner
        user: address
    }

    // On-chain storage of an `balances` map, with `(arc20, user)` as the key,
    // and `u64` as the value.
    mapping arc20balances: Arc20User => u64;

    // On-chain storage of an `approvals` map, with `(arc20, user)` as the key,
    // and `u64` as the value.
    mapping arc20approvals: Arc20User => u64;

    record ARC20Token {
        // The token owner.
        owner: address,
        // ARC20 Token Address
        arc20: address,
        // The token amount.
        amount: u64,
    }


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
        let receiverAccount: Arc20User = Arc20User {
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
        let receiverAccount: Arc20User = Arc20User {
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


}