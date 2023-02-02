#!/usr/bin/env bash
sed -i -e '/void user_revoke(struct key \*key)/{n;a\
\tprintk("V1me: revoke key ========");
}' security/keys/user_defined.c 

sed -i -e '/static void user_free_payload_rcu(struct rcu_head \*head)/{n;a\
\tprintk("V1me: free payload callback ========");
}' security/keys/user_defined.c