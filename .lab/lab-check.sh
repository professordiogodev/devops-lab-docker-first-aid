#!/usr/bin/env bash
rc=0
n=0
for c in fa-db fa-web fa-crashloop fa-chatty fa-mystery; do grep -qE "^- $c: .{20,}" notes.md 2>/dev/null && n=$((n+1)); done
if [ "$n" -eq 5 ]; then echo "- ✅ notes.md describes all five containers"; else echo "- ❌ notes.md needs one real sentence (20+ characters) for each of the 5 containers ($n/5)"; rc=1; fi
grep -qE '^ALL CHECKS PASSED \(' SUBMISSION.md && echo "- ✅ SUBMISSION.md shows ALL CHECKS PASSED" || { echo "- ❌ paste the verify.sh output ('ALL CHECKS PASSED') into SUBMISSION.md"; rc=1; }
exit $rc
