#ifndef HEAVY_H
#define HEAVY_H

#include "miner.h"

#ifdef USE_HEAVY
extern bool heavy_prepare_work(struct thr_info *thr, struct work *work);
extern void heavy_regenhash(struct work *work);
#else
static inline void heavy_regenhash(struct work *work)
{
}
#endif

#endif
