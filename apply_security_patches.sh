#!/bin/bash
# apply_security_patches.sh
# Selectively cherry-picks upstream 5.4.y security commits onto the current branch.
# Commits that apply cleanly are committed automatically.
# Conflicts are skipped and logged for manual review.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/security_patch_results.log"
SKIP_LOG="$SCRIPT_DIR/security_patch_skipped.log"

# Clean up old logs
rm -f "$LOG_FILE" "$SKIP_LOG"

echo "=======================================================" | tee "$LOG_FILE"
echo "  Kirisakura Kernel - Security Patch Application"      | tee -a "$LOG_FILE"
echo "  $(date)"                                              | tee -a "$LOG_FILE"
echo "=======================================================" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# Get security-relevant commits (newest first → reverse for cherry-pick order)
SECURITY_COMMITS=$(git log --oneline stable/linux-5.4.y ^HEAD -- 2>/dev/null | grep -iE \
  "CVE|fix.*overflow|fix.*oob|fix.*out.of.bound|fix.*use.after.free|uaf|null.deref|fix.*race.condition|fix.*memory.leak|fix.*double.free|fix.*integer.*over|fix.*heap|fix.*slab" \
  | awk '{print $1}' | tac)

TOTAL=$(echo "$SECURITY_COMMITS" | wc -l)
APPLIED=0
SKIPPED=0
COUNT=0

echo "Found $TOTAL security commits to evaluate." | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

for COMMIT in $SECURITY_COMMITS; do
    COUNT=$((COUNT + 1))
    MSG=$(git log --oneline -1 "$COMMIT" 2>/dev/null)

    printf "[%3d/%d] Trying: %s\n" "$COUNT" "$TOTAL" "$MSG" | tee -a "$LOG_FILE"

    # Try to cherry-pick without committing to test applicability
    if git cherry-pick --no-commit -x "$COMMIT" 2>/dev/null; then
        # Check if there are any actual changes staged
        if git diff --cached --quiet; then
            git cherry-pick --abort 2>/dev/null || true
            git reset HEAD 2>/dev/null || true
            echo "         → SKIP (already applied)" | tee -a "$LOG_FILE"
            SKIPPED=$((SKIPPED + 1))
        else
            git commit --no-edit -q 2>/dev/null
            echo "         → APPLIED ✓" | tee -a "$LOG_FILE"
            echo "$MSG" >> "$SKIP_LOG.applied"
            APPLIED=$((APPLIED + 1))
        fi
    else
        # Conflict - abort and skip
        git cherry-pick --abort 2>/dev/null || true
        git reset --hard HEAD 2>/dev/null || true
        echo "         → SKIPPED (conflict)" | tee -a "$LOG_FILE"
        echo "$MSG" >> "$SKIP_LOG"
        SKIPPED=$((SKIPPED + 1))
    fi
done

echo | tee -a "$LOG_FILE"
echo "=======================================================" | tee -a "$LOG_FILE"
echo "  DONE: Applied=$APPLIED  Skipped=$SKIPPED  Total=$TOTAL" | tee -a "$LOG_FILE"
echo "  Full log:    security_patch_results.log"                | tee -a "$LOG_FILE"
echo "  Skipped:     security_patch_skipped.log"                | tee -a "$LOG_FILE"
echo "=======================================================" | tee -a "$LOG_FILE"
