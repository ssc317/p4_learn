// This is P4 sample source for myp4
// Fill in these files with your P4 code

#include "includes/headers.p4"
#include "includes/parser.p4"


action _drop() {
    drop();
}

action _nop() {
}

header_type intrinsic_metadata_t {
    fields {
        mcast_grp : 4;
        egress_rid : 4;
        mcast_hash : 16;
        lf_field_list: 32;
    }
}

metadata intrinsic_metadata_t intrinsic_metadata;


#define MAC_LEARN_RECEIVER 1024

field_list mac_learn_digest {
    ethernet.srcAddr;
    standard_metadata.ingress_port;
}
action mac_learn() {
    generate_digest(MAC_LEARN_RECEIVER, mac_learn_digest);
}
table smac {
    reads {
        ethernet.srcAddr : exact;
    }
    actions {mac_learn; _nop;}
    size : 512;
}


action forward(port) {
    modify_field(standard_metadata.egress_spec, port);
}
action broadcast() {
    modify_field(intrinsic_metadata.mcast_grp, 1);
}
table dmac {
    reads {
        ethernet.dstAddr : exact;
    }
    actions {
        forward;
	broadcast;
    }
    size : 512;
}

table mcast_src_pruning {
    reads {
        standard_metadata.instance_type : exact;
    }
    actions {_nop; _drop;}
    size : 1;
}

action rewrite_mac() {
    
}
table send_frame {
    reads {
	standard_metadata.egress_port : exact;
    }
    actions {
	rewrite_mac;
	_drop;
    }
    size : 512;
}

control ingress {
    apply(smac);
    apply(dmac);
}

control egress {
    /*if (standard_metadata.ingress_port == standard_metadata.egress_port) {
	apply(mcast_src_pruning);
    }*/
    //apply(send_frame);
    
}

