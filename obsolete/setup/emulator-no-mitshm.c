#define _GNU_SOURCE
#include <dlfcn.h>
#include <string.h>

/* SwiftShader resolves XShmQueryExtension using dlsym, so an ordinary symbol
 * override is insufficient. Disable only this capability probe: shared memory
 * cannot cross SSH or a container IPC namespace. Qt has its own environment flag.
 * This preload library is scoped to the emulator by its launcher.
 */
static int no_mitshm(void *display)
{
    (void)display;
    return 0;
}

void *dlsym(void *handle, const char *name)
{
    typedef void *(*lookup_fn)(void *, const char *);
    lookup_fn lookup = (lookup_fn)dlvsym(RTLD_NEXT, "dlsym", "GLIBC_2.2.5");
    if (strcmp(name, "XShmQueryExtension") == 0)
        return (void *)no_mitshm;
    return lookup(handle, name);
}
