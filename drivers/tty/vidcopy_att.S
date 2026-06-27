# ==============================================================================
# src/drivers/tty/vidcopy.S
# TTY video memory copy routines for GNU Assembler (GAS) - AT&T Syntax
# ==============================================================================

.text

# Export global functions
.global mem_vid_copy
.global vid_vid_copy

# Import external variables from C console driver
.extern vid_seg
.extern vid_mask
.extern vid_size
.extern vid_off
.extern blank_color

# ==============================================================================
# PUBLIC void mem_vid_copy(u16 *src, unsigned dst, unsigned count);
# Copy count characters from kernel memory to video memory.
# ==============================================================================
mem_vid_copy:
    pushl   %ebp
    movl    %esp, %ebp
    pushl   %esi
    pushl   %edi
    pushl   %es
    
    movl    8(%ebp), %esi           # source
    movl    12(%ebp), %edi          # destination
    movl    16(%ebp), %edx          # count
    
    # Load ES segment register via general-purpose register AX
    movw    vid_seg, %ax
    movw    %ax, %es                # segment containing video memory
    cld                             # ensure direction is up

mvc_loop:
    andl    vid_mask, %edi          # wrap address
    movl    %edx, %ecx              # one chunk to copy
    movl    vid_size, %eax
    subl    %edi, %eax
    cmpl    %eax, %ecx
    jbe     0f
    movl    %eax, %ecx              # ecx = min(ecx, vid_size - edi)
0:  subl    %ecx, %edx              # count -= ecx
    shll    $1, %edi                # byte address
    addl    vid_off, %edi           # offset in video memory
    testl   %esi, %esi              # source == 0 means blank the screen
    jz      mvc_blank

mvc_copy:
    rep     movsw                   # copy words to video memory (%es:%edi)
    jmp     mvc_test

mvc_blank:
    movl    blank_color, %eax       # ax = blanking character
    rep     stosw                   # copy blanks to video memory

mvc_test:
    subl    vid_off, %edi
    shrl    $1, %edi                # back to a word address
    testl   %edx, %edx
    jnz     mvc_loop

mvc_done:
    popl    %es
    popl    %edi
    popl    %esi
    popl    %ebp
    ret


# ==============================================================================
# PUBLIC void vid_vid_copy(unsigned src, unsigned dst, unsigned count);
# Copy count characters from video memory to video memory. Handles overlap.
# ==============================================================================
vid_vid_copy:
    pushl   %ebp
    movl    %esp, %ebp
    pushl   %esi
    pushl   %edi
    pushl   %es
    
    movl    8(%ebp), %esi           # source
    movl    12(%ebp), %edi          # destination
    movl    16(%ebp), %edx          # count
    
    movw    vid_seg, %ax
    movw    %ax, %es                # segment containing video memory
    cmpl    %edi, %esi              # copy up or down?
    jb      vvc_down

vvc_up:
    cld                             # direction is up
vvc_uploop:
    andl    vid_mask, %esi          # wrap addresses
    andl    vid_mask, %edi
    movl    %edx, %ecx              # one chunk to copy
    movl    vid_size, %eax
    subl    %esi, %eax
    cmpl    %eax, %ecx
    jbe     0f
    movl    %eax, %ecx              # ecx = min(ecx, vid_size - esi)
0:  movl    vid_size, %eax
    subl    %edi, %eax
    cmpl    %eax, %ecx
    jbe     0f
    movl    %eax, %ecx              # ecx = min(ecx, vid_size - edi)
0:  subl    %ecx, %edx              # count -= ecx
    call    vvc_copy                # copy video words
    testl   %edx, %edx
    jnz     vvc_uploop              # again?
    jmp     vvc_done

vvc_down:
    std                             # direction is down
    leal    -1(%esi, %edx, 1), %esi # start copying at the top
    leal    -1(%edi, %edx, 1), %edi

vvc_downloop:
    andl    vid_mask, %esi
    andl    vid_mask, %edi
    movl    %edx, %ecx
    leal    1(%esi), %eax
    cmpl    %eax, %ecx
    jbe     0f
    movl    %eax, %ecx              # ecx = min(ecx, esi + 1)
0:  leal    1(%edi), %eax
    cmpl    %eax, %ecx
    jbe     0f
    movl    %eax, %ecx              # ecx = min(ecx, edi + 1)
0:  subl    %ecx, %edx              # count -= ecx
    call    vvc_copy
    testl   %edx, %edx
    jnz     vvc_downloop            # again?
    cld                             # C compiler expects direction up

vvc_done:
    popl    %es
    popl    %edi
    popl    %esi
    popl    %ebp
    ret

# Inner function to copy video words (shared by both loops)
vvc_copy:
    shll    $1, %esi
    shll    $1, %edi                # byte addresses
    addl    vid_off, %esi
    addl    vid_off, %edi           # in video memory
    
    rep     movsw                   # copy video words from %ds:%esi to %es:%edi
    
    subl    vid_off, %esi
    subl    vid_off, %edi
    shrl    $1, %esi
    shrl    $1, %edi                # back to word addresses
    ret
