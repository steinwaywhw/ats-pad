/*
**
** The C code is generated by ATS/Postiats
** The compilation time is: 2014-3-14: 10h:20m
**
*/

/*
** include runtime header files
*/
#ifndef _ATS_CCOMP_HEADER_NONE
#include "pats_ccomp_config.h"
#include "pats_ccomp_basics.h"
#include "pats_ccomp_typedefs.h"
#include "pats_ccomp_instrset.h"
#include "pats_ccomp_memalloc.h"
#ifndef _ATS_EXCEPTION_NONE
#include "pats_ccomp_memalloca.h"
#include "pats_ccomp_exception.h"
#endif // end of [_ATS_EXCEPTION_NONE]
#endif /* _ATS_CCOMP_HEADER_NONE */


/*
** include prelude cats files
*/
#ifndef _ATS_CCOMP_PRELUDE_NONE
//
#include "prelude/CATS/basics.cats"
#include "prelude/CATS/integer.cats"
#include "prelude/CATS/pointer.cats"
#include "prelude/CATS/bool.cats"
#include "prelude/CATS/char.cats"
#include "prelude/CATS/integer_ptr.cats"
#include "prelude/CATS/integer_fixed.cats"
#include "prelude/CATS/float.cats"
#include "prelude/CATS/memory.cats"
#include "prelude/CATS/string.cats"
#include "prelude/CATS/strptr.cats"
//
#include "prelude/CATS/filebas.cats"
//
#include "prelude/CATS/list.cats"
#include "prelude/CATS/option.cats"
#include "prelude/CATS/array.cats"
#include "prelude/CATS/arrayptr.cats"
#include "prelude/CATS/arrayref.cats"
#include "prelude/CATS/matrix.cats"
#include "prelude/CATS/matrixptr.cats"
//
#endif /* _ATS_CCOMP_PRELUDE_NONE */

/*
staload-prologues(beg)
*/
/*
staload-prologues(end)
*/
/*
typedefs-for-tyrecs-and-tysums(beg)
*/
/*
typedefs-for-tyrecs-and-tysums(end)
*/
/*
dynconlst-declaration(beg)
*/
/*
dynconlst-declaration(end)
*/
/*
dyncstlst-declaration(beg)
*/
/*
dyncstlst-declaration(end)
*/
/*
dynvalist-implementation(beg)
*/
/*
dynvalist-implementation(end)
*/
/*
exnconlst-declaration(beg)
*/
#ifndef _ATS_EXCEPTION_NONE
extern void the_atsexncon_initize (atstype_exncon *d2c, char *exnmsg) ;
#endif // end of [_ATS_EXCEPTION_NONE]
/*
exnconlst-declaration(end)
*/
/*
assumelst-declaration(beg)
*/
/*
assumelst-declaration(end)
*/
/*
extypelst-declaration(beg)
*/
/*
extypelst-declaration(end)
*/
#if(0)
ATSglobaldec()
atsvoid_t0ype
mainats_void_0() ;
#endif // end of [QUALIFIED]

/*
/home/hwwu/Workspace/ats-pad/main.dats: 17(line=1, offs=17) -- 24(line=1, offs=24)
*/
/*
local: 
global: mainats_void_0$0$0(level=0)
local: 
global: 
*/
ATSglobaldec()
atsvoid_t0ype
mainats_void_0()
{
/* tmpvardeclst(beg) */
ATStmpdec_void(tmpret0, atsvoid_t0ype) ;
/* tmpvardeclst(end) */
/* funbodyinstrlst(beg) */
/*
emit_instr: loc0 = /home/hwwu/Workspace/ats-pad/main.dats: 11(line=1, offs=11) -- 24(line=1, offs=24)
*/
__patsflab_main_void_0:
/*
emit_instr: loc0 = /home/hwwu/Workspace/ats-pad/main.dats: 22(line=1, offs=22) -- 24(line=1, offs=24)
*/
ATSINSmove_void(tmpret0, ATSempty()) ;
/* funbodyinstrlst(end) */
ATSreturn_void(tmpret0) ;
} /* end of [mainats_void_0] */

/*
** for initialization(dynloading)
*/
atsvoid_t0ype
_057_home_057_hwwu_057_Workspace_057_ats_055_pad_057_main_056_dats__dynload()
{
ATSdynload0(
_057_home_057_hwwu_057_Workspace_057_ats_055_pad_057_main_056_dats__dynloadflag
) ;
ATSif(
ATSCKiseqz(
_057_home_057_hwwu_057_Workspace_057_ats_055_pad_057_main_056_dats__dynloadflag
)
) ATSthen() {
ATSdynloadset(_057_home_057_hwwu_057_Workspace_057_ats_055_pad_057_main_056_dats__dynloadflag) ;
/*
dynexnlst-initize(beg)
*/
/*
dynexnlst-initize(end)
*/
} /* ATSendif */
ATSreturn_void() ;
} /* end of [*_dynload] */

/*
** the ATS runtime
*/
#ifndef _ATS_CCOMP_RUNTIME_NONE
#include "pats_ccomp_runtime.c"
#include "pats_ccomp_runtime_memalloc.c"
#ifndef _ATS_EXCEPTION_NONE
#include "pats_ccomp_runtime2_dats.c"
#ifndef _ATS_CCOMP_RUNTIME_TRYWITH_NONE
#include "pats_ccomp_runtime_trywith.c"
#endif /* _ATS_CCOMP_RUNTIME_TRYWITH_NONE */
#endif // end of [_ATS_EXCEPTION_NONE]
#endif /* _ATS_CCOMP_RUNTIME_NONE */

/*
** the [main] implementation
*/
int
main
(
int argc, char **argv, char **envp
) {
int err = 0 ;
_057_home_057_hwwu_057_Workspace_057_ats_055_pad_057_main_056_dats__dynload() ;
ATSmainats_void_0(err) ;
return (err) ;
} /* end of [main] */
