#include "cppdefs.h"
      MODULE positiveN15_mod
#if defined NONLINEAR && defined POSITIVE_N15
!
!
      implicit none

      PRIVATE
      PUBLIC  :: positive_N15

      CONTAINS
#  if defined NEMURO && defined N15
#    include <positive_N15.h>
#  endif
#endif
      END MODULE positiveN15_mod

