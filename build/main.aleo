import arc20_registry.aleo;
import arc20.aleo;
program arc20_wrapper.aleo;











function wrap_private:
    input r0 as arc20.aleo/token.record;
    input r1 as u64.private;
    call arc20.aleo/transfer_private_to_public r0 aleo1m7k6734jdlyyar8z7w8wxk6rpnz8w9j88k4kw0nmdtdrcjt2kgqqhfzyyf r1 into r2 r3;
    call arc20_registry.aleo/mint_private_to_registry self.caller r1 into r4;
    async wrap_private r3 into r5;
    output r2 as arc20.aleo/token.record;
    output r4 as arc20_registry.aleo/ARC20Token.record;
    output r5 as arc20_wrapper.aleo/wrap_private.future;

finalize wrap_private:
    input r0 as arc20.aleo/transfer_private_to_public.future;
    await r0;


function unwrap_private:
    input r0 as arc20_registry.aleo/ARC20Token.record;
    call arc20_registry.aleo/burn_private_from_registry r0;
    call arc20.aleo/transfer_public_to_private r0.owner r0.amount into r1 r2;
    async unwrap_private r2 into r3;
    output r1 as token.record;
    output r3 as arc20_wrapper.aleo/unwrap_private.future;

finalize unwrap_private:
    input r0 as arc20.aleo/transfer_public_to_private.future;
    await r0;


function wrap_public:
    input r0 as u64.private;
    call arc20.aleo/transfer_from_public self.caller aleo1m7k6734jdlyyar8z7w8wxk6rpnz8w9j88k4kw0nmdtdrcjt2kgqqhfzyyf r0 into r1;
    call arc20_registry.aleo/mint_public_to_registry self.caller r0 into r2;
    async wrap_public r1 r2 into r3;
    output r3 as arc20_wrapper.aleo/wrap_public.future;

finalize wrap_public:
    input r0 as arc20.aleo/transfer_from_public.future;
    input r1 as arc20_registry.aleo/mint_public_to_registry.future;
    await r0;
    await r1;


function unwrap_public:
    input r0 as u64.private;
    call arc20_registry.aleo/burn_public_from_registry self.caller r0 into r1;
    call arc20.aleo/transfer_public self.caller r0 into r2;
    async unwrap_public r1 r2 into r3;
    output r3 as arc20_wrapper.aleo/unwrap_public.future;

finalize unwrap_public:
    input r0 as arc20_registry.aleo/burn_public_from_registry.future;
    input r1 as arc20.aleo/transfer_public.future;
    await r0;
    await r1;
