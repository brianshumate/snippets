# Wed Feb 4 18:03:36.334143 CST 3: (bucket_name) DCP (Producer) eq_dcpq:cbbackup-qeYHjBNEGfOVoQKb - (vb 99) stream created with start seqno 0 and end seqno 381517
# Wed Feb 4 18:03:36.433578 CST 3: (bucket_name) DCP (Producer) eq_dcpq:cbbackup-qeYHjBNEGfOVoQKb - (vb 99) Sending disk snapshot with start seqno 0 and end seqno 381517
# Wed Feb 4 18:03:36.436566 CST 3: (bucket_name) DCP (Producer) eq_dcpq:cbbackup-qeYHjBNEGfOVoQKb - (vb 99) Backfill complete, 0 items read from disk, last seqno read: 381507
# Wed Feb 4 18:03:36.436577 CST 3: (bucket_name) Backfill task (1 to 381517) finished for vb 99 disk seqno 381517 memory seqno 381517

/Sending .* end seqno/ {
    match($0, /\(vb [0-9][0-9]+\)/)
    vb = substr($0, RSTART+4, RLENGTH-5)

    match($0, /DCP \(Producer\) .* \(vb/)
    task = substr($0, RSTART+15, RLENGTH-21)

    match($0, /end seqno [0-9][0-9]*/)
    vbuckets[vb task] = substr($0, RSTART+10, RLENGTH-10)
}

# Wed Feb 4 18:03:36.436566 CST 3: (bucket_name) DCP (Producer) eq_dcpq:cbbackup-qeYHjBNEGfOVoQKb - (vb 99) Backfill complete, 0 items read from disk, last seqno read: 381507
/Backfill complete.* last seqno read:/ {
    match($0, /\(vb [0-9][0-9]+\)/)
    vb = substr($0, RSTART+4, RLENGTH-5)

    match($0, /DCP \(Producer\) .* \(vb/)
    task = substr($0, RSTART+15, RLENGTH-21)

    match($0, /last seqno read: [0-9][0-9]*/)
    seqno = substr($0, RSTART+17, RLENGTH-17)

    if(vbuckets[vb task]) {
        if(vbuckets[vb task] - seqno != 0) {
            print($2, $3, $4, $5, "vbucket " vb " appears stuck. seqno " vbuckets[vb task] " read " seqno " task " task)
        }
    }

}
