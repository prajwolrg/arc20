import arc20_registry.aleo;
program arc20.aleo;



record token:
    owner as address.private;
    amount as u64.private;


mapping account:
	key as address.public;
	value as u64.public;

function mint_public:
    input r0 as address.public;
    input r1 as u64.public;
    async mint_public r0 r1 into r2;
    output r2 as arc20.aleo/mint_public.future;

finalize mint_public:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into account[r0];


function mint_private:
    input r0 as address.private;
    input r1 as u64.private;
    cast r0 r1 into r2 as token.record;
    output r2 as token.record;


function transfer_public:
    input r0 as address.public;
    input r1 as u64.public;
    async transfer_public self.caller r0 r1 into r2;
    output r2 as arc20.aleo/transfer_public.future;

finalize transfer_public:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    get.or_use account[r0] 0u64 into r3;
    sub r3 r2 into r4;
    set r4 into account[r0];
    get.or_use account[r1] 0u64 into r5;
    add r5 r2 into r6;
    set r6 into account[r1];


function transfer_private:
    input r0 as token.record;
    input r1 as address.private;
    input r2 as u64.private;
    sub r0.amount r2 into r3;
    cast r0.owner r3 into r4 as token.record;
    cast r1 r2 into r5 as token.record;
    output r4 as token.record;
    output r5 as token.record;


function transfer_private_to_public:
    input r0 as token.record;
    input r1 as address.public;
    input r2 as u64.public;
    sub r0.amount r2 into r3;
    cast r0.owner r3 into r4 as token.record;
    async transfer_private_to_public r1 r2 into r5;
    output r4 as token.record;
    output r5 as arc20.aleo/transfer_private_to_public.future;

finalize transfer_private_to_public:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into account[r0];


function transfer_public_to_private:
    input r0 as address.public;
    input r1 as u64.public;
    cast r0 r1 into r2 as token.record;
    async transfer_public_to_private self.caller r1 into r3;
    output r2 as token.record;
    output r3 as arc20.aleo/transfer_public_to_private.future;

finalize transfer_public_to_private:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    sub r2 r1 into r3;
    set r3 into account[r0];


function wrap_public:
    input r0 as u64.public;
    call arc20_registry.aleo/mint_public_from_arc20 self.caller r0 into r1;
    async wrap_public r1 self.caller r0 into r2;
    output r2 as arc20.aleo/wrap_public.future;

finalize wrap_public:
    input r0 as arc20_registry.aleo/mint_public_from_arc20.future;
    input r1 as address.public;
    input r2 as u64.public;
    await r0;
    get.or_use account[r1] 0u64 into r3;
    sub r3 r2 into r4;
    set r4 into account[r1];


function wrap_private:
    input r0 as token.record;
    input r1 as u64.private;
    sub r0.amount r1 into r2;
    cast r0.owner r2 into r3 as token.record;
    call arc20_registry.aleo/mint_private_from_arc20 self.caller r1 into r4;
    output r3 as token.record;
    output r4 as arc20_registry.aleo/ARC20Token.record;
