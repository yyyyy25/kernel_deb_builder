#!/usr/bin/env bash
sed -i -e '/void user_revoke(struct key \*key)/{n;n;a\
\tprintk("V1me: revoke key -- %#lx ========\\n", upayload);
}' security/keys/user_defined.c 

sed -i -e '/static void user_free_payload_rcu(struct rcu_head \*head)/{n;a\
\tprintk("V1me: free payload callback ========\\n");
}' security/keys/user_defined.c

sed -i -e '/int user_update(struct key \*key, struct key_preparsed_payload \*prep)/{n;a\
\tprintk("V1me: update key -- %#lx ========\\n", prep->payload.data[0]);
}' security/keys/user_defined.c

# TODO: user_preparse