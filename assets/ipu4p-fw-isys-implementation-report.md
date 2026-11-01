Ran commit 2: Do not pass kernel pointer as firmware buffer handle
Analyzed ipu4p-fw-isys.c:L45-75
Analyzed ipu4p-fw-isys.c:L725-775
Edited ipu4p-fw-isys.c
Edited ipu4p-fw-isys.c
Ran git diff
Ran commit 3: Add diagnostic logging for truncated DMA addresses
Analyzed ipu6-isys.h:L155-185
Edited ipu6-isys.h
Analyzed ipu4p-fw-isys.c:L380-445
Edited ipu4p-fw-isys.c
Analyzed ipu4p-fw-isys.c:L675-830
Edited ipu4p-fw-isys.c
Edited ipu4p-fw-isys.c
Edited ipu4p-fw-isys.c
Ran git diff for Change 4
Ran commit 4: Group message tracking fields in isys_fw_msgs
Ran check recent commits
Analyzed ipu4p-fw-isys.c:L1-35
Ran git diff HEAD~4..HEAD
Ran git status check

### Summary of Implementation

Following our re-evaluation of [`ipu4p-fw-isys.c`](file:///home/admin/Github/linux/drivers/media/pci/intel/ipu6/ipu4p-fw-isys.c) and [`ipu4p-fw-isys.h`](file:///home/admin/Github/linux/drivers/media/pci/intel/ipu6/ipu4p-fw-isys.h), we adjusted the plan and implemented the cleanup across **4 follow-up commits** on branch `media-committers`:

---

### Plan Adjustments During Review

1. **`stream_start` Payload**:
   - Initial review suspected that passing the frame buffer set for `STREAM_START_AND_CAPTURE` was a bug compared to IPU6.
   - **Finding**: In IPU6, `stream` and `frame` are unioned at offset 0, and IPU6 passed `sizeof(stream)` by mistake. IPU7 corrected this by sending the frame buffer set via `ipu7_fw_isys_send_frame_buff_set()`. IPU4P was already doing the right thing. We kept this logic and added an explanatory comment.

2. **Placement of `ipu4p_isys_irq_setup()` and `ipu4p_isys_isr()`**:
   - Initial review suggested moving IRQ handling out of `ipu4p-fw-isys.c`.
   - **Finding**: In upstream, `ipu6_isys_isr()` lives in [`ipu6-fw-isys.c`](file:///home/admin/Github/linux/drivers/media/pci/intel/ipu6/ipu6-fw-isys.c#L727) and `ipu7_isys_isr()` lives in [`ipu7-fw-isys.c`](file:///home/admin/Github/linux/drivers/media/pci/intel/ipu6/ipu7-fw-isys.c#L825). Keeping `ipu4p_isys_isr()` in [`ipu4p-fw-isys.c`](file:///home/admin/Github/linux/drivers/media/pci/intel/ipu6/ipu4p-fw-isys.c#L893) adheres strictly to the existing codebase conventions and is the least intrusive approach.

---

### Follow-up Commits Created

1. **`34457d3cf96`**: `media: ipu6: ipu4p: Reuse IPU6 firmware enums and remove redundant translation`
   - Reused [`IPU6_FW_ISYS_*`](file:///home/admin/Github/linux/drivers/media/pci/intel/ipu6/ipu6-fw-isys.h#L74) enums directly, removing ~200 lines of duplicate enums in [`ipu4p-fw-isys.h`](file:///home/admin/Github/linux/drivers/media/pci/intel/ipu6/ipu4p-fw-isys.h).
   - Removed the 40-line `ipu4p_fw_isys_resp_type_to_ipu6()` identity mapping.
   - Handled response types directly in `ipu4p_fw_isys_isr_one()`, eliminating dead-code paths.

2. **`b661262e61a`**: `media: ipu6: ipu4p: Do not pass kernel pointer as firmware buffer handle`
   - Changed `pin->out_buf_id` from `(u64)(uintptr_t)set` to `vb->index + 1`, matching IPU6 and preventing kernel address exposure (KASLR leak).
   - In `ipu4p_fw_isys_complete_pin_response()`, matched frames solely using `stream_handle` and `frame_counter`.

3. **`df723738516`**: `media: ipu6: ipu4p: Add diagnostic logging for truncated DMA addresses`
   - Added `dev_err` and `dev_err_once` diagnostics if `upper_32_bits(dma_addr)` is ever non-zero instead of silently failing.
   - Added an explanatory comment on the `STREAM_START_AND_CAPTURE` payload requirement.

4. **`76ee25770fd`**: `media: ipu6: ipu4p: Group message tracking fields in isys_fw_msgs`
   - Grouped the 5 loose `ipu4p_*` tracking fields in [`struct isys_fw_msgs`](file:///home/admin/Github/linux/drivers/media/pci/intel/ipu6/ipu6-isys.h#L155-L185) into an `ipu4p_track` sub-structure, clarifying scope and ownership.

---

### Net Impact

```
 drivers/media/pci/intel/ipu6/ipu4p-fw-isys.c | 196 ++++++++++---------------
 drivers/media/pci/intel/ipu6/ipu4p-fw-isys.h | 204 +--------------------------
 drivers/media/pci/intel/ipu6/ipu6-isys.h     |  14 +-
 3 files changed, 90 insertions(+), 324 deletions(-)
```

Net reduction of **234 lines**, removal of duplicate definitions, elimination of kernel pointer exposure to firmware, and clearer scoping.