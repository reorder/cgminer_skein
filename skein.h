#ifndef SKEIN_H
#define SKEIN_H

#include "miner.h"

#ifdef USE_SKEIN
extern bool skein_prepare_work(struct thr_info *thr, struct work *work);
extern void skein_regenhash(struct work *work);
#else
static inline void skein_regenhash(struct work *work)
{
}
#endif

#endif /* SKEIN_H */
