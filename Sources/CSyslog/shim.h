#ifndef shim_h
#define shim_h

#include <syslog.h>

static inline void syslog_helper(int priority, const char *message) {
    syslog(priority, "%s", message);
}

#endif /* shim_h */
