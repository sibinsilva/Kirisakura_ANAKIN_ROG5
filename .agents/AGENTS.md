# Custom Project Rules

## KernelSU-Next Version Fallback
- **Rule:** When compiling KernelSU-Next inside this workspace, always verify that `KSU_VERSION_FALLBACK` in [Kbuild](file:///home/sibindev9746_gmail_com/Kirisakura_ANAKIN_ROG5/KernelSU-Next/kernel/Kbuild) is explicitly set to the desired version code (e.g., `33188`).
- **Context:** The dynamic Git repository check in the KernelSU-Next build system (`ifneq ($(GIT_ROOT),$(KERNEL_GIT_ROOT))`) evaluates to false because the directory is part of the main kernel tree, falling back to a lower version number if not overridden.

## KSUD_PATH Must Never Be Changed
- **Rule:** NEVER modify `KSUD_PATH` in [ksud.h](file:///home/sibindev9746_gmail_com/Kirisakura_ANAKIN_ROG5/KernelSU-Next/kernel/ksud.h). It must always remain `/data/adb/ksud`.
- **Context:** `KSUD_PATH` is used by `sucompat.c` and other kernel hooks to redirect all `su` calls to the userspace daemon. Changing it to any other path (e.g. `/ksud`) breaks root access entirely, requiring the user to reflash. If a separate ramdisk source path is needed, define a new constant (e.g. `KSUD_RAMDISK_PATH`) in `ksud.h` and use that instead.

## Propose Upstream Patches Validation
- **Rule:** Before presenting any upstream kernel commits/patches as recommendations to the user, always verify locally in the git history (e.g. using `git log --grep="..."` or checking if the commit hash is reachable in the current branch) whether they have already been merged or applied. Never recommend patches that are already present in the local codebase.
- **Context:** Proposing already-merged patches creates noise and leads to duplicate/empty cherry-pick attempts.

## Always Use dev Branch for New Changes
- **Rule:** When introducing new kernel changes, commits, config edits, or features, always switch to the `dev` branch to perform the development work. Do not make changes directly on master or release branches (e.g., `master_release_t2_ksu_next`). Verify and test changes on `dev` before merging/fast-forwarding them.
- **Context:** Isolating development to the `dev` branch keeps production/release branches stable, prevents accidental commits on release branches, and allows for safe staging and verification of updates.

## Packaging and Uploading Kernel Builds
- **Rule:** Always run `./package_kernel.sh` to package and build the final AnyKernel3 zip, rather than manually running `cp` and `zip` commands.
- **Context:** `./package_kernel.sh` automatically copies the compiled image and drivers, packages the zip, and uploads it to Litterbox to provide a direct download URL. Using the script ensures consistency and simplifies downloading the build files to the phone/PC.

## Explicit Approval for Merging and Code Modifications
- **Rule:** Always ask for explicit user approval before performing git merges, branch checkouts for merging, or editing codebase files. Once the user approves the proposed action, proceed with it.
- **Context:** Ensures that no unexpected modifications or merges occur without the user's explicit consent.

## KMI Constraint and Localversion Suffix
- **Rule:** NEVER suggest or perform bulk merges of upstream stable tags (e.g. v5.4.260) on this kernel. The kernel sublevel must remain locked to `5.4.210` to maintain KMI (Kernel Module Interface) Symbol CRC compatibility with the pre-compiled Qualcomm/ASUS vendor modules. Suffixes like `CONFIG_LOCALVERSION="-qgki-perf"` must not be changed, as version matching works automatically once CRCs match. Only perform surgical cherry-pick backports of specific performance or security commits.
- **Context:** Stable merges change function signatures and structure sizes, breaking compatibility with stock modules on the device partition. Setting localversion to empty or another string does not bypass this because Symbol CRCs are checked first.
