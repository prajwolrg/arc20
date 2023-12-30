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
	key as field.public;
	value as u64.public;


mapping arc20approvals:
	key as field.public;
	value as u64.public;

function mint_public_to_registry:
    input r0 as address.public;
    input r1 as u64.public;
    cast self.caller r0 into r2 as ARC20Account;
    hash.bhp256 r2 into r3 as field;
    async mint_public_to_registry r3 r1 into r4;
    output r4 as arc20_registry.aleo/mint_public_to_registry.future;

finalize mint_public_to_registry:
    input r0 as field.public;
    input r1 as u64.public;
    get.or_use arc20balances[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into arc20balances[r0];


function mint_private_to_registry:
    input r0 as address.private;
    input r1 as u64.private;
    cast r0 self.caller r1 into r2 as ARC20Token.record;
    output r2 as ARC20Token.record;


function burn_public_from_registry:
    input r0 as address.public;
    input r1 as u64.public;
    cast self.caller r0 into r2 as ARC20Account;
    hash.bhp256 r2 into r3 as field;
    async burn_public_from_registry r3 r1 into r4;
    output r4 as arc20_registry.aleo/burn_public_from_registry.future;

finalize burn_public_from_registry:
    input r0 as field.public;
    input r1 as u64.public;
    get arc20balances[r0] into r2;
    sub r2 r1 into r3;
    set r3 into arc20balances[r0];


function burn_private_from_registry:
    input r0 as ARC20Token.record;
    assert.eq r0.arc20 self.caller;


function transfer_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast r0 self.caller into r3 as ARC20Account;
    hash.bhp256 r3 into r4 as field;
    cast r0 r1 into r5 as ARC20Account;
    hash.bhp256 r5 into r6 as field;
    async transfer_public_in_registry r0 r4 r6 r2 into r7;
    output r7 as arc20_registry.aleo/transfer_public_in_registry.future;

finalize transfer_public_in_registry:
    input r0 as address.public;
    input r1 as field.public;
    input r2 as field.public;
    input r3 as u64.public;
    get arc20balances[r1] into r4;
    sub r4 r3 into r5;
    set r5 into arc20balances[r1];
    get.or_use arc20balances[r2] 0u64 into r6;
    add r6 r3 into r7;
    set r7 into arc20balances[r2];


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
    cast r0.arc20 r1 into r5 as ARC20Account;
    hash.bhp256 r5 into r6 as field;
    async transfer_private_to_public_in_registry r6 r2 into r7;
    output r4 as ARC20Token.record;
    output r7 as arc20_registry.aleo/transfer_private_to_public_in_registry.future;

finalize transfer_private_to_public_in_registry:
    input r0 as field.public;
    input r1 as u64.public;
    get.or_use arc20balances[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into arc20balances[r0];


function transfer_public_to_private_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast r1 r0 r2 into r3 as ARC20Token.record;
    cast r0 self.caller into r4 as ARC20Account;
    hash.bhp256 r4 into r5 as field;
    async transfer_public_to_private_in_registry r5 r2 into r6;
    output r3 as ARC20Token.record;
    output r6 as arc20_registry.aleo/transfer_public_to_private_in_registry.future;

finalize transfer_public_to_private_in_registry:
    input r0 as field.public;
    input r1 as u64.public;
    get arc20balances[r0] into r2;
    sub r2 r1 into r3;
    set r3 into arc20balances[r0];


function approve_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast self.caller r0 r1 into r3 as ARC20Approval;
    hash.bhp256 r3 into r4 as field;
    async approve_public_in_registry r4 r2 into r5;
    output r5 as arc20_registry.aleo/approve_public_in_registry.future;

finalize approve_public_in_registry:
    input r0 as field.public;
    input r1 as u64.public;
    get.or_use arc20approvals[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into arc20approvals[r0];


function unapprove_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast self.caller r0 r1 into r3 as ARC20Approval;
    hash.bhp256 r3 into r4 as field;
    async unapprove_public_in_registry r4 r2 into r5;
    output r5 as arc20_registry.aleo/unapprove_public_in_registry.future;

finalize unapprove_public_in_registry:
    input r0 as field.public;
    input r1 as u64.public;
    get arc20approvals[r0] into r2;
    sub r2 r1 into r3;
    set r3 into arc20approvals[r0];


function transfer_from_public_in_registry:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as address.public;
    input r3 as u64.public;
    cast self.caller r1 self.caller into r4 as ARC20Approval;
    hash.bhp256 r4 into r5 as field;
    cast r0 r1 into r6 as ARC20Account;
    hash.bhp256 r6 into r7 as field;
    cast r0 r1 into r8 as ARC20Account;
    hash.bhp256 r8 into r9 as field;
    async transfer_from_public_in_registry r7 r9 r3 r5 into r10;
    output r10 as arc20_registry.aleo/transfer_from_public_in_registry.future;

finalize transfer_from_public_in_registry:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as field.public;
    get arc20approvals[r3] into r4;
    sub r4 r2 into r5;
    set r5 into arc20approvals[r3];
    get arc20balances[r0] into r6;
    sub r6 r2 into r7;
    set r7 into arc20balances[r0];
    get.or_use arc20balances[r1] 0u64 into r8;
    add r8 r2 into r9;
    set r9 into arc20balances[r1];
