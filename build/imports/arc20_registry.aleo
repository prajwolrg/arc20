program arc20_registry.aleo;

struct Arc20User:
    arc20 as address;
    user as address;

record ARC20Token:
    owner as address.private;
    arc20 as address.private;
    amount as u64.private;


mapping arc20account:
	key as Arc20User.public;
	value as u64.public;

function mint_public_from_arc20:
    input r0 as address.public;
    input r1 as u64.public;
    async mint_public_from_arc20 self.caller r0 r1 into r2;
    output r2 as arc20_registry.aleo/mint_public_from_arc20.future;

finalize mint_public_from_arc20:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast r0 r1 into r3 as Arc20User;
    get.or_use arc20account[r3] 0u64 into r4;
    add r4 r2 into r5;
    set r5 into arc20account[r3];


function mint_private_from_arc20:
    input r0 as address.private;
    input r1 as u64.private;
    cast r0 self.caller r1 into r2 as ARC20Token.record;
    output r2 as ARC20Token.record;
