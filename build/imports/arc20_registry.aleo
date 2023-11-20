program arc20_registry.aleo;

struct ARC20Account:
    arc20 as address;
    user as address;

struct ARC20Approval:
    arc20 as address;
    user as address;
    spender as address;

record ARC20Token:
    owner as address.private;
    arc20 as address.private;
    amount as u64.private;


mapping arc20balances:
	key as ARC20Account.public;
	value as u64.public;


mapping arc20approvals:
	key as ARC20Approval.public;
	value as u64.public;

function mint_public_to_registry:
    input r0 as address.public;
    input r1 as u64.public;
    async mint_public_to_registry self.caller r0 r1 into r2;
    output r2 as arc20_registry.aleo/mint_public_to_registry.future;

finalize mint_public_to_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast r0 r1 into r3 as ARC20Account;
    get.or_use arc20balances[r3] 0u64 into r4;
    add r4 r2 into r5;
    set r5 into arc20balances[r3];


function mint_private_to_registry:
    input r0 as address.private;
    input r1 as u64.private;
    cast r0 self.caller r1 into r2 as ARC20Token.record;
    output r2 as ARC20Token.record;


function burn_public_from_registry:
    input r0 as address.public;
    input r1 as u64.public;
    async burn_public_from_registry self.caller r0 r1 into r2;
    output r2 as arc20_registry.aleo/burn_public_from_registry.future;

finalize burn_public_from_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast r0 r1 into r3 as ARC20Account;
    get arc20balances[r3] into r4;
    sub r4 r2 into r5;
    set r5 into arc20balances[r3];


function burn_private_from_registry:
    input r0 as ARC20Token.record;
    assert.eq r0.arc20 self.caller;


function transfer_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    async transfer_public_in_registry self.caller r0 r1 r2 into r3;
    output r3 as arc20_registry.aleo/transfer_public_in_registry.future;

finalize transfer_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as address.public;
    input r3 as u64.public;
    cast r0 r1 into r4 as ARC20Account;
    get arc20balances[r4] into r5;
    sub r5 r3 into r6;
    set r6 into arc20balances[r4];
    cast r0 r2 into r7 as ARC20Account;
    get.or_use arc20balances[r7] 0u64 into r8;
    add r8 r3 into r9;
    set r9 into arc20balances[r7];


function transfer_private_in_registry:
    input r0 as ARC20Token.record;
    input r1 as address.private;
    input r2 as u64.private;
    sub r0.amount r2 into r3;
    cast r0.owner r0.arc20 r3 into r4 as ARC20Token.record;
    cast r1 r0.arc20 r2 into r5 as ARC20Token.record;
    output r4 as ARC20Token.record;
    output r5 as ARC20Token.record;


function transfer_private_to_public_in_registry:
    input r0 as ARC20Token.record;
    input r1 as address.public;
    input r2 as u64.public;
    sub r0.amount r2 into r3;
    cast r0.owner r0.arc20 r3 into r4 as ARC20Token.record;
    async transfer_private_to_public_in_registry r0.arc20 r1 r2 into r5;
    output r4 as ARC20Token.record;
    output r5 as arc20_registry.aleo/transfer_private_to_public_in_registry.future;

finalize transfer_private_to_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast r0 r1 into r3 as ARC20Account;
    get.or_use arc20balances[r3] 0u64 into r4;
    add r4 r2 into r5;
    set r5 into arc20balances[r3];


function transfer_public_to_private_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast r1 r0 r2 into r3 as ARC20Token.record;
    async transfer_public_to_private_in_registry r0 self.caller r2 into r4;
    output r3 as ARC20Token.record;
    output r4 as arc20_registry.aleo/transfer_public_to_private_in_registry.future;

finalize transfer_public_to_private_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast r0 r1 into r3 as ARC20Account;
    get arc20balances[r3] into r4;
    sub r4 r2 into r5;
    set r5 into arc20balances[r3];


function approve_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    async approve_public_in_registry self.caller r0 r1 r2 into r3;
    output r3 as arc20_registry.aleo/approve_public_in_registry.future;

finalize approve_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as address.public;
    input r3 as u64.public;
    cast r0 r1 r2 into r4 as ARC20Approval;
    get.or_use arc20approvals[r4] 0u64 into r5;
    add r5 r3 into r6;
    set r6 into arc20approvals[r4];


function unapprove_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    async unapprove_public_in_registry self.caller r0 r1 r2 into r3;
    output r3 as arc20_registry.aleo/unapprove_public_in_registry.future;

finalize unapprove_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as address.public;
    input r3 as u64.public;
    cast r0 r1 r2 into r4 as ARC20Approval;
    get arc20approvals[r4] into r5;
    sub r5 r3 into r6;
    set r6 into arc20approvals[r4];


function transfer_from_public:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as address.public;
    input r3 as u64.public;
    async transfer_from_public r0 r1 r2 r3 self.caller into r4;
    output r4 as arc20_registry.aleo/transfer_from_public.future;

finalize transfer_from_public:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as address.public;
    input r3 as u64.public;
    input r4 as address.public;
    cast r0 r1 r4 into r5 as ARC20Approval;
    get arc20approvals[r5] into r6;
    sub r6 r3 into r7;
    set r7 into arc20approvals[r5];
    cast r0 r1 into r8 as ARC20Account;
    get arc20balances[r8] into r9;
    sub r9 r3 into r10;
    set r10 into arc20balances[r8];
    cast r0 r2 into r11 as ARC20Account;
    get.or_use arc20balances[r11] 0u64 into r12;
    add r12 r3 into r13;
    set r13 into arc20balances[r11];
