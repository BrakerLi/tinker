@echo off
rem
rem
rem  #################################################################
rem  ##                                                             ##
rem  ##  generic.make  --  compile Tinker routines for generic CPU  ##
rem  ##             (Intel Fortran for Windows Version)             ##
rem  ##                                                             ##
rem  #################################################################
rem
rem
rem  compile all the modules; "sizes" must be first since it is used
rem  to set static array dimensions in many of the other modules
rem
rem
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp sizes.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp action.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp align.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp analyz.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp angang.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp angbnd.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp angpot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp angtor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp argue.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ascii.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp atmlst.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp atomid.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp atoms.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bath.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bitor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bndpot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bndstr.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bound.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp boxes.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp cell.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp cflux.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp charge.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp chgpen.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp chgpot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp chgtrn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp chrono.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp chunks.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp couple.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ctrpot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp deriv.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp dipole.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp disgeo.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp disp.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp dma.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp domega.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp dsppot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp energi.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ewald.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp expol.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp faces.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp fft.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp fields.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp files.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp fracs.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp freeze.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp gkstuf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp group.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp hescut.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp hessn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp hpmf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ielscf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp improp.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp imptor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp inform.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp inter.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp iounit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kanang.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kangs.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kantor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp katoms.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kbonds.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kcflux.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kchrge.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kcpen.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kctrn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kdipol.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kdsp.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kexpl.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp keys.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp khbond.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kiprop.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kitors.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kmulti.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kopbnd.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kopdst.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp korbs.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kpitor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kpolpr.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kpolr.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp krepl.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ksolut.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kstbnd.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ksttor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ktorsn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ktrtor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kurybr.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kvdwpr.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kvdws.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp light.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp limits.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp linmin.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp math.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mdstuf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp merck.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp minima.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp molcul.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp moldyn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp moment.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mplpot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mpole.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mrecip.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mutant.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp neigh.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp nonpol.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp nucleo.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp omega.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp opbend.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp opdist.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp openmp.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp orbits.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp output.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp params.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp paths.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pbstuf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pdb.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp phipsi.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp piorbs.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pistuf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pitors.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pme.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp polar.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp polgrp.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp polopt.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp polpcg.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp polpot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp poltcg.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp potent.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp potfit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ptable.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp qmstuf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp refer.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp repel.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp reppot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp resdue.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp restrn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rgddyn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rigid.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ring.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rotbnd.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rxnfld.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rxnpot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp scales.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp sequen.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp shapes.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp shunt.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp socket.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp solpot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp solute.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp stodyn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp strbnd.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp strtor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp syntrn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp tarray.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp titles.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp torpot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp tors.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp tortor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp tree.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp units.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp uprior.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp urey.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp urypot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp usage.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp valfit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp vdw.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp vdwpot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp vibs.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp virial.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp warp.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp xtals.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp zclose.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp zcoord.f
#
#  now compile separately each of the Fortran source files
#
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp active.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp alchemy.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp alterchg.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp alterpol.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp analysis.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp analyze.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp angles.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp anneal.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp arcedit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp attach.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp baoab.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bar.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp basefile.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp beeman.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bicubic.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bitors.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bonds.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp born.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bounds.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp bussi.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp calendar.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp center.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp chkpole.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp chkring.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp chksymm.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp chkxyz.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp cholesky.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp clock.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp cluster.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp column.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp command.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp connect.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp connolly.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp control.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp correlate.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp critical.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp crystal.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp cspline.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp cutoffs.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp damping.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp dcflux.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp deflate.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp delete.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp dexpol.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp diagq.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp diffeq.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp diffuse.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp distgeom.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp document.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp dynamic.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangang.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangang1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangang2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangang3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangle.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangle1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangle2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangle3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangtor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangtor1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangtor2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eangtor3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ebond.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ebond1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ebond2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ebond3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ebuck.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ebuck1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ebuck2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ebuck3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echarge.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echarge1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echarge2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echarge3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echgdpl.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echgdpl1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echgdpl2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echgdpl3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echgtrn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echgtrn1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echgtrn2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp echgtrn3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp edipole.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp edipole1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp edipole2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp edipole3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp edisp.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp edisp1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp edisp2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp edisp3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp egauss.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp egauss1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp egauss2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp egauss3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp egeom.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp egeom1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp egeom2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp egeom3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ehal.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ehal1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ehal2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ehal3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eimprop.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eimprop1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eimprop2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eimprop3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eimptor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eimptor1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eimptor2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eimptor3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp elj.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp elj1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp elj2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp elj3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp embed.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp emetal.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp emetal1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp emetal2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp emetal3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp emm3hb.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp emm3hb1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp emm3hb2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp emm3hb3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp empole.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp empole1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp empole2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp empole3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp energy.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eopbend.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eopbend1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eopbend2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eopbend3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eopdist.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eopdist1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eopdist2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eopdist3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp epitors.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp epitors1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp epitors2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp epitors3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp epolar.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp epolar1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp epolar2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp epolar3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp erepel.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp erepel1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp erepel2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp erepel3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp erf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp erxnfld.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp erxnfld1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp erxnfld2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp erxnfld3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp esolv.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp esolv1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp esolv2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp esolv3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp estrbnd.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp estrbnd1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp estrbnd2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp estrbnd3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp estrtor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp estrtor1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp estrtor2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp estrtor3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp etors.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp etors1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp etors2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp etors3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp etortor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp etortor1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp etortor2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp etortor3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eurey.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eurey1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eurey2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp eurey3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp evcorr.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp extra.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp extra1.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp extra2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp extra3.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp fatal.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp fft3d.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp fftpack.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp field.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp final.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp flatten.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp freefix.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp freeunit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp gda.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp geometry.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getarc.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getcart.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getint.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getkey.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getmol.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getmol2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getnumb.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getpdb.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getprm.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getref.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getstring.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp gettext.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getword.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp getxyz.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ghmcstep.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp gradient.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp gradrgd.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp gradrot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp groups.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp grpline.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp gyrate.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp hessian.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp hessrgd.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp hessrot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp hybrid.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp image.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp impose.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp induce.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp inertia.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp initatom.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp initial.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp initneck.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp initprm.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp initres.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp initrot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp insert.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp intedit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp intxyz.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp invbeta.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp invert.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp jacobi.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kangang.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kangle.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kangtor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp katom.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kbond.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kcharge.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kchgflx.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kchgtrn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kdipole.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kdisp.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kewald.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kexpol.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kextra.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kgeom.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kimprop.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kimptor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kinetic.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kmetal.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kmpole.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kopbend.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kopdist.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp korbit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kpitors.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kpolar.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp krepel.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ksolv.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kstrbnd.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kstrtor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ktors.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ktortor.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kundrot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kurey.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp kvdw.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp lattice.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp lbfgs.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp lights.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp lusolve.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp makeint.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp makeref.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp makexyz.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp maxwell.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mdinit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mdrest.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mdsave.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mdstat.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mechanic.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp merge.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp minimize.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp minirot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp minrigid.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mol2xyz.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp molecule.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp molxyz.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp moments.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp monte.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp mutate.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp nblist.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp neck.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp newton.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp newtrot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp nextarg.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp nexttext.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp nose.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp nspline.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp nucleic.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp number.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp numeral.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp numgrad.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp ocvm.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp openend.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp optimize.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp optinit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp optirot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp optrigid.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp optsave.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp orbital.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp orient.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp orthog.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp overlap.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp path.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pdbxyz.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp picalc.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pmestuf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pmpb.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp polarize.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp poledit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp polymer.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp potential.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp predict.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pressure.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prmedit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prmkey.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp promo.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp protein.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtarc.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtdyn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prterr.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtfrc.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtint.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtmol2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtpdb.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtprm.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtseq.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtuind.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtvel.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp prtxyz.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pss.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pssrigid.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp pssrot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp qrsolve.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp quatfit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp radial.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp random.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rattle.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readcart.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readdcd.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readdyn.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readgau.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readgdma.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readint.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readmbis.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readmol.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readmol2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readpdb.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readprm.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readseq.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp readxyz.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp replica.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp respa.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rgdstep.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp richmond.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rings.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rmsfit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rotlist.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp rotpole.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp saddle.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp scan.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp sdstep.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp search.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp server.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp setprm.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp shakeup.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp sigmoid.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp simplex.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp sktstuf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp sniffer.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp sort.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp spacefill.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp spectrum.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp square.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp suffix.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp superpose.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp surface.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp surfatom.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp switch.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp tcgstuf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp temper.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp testgrad.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp testhess.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp testpair.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp testpol.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp testrot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp testsurf.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp testvir.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp timer.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp timerot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp tncg.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp torphase.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp torque.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp torsfit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp torsions.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp trimtext.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp unionball.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp unitcell.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp valence.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp verlet.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp version.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp vibbig.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp vibrate.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp vibrot.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp volume.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp xtalfit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp xtalmin.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp xyzatm.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp xyzedit.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp xyzint.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp xyzmol2.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp xyzpdb.f
ifort /c /O3 /arch:sse3 /Qip- /Qprec-div- /w /Qopenmp zatom.f
