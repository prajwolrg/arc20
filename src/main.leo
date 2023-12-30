// arc20_wrapper.aleo must import both arc20_registry and arc20 token
import arc20_registry.leo;
import arc20.leo;

// The `program` scope defines the data types, functions, and state associated with the `token` program.
program arc20_wrapper.aleo {

    inline this() -> address {
        // return arc20_wrapper.aleo as address;
        return aleo1m7k6734jdlyyar8z7w8wxk6rpnz8w9j88k4kw0nmdtdrcjt2kgqqhfzyyf;
    }

    inline arc20_registry() -> address {
        // return arc20_registry.aleo as address;
        return aleo15u0eqqaguttgc9a5hvhlmljnv2axvkrk8zuu8ckmfz722qxqnsqqjyhrgd;
    }

    // The function `wrap_private` mints wrapped ARC20 record in the registry by locking tokens here privately.
    transition wrap_private(sender: arc20.leo/token.record, amount: u64) -> (arc20.leo/token.record, arc20_registry.leo/ARC20Token.record) {

        // Produce a new token after subtracting `amount` from `sender`
        let remaining: token = arc20.leo/transfer_private_to_public(sender, this(), amount);

        // Produce a Wrapped ARC20 token record at the registry.
        let arc20wrapped: ARC20Token = arc20_registry.leo/mint_private_to_registry(self.caller, amount);

        // Output the sender's unwrapped and wrapped token.
        return (remaining, arc20wrapped);
    }

    // The function `unwrap_public` burns wrapped ARC20 record in the registry and unlock tokens previously locked here.
    transition unwrap_private(sender: arc20_registry.leo/ARC20Token.record) -> token {
        // Burn the ARC20Token
        arc20_registry.leo/burn_private_from_registry(sender);

        // Unlock the corresponding amount of token
        let unwrapped: token = arc20.leo/transfer_public_to_private(sender.owner, sender.amount);

        // Output the sender's change record and the receiver's record.
        return unwrapped;
    }

    // The function `wrap_public` mints wrapped ARC20 record in the registry by locking actual tokens here.
    transition wrap_public(amount: u64) {

        // Locks `amount` from caller in this contract
        // Prior to calling this the caller should approve at least `amount` in arc20 program.
        arc20.leo/transfer_from_public(self.caller, this(), amount);

        // Mints the wrapped token
        arc20_registry.leo/mint_public_to_registry(self.caller, amount);
    }

    // The function `unwrap_public` burns wrapped amount in the registry and unlock actual tokens that was previously locked here.
    transition unwrap_public(amount: u64) {
        // Burns the `amount`
        arc20_registry.leo/burn_public_from_registry(self.caller, amount);

        // Unlocks the 
        arc20.leo/transfer_public(self.caller, amount);
    }



}