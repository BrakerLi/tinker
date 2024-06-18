#
#
#  ############################################################
#  ##                                                        ##
#  ##  compile.make  --  compile each of the Tinker modules  ##
#  ##          (Windows/Cygwin/GNU gfortran Version)         ##
#  ##                                                        ##
#  ############################################################
#
#
#  compile all the modules; "sizes" must be first since it
#  sets static array dimensions in many of the other modules
#
#
gfortran -c -O3 -ffast-math -fopenmp sizes.f
gfortran -c -O3 -ffast-math -fopenmp action.f
gfortran -c -O3 -ffast-math -fopenmp align.f
gfortran -c -O3 -ffast-math -fopenmp analyz.f
gfortran -c -O3 -ffast-math -fopenmp angang.f
gfortran -c -O3 -ffast-math -fopenmp angbnd.f
gfortran -c -O3 -ffast-math -fopenmp angpot.f
gfortran -c -O3 -ffast-math -fopenmp angtor.f
gfortran -c -O3 -ffast-math -fopenmp argue.f
gfortran -c -O3 -ffast-math -fopenmp ascii.f
gfortran -c -O3 -ffast-math -fopenmp atmlst.f
gfortran -c -O3 -ffast-math -fopenmp atomid.f
gfortran -c -O3 -ffast-math -fopenmp atoms.f
gfortran -c -O3 -ffast-math -fopenmp bath.f
gfortran -c -O3 -ffast-math -fopenmp bitor.f
gfortran -c -O3 -ffast-math -fopenmp bndpot.f
gfortran -c -O3 -ffast-math -fopenmp bndstr.f
gfortran -c -O3 -ffast-math -fopenmp bound.f
gfortran -c -O3 -ffast-math -fopenmp boxes.f
gfortran -c -O3 -ffast-math -fopenmp cell.f
gfortran -c -O3 -ffast-math -fopenmp cflux.f
gfortran -c -O3 -ffast-math -fopenmp charge.f
gfortran -c -O3 -ffast-math -fopenmp chgpen.f
gfortran -c -O3 -ffast-math -fopenmp chgpot.f
gfortran -c -O3 -ffast-math -fopenmp chgtrn.f
gfortran -c -O3 -ffast-math -fopenmp chrono.f
gfortran -c -O3 -ffast-math -fopenmp chunks.f
gfortran -c -O3 -ffast-math -fopenmp couple.f
gfortran -c -O3 -ffast-math -fopenmp ctrpot.f
gfortran -c -O3 -ffast-math -fopenmp deriv.f
gfortran -c -O3 -ffast-math -fopenmp dipole.f
gfortran -c -O3 -ffast-math -fopenmp disgeo.f
gfortran -c -O3 -ffast-math -fopenmp disp.f
gfortran -c -O3 -ffast-math -fopenmp dma.f
gfortran -c -O3 -ffast-math -fopenmp domega.f
gfortran -c -O3 -ffast-math -fopenmp dsppot.f
gfortran -c -O3 -ffast-math -fopenmp energi.f
gfortran -c -O3 -ffast-math -fopenmp ewald.f
gfortran -c -O3 -ffast-math -fopenmp expol.f
gfortran -c -O3 -ffast-math -fopenmp extfld.f
gfortran -c -O3 -ffast-math -fopenmp faces.f
gfortran -c -O3 -ffast-math -fopenmp fft.f
gfortran -c -O3 -ffast-math -fopenmp fields.f
gfortran -c -O3 -ffast-math -fopenmp files.f
gfortran -c -O3 -ffast-math -fopenmp fracs.f
gfortran -c -O3 -ffast-math -fopenmp freeze.f
gfortran -c -O3 -ffast-math -fopenmp gkstuf.f
gfortran -c -O3 -ffast-math -fopenmp group.f
gfortran -c -O3 -ffast-math -fopenmp hescut.f
gfortran -c -O3 -ffast-math -fopenmp hessn.f
gfortran -c -O3 -ffast-math -fopenmp hpmf.f
gfortran -c -O3 -ffast-math -fopenmp ielscf.f
gfortran -c -O3 -ffast-math -fopenmp improp.f
gfortran -c -O3 -ffast-math -fopenmp imptor.f
gfortran -c -O3 -ffast-math -fopenmp inform.f
gfortran -c -O3 -ffast-math -fopenmp inter.f
gfortran -c -O3 -ffast-math -fopenmp iounit.f
gfortran -c -O3 -ffast-math -fopenmp kanang.f
gfortran -c -O3 -ffast-math -fopenmp kangs.f
gfortran -c -O3 -ffast-math -fopenmp kantor.f
gfortran -c -O3 -ffast-math -fopenmp katoms.f
gfortran -c -O3 -ffast-math -fopenmp kbonds.f
gfortran -c -O3 -ffast-math -fopenmp kcflux.f
gfortran -c -O3 -ffast-math -fopenmp kchrge.f
gfortran -c -O3 -ffast-math -fopenmp kcpen.f
gfortran -c -O3 -ffast-math -fopenmp kctrn.f
gfortran -c -O3 -ffast-math -fopenmp kdipol.f
gfortran -c -O3 -ffast-math -fopenmp kdsp.f
gfortran -c -O3 -ffast-math -fopenmp kexpl.f
gfortran -c -O3 -ffast-math -fopenmp keys.f
gfortran -c -O3 -ffast-math -fopenmp khbond.f
gfortran -c -O3 -ffast-math -fopenmp kiprop.f
gfortran -c -O3 -ffast-math -fopenmp kitors.f
gfortran -c -O3 -ffast-math -fopenmp kmulti.f
gfortran -c -O3 -ffast-math -fopenmp kopbnd.f
gfortran -c -O3 -ffast-math -fopenmp kopdst.f
gfortran -c -O3 -ffast-math -fopenmp korbs.f
gfortran -c -O3 -ffast-math -fopenmp kpitor.f
gfortran -c -O3 -ffast-math -fopenmp kpolpr.f
gfortran -c -O3 -ffast-math -fopenmp kpolr.f
gfortran -c -O3 -ffast-math -fopenmp krepl.f
gfortran -c -O3 -ffast-math -fopenmp ksolut.f
gfortran -c -O3 -ffast-math -fopenmp kstbnd.f
gfortran -c -O3 -ffast-math -fopenmp ksttor.f
gfortran -c -O3 -ffast-math -fopenmp ktorsn.f
gfortran -c -O3 -ffast-math -fopenmp ktrtor.f
gfortran -c -O3 -ffast-math -fopenmp kurybr.f
gfortran -c -O3 -ffast-math -fopenmp kvdwpr.f
gfortran -c -O3 -ffast-math -fopenmp kvdws.f
gfortran -c -O3 -ffast-math -fopenmp light.f
gfortran -c -O3 -ffast-math -fopenmp limits.f
gfortran -c -O3 -ffast-math -fopenmp linmin.f
gfortran -c -O3 -ffast-math -fopenmp math.f
gfortran -c -O3 -ffast-math -fopenmp mdstuf.f
gfortran -c -O3 -ffast-math -fopenmp merck.f
gfortran -c -O3 -ffast-math -fopenmp minima.f
gfortran -c -O3 -ffast-math -fopenmp molcul.f
gfortran -c -O3 -ffast-math -fopenmp moldyn.f
gfortran -c -O3 -ffast-math -fopenmp moment.f
gfortran -c -O3 -ffast-math -fopenmp mplpot.f
gfortran -c -O3 -ffast-math -fopenmp mpole.f
gfortran -c -O3 -ffast-math -fopenmp mrecip.f
gfortran -c -O3 -ffast-math -fopenmp mutant.f
gfortran -c -O3 -ffast-math -fopenmp neigh.f
gfortran -c -O3 -ffast-math -fopenmp nonpol.f
gfortran -c -O3 -ffast-math -fopenmp nucleo.f
gfortran -c -O3 -ffast-math -fopenmp omega.f
gfortran -c -O3 -ffast-math -fopenmp opbend.f
gfortran -c -O3 -ffast-math -fopenmp opdist.f
gfortran -c -O3 -ffast-math -fopenmp openmp.f
gfortran -c -O3 -ffast-math -fopenmp orbits.f
gfortran -c -O3 -ffast-math -fopenmp output.f
gfortran -c -O3 -ffast-math -fopenmp params.f
gfortran -c -O3 -ffast-math -fopenmp paths.f
gfortran -c -O3 -ffast-math -fopenmp pbstuf.f
gfortran -c -O3 -ffast-math -fopenmp pdb.f
gfortran -c -O3 -ffast-math -fopenmp phipsi.f
gfortran -c -O3 -ffast-math -fopenmp piorbs.f
gfortran -c -O3 -ffast-math -fopenmp pistuf.f
gfortran -c -O3 -ffast-math -fopenmp pitors.f
gfortran -c -O3 -ffast-math -fopenmp pme.f
gfortran -c -O3 -ffast-math -fopenmp polar.f
gfortran -c -O3 -ffast-math -fopenmp polgrp.f
gfortran -c -O3 -ffast-math -fopenmp polopt.f
gfortran -c -O3 -ffast-math -fopenmp polpcg.f
gfortran -c -O3 -ffast-math -fopenmp polpot.f
gfortran -c -O3 -ffast-math -fopenmp poltcg.f
gfortran -c -O3 -ffast-math -fopenmp potent.f
gfortran -c -O3 -ffast-math -fopenmp potfit.f
gfortran -c -O3 -ffast-math -fopenmp ptable.f
gfortran -c -O3 -ffast-math -fopenmp qmstuf.f
gfortran -c -O3 -ffast-math -fopenmp refer.f
gfortran -c -O3 -ffast-math -fopenmp repel.f
gfortran -c -O3 -ffast-math -fopenmp reppot.f
gfortran -c -O3 -ffast-math -fopenmp resdue.f
gfortran -c -O3 -ffast-math -fopenmp restrn.f
gfortran -c -O3 -ffast-math -fopenmp rgddyn.f
gfortran -c -O3 -ffast-math -fopenmp rigid.f
gfortran -c -O3 -ffast-math -fopenmp ring.f
gfortran -c -O3 -ffast-math -fopenmp rotbnd.f
gfortran -c -O3 -ffast-math -fopenmp rxnfld.f
gfortran -c -O3 -ffast-math -fopenmp rxnpot.f
gfortran -c -O3 -ffast-math -fopenmp scales.f
gfortran -c -O3 -ffast-math -fopenmp sequen.f
gfortran -c -O3 -ffast-math -fopenmp shapes.f
gfortran -c -O3 -ffast-math -fopenmp shunt.f
gfortran -c -O3 -ffast-math -fopenmp socket.f
gfortran -c -O3 -ffast-math -fopenmp solpot.f
gfortran -c -O3 -ffast-math -fopenmp solute.f
gfortran -c -O3 -ffast-math -fopenmp stodyn.f
gfortran -c -O3 -ffast-math -fopenmp strbnd.f
gfortran -c -O3 -ffast-math -fopenmp strtor.f
gfortran -c -O3 -ffast-math -fopenmp syntrn.f
gfortran -c -O3 -ffast-math -fopenmp tarray.f
gfortran -c -O3 -ffast-math -fopenmp titles.f
gfortran -c -O3 -ffast-math -fopenmp torpot.f
gfortran -c -O3 -ffast-math -fopenmp tors.f
gfortran -c -O3 -ffast-math -fopenmp tortor.f
gfortran -c -O3 -ffast-math -fopenmp tree.f
gfortran -c -O3 -ffast-math -fopenmp units.f
gfortran -c -O3 -ffast-math -fopenmp uprior.f
gfortran -c -O3 -ffast-math -fopenmp urey.f
gfortran -c -O3 -ffast-math -fopenmp urypot.f
gfortran -c -O3 -ffast-math -fopenmp usage.f
gfortran -c -O3 -ffast-math -fopenmp valfit.f
gfortran -c -O3 -ffast-math -fopenmp vdw.f
gfortran -c -O3 -ffast-math -fopenmp vdwpot.f
gfortran -c -O3 -ffast-math -fopenmp vibs.f
gfortran -c -O3 -ffast-math -fopenmp virial.f
gfortran -c -O3 -ffast-math -fopenmp warp.f
gfortran -c -O3 -ffast-math -fopenmp xtals.f
gfortran -c -O3 -ffast-math -fopenmp zclose.f
gfortran -c -O3 -ffast-math -fopenmp zcoord.f
#
#  now compile separately each of the Fortran source files
#
gfortran -c -O3 -ffast-math -fopenmp active.f
gfortran -c -O3 -ffast-math -fopenmp alchemy.f
gfortran -c -O3 -ffast-math -fopenmp alterchg.f
gfortran -c -O3 -ffast-math -fopenmp alterpol.f
gfortran -c -O3 -ffast-math -fopenmp analysis.f
gfortran -c -O3 -ffast-math -fopenmp analyze.f
gfortran -c -O3 -ffast-math -fopenmp angles.f
gfortran -c -O3 -ffast-math -fopenmp anneal.f
gfortran -c -O3 -ffast-math -fopenmp arcedit.f
gfortran -c -O3 -ffast-math -fopenmp attach.f
gfortran -c -O3 -ffast-math -fopenmp baoab.f
gfortran -c -O3 -ffast-math -fopenmp bar.f
gfortran -c -O3 -ffast-math -fopenmp basefile.f
gfortran -c -O3 -ffast-math -fopenmp beeman.f
gfortran -c -O3 -ffast-math -fopenmp bicubic.f
gfortran -c -O3 -ffast-math -fopenmp bitors.f
gfortran -c -O3 -ffast-math -fopenmp bonds.f
gfortran -c -O3 -ffast-math -fopenmp born.f
gfortran -c -O3 -ffast-math -fopenmp bounds.f
gfortran -c -O3 -ffast-math -fopenmp bussi.f
gfortran -c -O3 -ffast-math -fopenmp calendar.f
gfortran -c -O3 -ffast-math -fopenmp center.f
gfortran -c -O3 -ffast-math -fopenmp chkpole.f
gfortran -c -O3 -ffast-math -fopenmp chkring.f
gfortran -c -O3 -ffast-math -fopenmp chksymm.f
gfortran -c -O3 -ffast-math -fopenmp chkxyz.f
gfortran -c -O3 -ffast-math -fopenmp cholesky.f
gfortran -c -O3 -ffast-math -fopenmp clock.f
gfortran -c -O3 -ffast-math -fopenmp cluster.f
gfortran -c -O3 -ffast-math -fopenmp column.f
gfortran -c -O3 -ffast-math -fopenmp command.f
gfortran -c -O3 -ffast-math -fopenmp connect.f
gfortran -c -O3 -ffast-math -fopenmp connolly.f
gfortran -c -O3 -ffast-math -fopenmp control.f
gfortran -c -O3 -ffast-math -fopenmp correlate.f
gfortran -c -O3 -ffast-math -fopenmp critical.f
gfortran -c -O3 -ffast-math -fopenmp crystal.f
gfortran -c -O3 -ffast-math -fopenmp cspline.f
gfortran -c -O3 -ffast-math -fopenmp cutoffs.f
gfortran -c -O3 -ffast-math -fopenmp damping.f
gfortran -c -O3 -ffast-math -fopenmp dcflux.f
gfortran -c -O3 -ffast-math -fopenmp deflate.f
gfortran -c -O3 -ffast-math -fopenmp delete.f
gfortran -c -O3 -ffast-math -fopenmp dexpol.f
gfortran -c -O3 -ffast-math -fopenmp diagq.f
gfortran -c -O3 -ffast-math -fopenmp diffeq.f
gfortran -c -O3 -ffast-math -fopenmp diffuse.f
gfortran -c -O3 -ffast-math -fopenmp distgeom.f
gfortran -c -O3 -ffast-math -fopenmp document.f
gfortran -c -O3 -ffast-math -fopenmp dynamic.f
gfortran -c -O3 -ffast-math -fopenmp eangang.f
gfortran -c -O3 -ffast-math -fopenmp eangang1.f
gfortran -c -O3 -ffast-math -fopenmp eangang2.f
gfortran -c -O3 -ffast-math -fopenmp eangang3.f
gfortran -c -O3 -ffast-math -fopenmp eangle.f
gfortran -c -O3 -ffast-math -fopenmp eangle1.f
gfortran -c -O3 -ffast-math -fopenmp eangle2.f
gfortran -c -O3 -ffast-math -fopenmp eangle3.f
gfortran -c -O3 -ffast-math -fopenmp eangtor.f
gfortran -c -O3 -ffast-math -fopenmp eangtor1.f
gfortran -c -O3 -ffast-math -fopenmp eangtor2.f
gfortran -c -O3 -ffast-math -fopenmp eangtor3.f
gfortran -c -O3 -ffast-math -fopenmp ebond.f
gfortran -c -O3 -ffast-math -fopenmp ebond1.f
gfortran -c -O3 -ffast-math -fopenmp ebond2.f
gfortran -c -O3 -ffast-math -fopenmp ebond3.f
gfortran -c -O3 -ffast-math -fopenmp ebuck.f
gfortran -c -O3 -ffast-math -fopenmp ebuck1.f
gfortran -c -O3 -ffast-math -fopenmp ebuck2.f
gfortran -c -O3 -ffast-math -fopenmp ebuck3.f
gfortran -c -O3 -ffast-math -fopenmp echarge.f
gfortran -c -O3 -ffast-math -fopenmp echarge1.f
gfortran -c -O3 -ffast-math -fopenmp echarge2.f
gfortran -c -O3 -ffast-math -fopenmp echarge3.f
gfortran -c -O3 -ffast-math -fopenmp echgdpl.f
gfortran -c -O3 -ffast-math -fopenmp echgdpl1.f
gfortran -c -O3 -ffast-math -fopenmp echgdpl2.f
gfortran -c -O3 -ffast-math -fopenmp echgdpl3.f
gfortran -c -O3 -ffast-math -fopenmp echgtrn.f
gfortran -c -O3 -ffast-math -fopenmp echgtrn1.f
gfortran -c -O3 -ffast-math -fopenmp echgtrn2.f
gfortran -c -O3 -ffast-math -fopenmp echgtrn3.f
gfortran -c -O3 -ffast-math -fopenmp edipole.f
gfortran -c -O3 -ffast-math -fopenmp edipole1.f
gfortran -c -O3 -ffast-math -fopenmp edipole2.f
gfortran -c -O3 -ffast-math -fopenmp edipole3.f
gfortran -c -O3 -ffast-math -fopenmp edisp.f
gfortran -c -O3 -ffast-math -fopenmp edisp1.f
gfortran -c -O3 -ffast-math -fopenmp edisp2.f
gfortran -c -O3 -ffast-math -fopenmp edisp3.f
gfortran -c -O3 -ffast-math -fopenmp egauss.f
gfortran -c -O3 -ffast-math -fopenmp egauss1.f
gfortran -c -O3 -ffast-math -fopenmp egauss2.f
gfortran -c -O3 -ffast-math -fopenmp egauss3.f
gfortran -c -O3 -ffast-math -fopenmp egeom.f
gfortran -c -O3 -ffast-math -fopenmp egeom1.f
gfortran -c -O3 -ffast-math -fopenmp egeom2.f
gfortran -c -O3 -ffast-math -fopenmp egeom3.f
gfortran -c -O3 -ffast-math -fopenmp ehal.f
gfortran -c -O3 -ffast-math -fopenmp ehal1.f
gfortran -c -O3 -ffast-math -fopenmp ehal2.f
gfortran -c -O3 -ffast-math -fopenmp ehal3.f
gfortran -c -O3 -ffast-math -fopenmp eimprop.f
gfortran -c -O3 -ffast-math -fopenmp eimprop1.f
gfortran -c -O3 -ffast-math -fopenmp eimprop2.f
gfortran -c -O3 -ffast-math -fopenmp eimprop3.f
gfortran -c -O3 -ffast-math -fopenmp eimptor.f
gfortran -c -O3 -ffast-math -fopenmp eimptor1.f
gfortran -c -O3 -ffast-math -fopenmp eimptor2.f
gfortran -c -O3 -ffast-math -fopenmp eimptor3.f
gfortran -c -O3 -ffast-math -fopenmp elj.f
gfortran -c -O3 -ffast-math -fopenmp elj1.f
gfortran -c -O3 -ffast-math -fopenmp elj2.f
gfortran -c -O3 -ffast-math -fopenmp elj3.f
gfortran -c -O3 -ffast-math -fopenmp embed.f
gfortran -c -O3 -ffast-math -fopenmp emetal.f
gfortran -c -O3 -ffast-math -fopenmp emetal1.f
gfortran -c -O3 -ffast-math -fopenmp emetal2.f
gfortran -c -O3 -ffast-math -fopenmp emetal3.f
gfortran -c -O3 -ffast-math -fopenmp emm3hb.f
gfortran -c -O3 -ffast-math -fopenmp emm3hb1.f
gfortran -c -O3 -ffast-math -fopenmp emm3hb2.f
gfortran -c -O3 -ffast-math -fopenmp emm3hb3.f
gfortran -c -O3 -ffast-math -fopenmp empole.f
gfortran -c -O3 -ffast-math -fopenmp empole1.f
gfortran -c -O3 -ffast-math -fopenmp empole2.f
gfortran -c -O3 -ffast-math -fopenmp empole3.f
gfortran -c -O3 -ffast-math -fopenmp energy.f
gfortran -c -O3 -ffast-math -fopenmp eopbend.f
gfortran -c -O3 -ffast-math -fopenmp eopbend1.f
gfortran -c -O3 -ffast-math -fopenmp eopbend2.f
gfortran -c -O3 -ffast-math -fopenmp eopbend3.f
gfortran -c -O3 -ffast-math -fopenmp eopdist.f
gfortran -c -O3 -ffast-math -fopenmp eopdist1.f
gfortran -c -O3 -ffast-math -fopenmp eopdist2.f
gfortran -c -O3 -ffast-math -fopenmp eopdist3.f
gfortran -c -O3 -ffast-math -fopenmp epitors.f
gfortran -c -O3 -ffast-math -fopenmp epitors1.f
gfortran -c -O3 -ffast-math -fopenmp epitors2.f
gfortran -c -O3 -ffast-math -fopenmp epitors3.f
gfortran -c -O3 -ffast-math -fopenmp epolar.f
gfortran -c -O3 -ffast-math -fopenmp epolar1.f
gfortran -c -O3 -ffast-math -fopenmp epolar2.f
gfortran -c -O3 -ffast-math -fopenmp epolar3.f
gfortran -c -O3 -ffast-math -fopenmp erepel.f
gfortran -c -O3 -ffast-math -fopenmp erepel1.f
gfortran -c -O3 -ffast-math -fopenmp erepel2.f
gfortran -c -O3 -ffast-math -fopenmp erepel3.f
gfortran -c -O3 -ffast-math -fopenmp erf.f
gfortran -c -O3 -ffast-math -fopenmp erxnfld.f
gfortran -c -O3 -ffast-math -fopenmp erxnfld1.f
gfortran -c -O3 -ffast-math -fopenmp erxnfld2.f
gfortran -c -O3 -ffast-math -fopenmp erxnfld3.f
gfortran -c -O3 -ffast-math -fopenmp esolv.f
gfortran -c -O3 -ffast-math -fopenmp esolv1.f
gfortran -c -O3 -ffast-math -fopenmp esolv2.f
gfortran -c -O3 -ffast-math -fopenmp esolv3.f
gfortran -c -O3 -ffast-math -fopenmp estrbnd.f
gfortran -c -O3 -ffast-math -fopenmp estrbnd1.f
gfortran -c -O3 -ffast-math -fopenmp estrbnd2.f
gfortran -c -O3 -ffast-math -fopenmp estrbnd3.f
gfortran -c -O3 -ffast-math -fopenmp estrtor.f
gfortran -c -O3 -ffast-math -fopenmp estrtor1.f
gfortran -c -O3 -ffast-math -fopenmp estrtor2.f
gfortran -c -O3 -ffast-math -fopenmp estrtor3.f
gfortran -c -O3 -ffast-math -fopenmp etors.f
gfortran -c -O3 -ffast-math -fopenmp etors1.f
gfortran -c -O3 -ffast-math -fopenmp etors2.f
gfortran -c -O3 -ffast-math -fopenmp etors3.f
gfortran -c -O3 -ffast-math -fopenmp etortor.f
gfortran -c -O3 -ffast-math -fopenmp etortor1.f
gfortran -c -O3 -ffast-math -fopenmp etortor2.f
gfortran -c -O3 -ffast-math -fopenmp etortor3.f
gfortran -c -O3 -ffast-math -fopenmp eurey.f
gfortran -c -O3 -ffast-math -fopenmp eurey1.f
gfortran -c -O3 -ffast-math -fopenmp eurey2.f
gfortran -c -O3 -ffast-math -fopenmp eurey3.f
gfortran -c -O3 -ffast-math -fopenmp evcorr.f
gfortran -c -O3 -ffast-math -fopenmp exfield.f
gfortran -c -O3 -ffast-math -fopenmp extra.f
gfortran -c -O3 -ffast-math -fopenmp extra1.f
gfortran -c -O3 -ffast-math -fopenmp extra2.f
gfortran -c -O3 -ffast-math -fopenmp extra3.f
gfortran -c -O3 -ffast-math -fopenmp fatal.f
gfortran -c -O3 -ffast-math -fopenmp fft3d.f
gfortran -c -O3 -ffast-math -fopenmp fftpack.f
gfortran -c -O3 -ffast-math -fopenmp field.f
gfortran -c -O3 -ffast-math -fopenmp final.f
gfortran -c -O3 -ffast-math -fopenmp flatten.f
gfortran -c -O3 -ffast-math -fopenmp freefix.f
gfortran -c -O3 -ffast-math -fopenmp freeunit.f
gfortran -c -O3 -ffast-math -fopenmp gda.f
gfortran -c -O3 -ffast-math -fopenmp geometry.f
gfortran -c -O3 -ffast-math -fopenmp getarc.f
gfortran -c -O3 -ffast-math -fopenmp getcart.f
gfortran -c -O3 -ffast-math -fopenmp getint.f
gfortran -c -O3 -ffast-math -fopenmp getkey.f
gfortran -c -O3 -ffast-math -fopenmp getmol.f
gfortran -c -O3 -ffast-math -fopenmp getmol2.f
gfortran -c -O3 -ffast-math -fopenmp getnumb.f
gfortran -c -O3 -ffast-math -fopenmp getpdb.f
gfortran -c -O3 -ffast-math -fopenmp getprm.f
gfortran -c -O3 -ffast-math -fopenmp getref.f
gfortran -c -O3 -ffast-math -fopenmp getstring.f
gfortran -c -O3 -ffast-math -fopenmp gettext.f
gfortran -c -O3 -ffast-math -fopenmp getword.f
gfortran -c -O3 -ffast-math -fopenmp getxyz.f
gfortran -c -O3 -ffast-math -fopenmp ghmcstep.f
gfortran -c -O3 -ffast-math -fopenmp gradient.f
gfortran -c -O3 -ffast-math -fopenmp gradrgd.f
gfortran -c -O3 -ffast-math -fopenmp gradrot.f
gfortran -c -O3 -ffast-math -fopenmp groups.f
gfortran -c -O3 -ffast-math -fopenmp grpline.f
gfortran -c -O3 -ffast-math -fopenmp gyrate.f
gfortran -c -O3 -ffast-math -fopenmp hessian.f
gfortran -c -O3 -ffast-math -fopenmp hessrgd.f
gfortran -c -O3 -ffast-math -fopenmp hessrot.f
gfortran -c -O3 -ffast-math -fopenmp hybrid.f
gfortran -c -O3 -ffast-math -fopenmp image.f
gfortran -c -O3 -ffast-math -fopenmp impose.f
gfortran -c -O3 -ffast-math -fopenmp induce.f
gfortran -c -O3 -ffast-math -fopenmp inertia.f
gfortran -c -O3 -ffast-math -fopenmp initatom.f
gfortran -c -O3 -ffast-math -fopenmp initial.f
gfortran -c -O3 -ffast-math -fopenmp initneck.f
gfortran -c -O3 -ffast-math -fopenmp initprm.f
gfortran -c -O3 -ffast-math -fopenmp initres.f
gfortran -c -O3 -ffast-math -fopenmp initrot.f
gfortran -c -O3 -ffast-math -fopenmp insert.f
gfortran -c -O3 -ffast-math -fopenmp intedit.f
gfortran -c -O3 -ffast-math -fopenmp intxyz.f
gfortran -c -O3 -ffast-math -fopenmp invbeta.f
gfortran -c -O3 -ffast-math -fopenmp invert.f
gfortran -c -O3 -ffast-math -fopenmp jacobi.f
gfortran -c -O3 -ffast-math -fopenmp kangang.f
gfortran -c -O3 -ffast-math -fopenmp kangle.f
gfortran -c -O3 -ffast-math -fopenmp kangtor.f
gfortran -c -O3 -ffast-math -fopenmp katom.f
gfortran -c -O3 -ffast-math -fopenmp kbond.f
gfortran -c -O3 -ffast-math -fopenmp kcharge.f
gfortran -c -O3 -ffast-math -fopenmp kchgflx.f
gfortran -c -O3 -ffast-math -fopenmp kchgtrn.f
gfortran -c -O3 -ffast-math -fopenmp kdipole.f
gfortran -c -O3 -ffast-math -fopenmp kdisp.f
gfortran -c -O3 -ffast-math -fopenmp kewald.f
gfortran -c -O3 -ffast-math -fopenmp kexpol.f
gfortran -c -O3 -ffast-math -fopenmp kextra.f
gfortran -c -O3 -ffast-math -fopenmp kgeom.f
gfortran -c -O3 -ffast-math -fopenmp kimprop.f
gfortran -c -O3 -ffast-math -fopenmp kimptor.f
gfortran -c -O3 -ffast-math -fopenmp kinetic.f
gfortran -c -O3 -ffast-math -fopenmp kmetal.f
gfortran -c -O3 -ffast-math -fopenmp kmpole.f
gfortran -c -O3 -ffast-math -fopenmp kopbend.f
gfortran -c -O3 -ffast-math -fopenmp kopdist.f
gfortran -c -O3 -ffast-math -fopenmp korbit.f
gfortran -c -O3 -ffast-math -fopenmp kpitors.f
gfortran -c -O3 -ffast-math -fopenmp kpolar.f
gfortran -c -O3 -ffast-math -fopenmp krepel.f
gfortran -c -O3 -ffast-math -fopenmp ksolv.f
gfortran -c -O3 -ffast-math -fopenmp kstrbnd.f
gfortran -c -O3 -ffast-math -fopenmp kstrtor.f
gfortran -c -O3 -ffast-math -fopenmp ktors.f
gfortran -c -O3 -ffast-math -fopenmp ktortor.f
gfortran -c -O3 -ffast-math -fopenmp kundrot.f
gfortran -c -O3 -ffast-math -fopenmp kurey.f
gfortran -c -O3 -ffast-math -fopenmp kvdw.f
gfortran -c -O3 -ffast-math -fopenmp lattice.f
gfortran -c -O3 -ffast-math -fopenmp lbfgs.f
gfortran -c -O3 -ffast-math -fopenmp lights.f
gfortran -c -O3 -ffast-math -fopenmp lusolve.f
gfortran -c -O3 -ffast-math -fopenmp makeint.f
gfortran -c -O3 -ffast-math -fopenmp makeref.f
gfortran -c -O3 -ffast-math -fopenmp makexyz.f
gfortran -c -O3 -ffast-math -fopenmp maxwell.f
gfortran -c -O3 -ffast-math -fopenmp mdinit.f
gfortran -c -O3 -ffast-math -fopenmp mdrest.f
gfortran -c -O3 -ffast-math -fopenmp mdsave.f
gfortran -c -O3 -ffast-math -fopenmp mdstat.f
gfortran -c -O3 -ffast-math -fopenmp mechanic.f
gfortran -c -O3 -ffast-math -fopenmp merge.f
gfortran -c -O3 -ffast-math -fopenmp minimize.f
gfortran -c -O3 -ffast-math -fopenmp minirot.f
gfortran -c -O3 -ffast-math -fopenmp minrigid.f
gfortran -c -O3 -ffast-math -fopenmp mol2xyz.f
gfortran -c -O3 -ffast-math -fopenmp molecule.f
gfortran -c -O3 -ffast-math -fopenmp molxyz.f
gfortran -c -O3 -ffast-math -fopenmp moments.f
gfortran -c -O3 -ffast-math -fopenmp monte.f
gfortran -c -O3 -ffast-math -fopenmp mutate.f
gfortran -c -O3 -ffast-math -fopenmp nblist.f
gfortran -c -O3 -ffast-math -fopenmp neck.f
gfortran -c -O3 -ffast-math -fopenmp newton.f
gfortran -c -O3 -ffast-math -fopenmp newtrot.f
gfortran -c -O3 -ffast-math -fopenmp nextarg.f
gfortran -c -O3 -ffast-math -fopenmp nexttext.f
gfortran -c -O3 -ffast-math -fopenmp nose.f
gfortran -c -O3 -ffast-math -fopenmp nspline.f
gfortran -c -O3 -ffast-math -fopenmp nucleic.f
gfortran -c -O3 -ffast-math -fopenmp number.f
gfortran -c -O3 -ffast-math -fopenmp numeral.f
gfortran -c -O3 -ffast-math -fopenmp numgrad.f
gfortran -c -O3 -ffast-math -fopenmp ocvm.f
gfortran -c -O3 -ffast-math -fopenmp openend.f
gfortran -c -O3 -ffast-math -fopenmp optimize.f
gfortran -c -O3 -ffast-math -fopenmp optinit.f
gfortran -c -O3 -ffast-math -fopenmp optirot.f
gfortran -c -O3 -ffast-math -fopenmp optrigid.f
gfortran -c -O3 -ffast-math -fopenmp optsave.f
gfortran -c -O3 -ffast-math -fopenmp orbital.f
gfortran -c -O3 -ffast-math -fopenmp orient.f
gfortran -c -O3 -ffast-math -fopenmp orthog.f
gfortran -c -O3 -ffast-math -fopenmp overlap.f
gfortran -c -O3 -ffast-math -fopenmp path.f
gfortran -c -O3 -ffast-math -fopenmp pdbxyz.f
gfortran -c -O3 -ffast-math -fopenmp picalc.f
gfortran -c -O3 -ffast-math -fopenmp pmestuf.f
gfortran -c -O3 -ffast-math -fopenmp pmpb.f
gfortran -c -O3 -ffast-math -fopenmp polarize.f
gfortran -c -O3 -ffast-math -fopenmp poledit.f
gfortran -c -O3 -ffast-math -fopenmp polymer.f
gfortran -c -O3 -ffast-math -fopenmp potential.f
gfortran -c -O3 -ffast-math -fopenmp predict.f
gfortran -c -O3 -ffast-math -fopenmp pressure.f
gfortran -c -O3 -ffast-math -fopenmp prmedit.f
gfortran -c -O3 -ffast-math -fopenmp prmkey.f
gfortran -c -O3 -ffast-math -fopenmp promo.f
gfortran -c -O3 -ffast-math -fopenmp protein.f
gfortran -c -O3 -ffast-math -fopenmp prtarc.f
gfortran -c -O3 -ffast-math -fopenmp prtdyn.f
gfortran -c -O3 -ffast-math -fopenmp prterr.f
gfortran -c -O3 -ffast-math -fopenmp prtfrc.f
gfortran -c -O3 -ffast-math -fopenmp prtint.f
gfortran -c -O3 -ffast-math -fopenmp prtmol2.f
gfortran -c -O3 -ffast-math -fopenmp prtpdb.f
gfortran -c -O3 -ffast-math -fopenmp prtprm.f
gfortran -c -O3 -ffast-math -fopenmp prtseq.f
gfortran -c -O3 -ffast-math -fopenmp prtuind.f
gfortran -c -O3 -ffast-math -fopenmp prtvel.f
gfortran -c -O3 -ffast-math -fopenmp prtxyz.f
gfortran -c -O3 -ffast-math -fopenmp pss.f
gfortran -c -O3 -ffast-math -fopenmp pssrigid.f
gfortran -c -O3 -ffast-math -fopenmp pssrot.f
gfortran -c -O3 -ffast-math -fopenmp qrsolve.f
gfortran -c -O3 -ffast-math -fopenmp quatfit.f
gfortran -c -O3 -ffast-math -fopenmp radial.f
gfortran -c -O3 -ffast-math -fopenmp random.f
gfortran -c -O3 -ffast-math -fopenmp rattle.f
gfortran -c -O3 -ffast-math -fopenmp readcart.f
gfortran -c -O3 -ffast-math -fopenmp readdcd.f
gfortran -c -O3 -ffast-math -fopenmp readdyn.f
gfortran -c -O3 -ffast-math -fopenmp readgau.f
gfortran -c -O3 -ffast-math -fopenmp readgdma.f
gfortran -c -O3 -ffast-math -fopenmp readint.f
gfortran -c -O3 -ffast-math -fopenmp readmbis.f
gfortran -c -O3 -ffast-math -fopenmp readmol.f
gfortran -c -O3 -ffast-math -fopenmp readmol2.f
gfortran -c -O3 -ffast-math -fopenmp readpdb.f
gfortran -c -O3 -ffast-math -fopenmp readprm.f
gfortran -c -O3 -ffast-math -fopenmp readseq.f
gfortran -c -O3 -ffast-math -fopenmp readxyz.f
gfortran -c -O3 -ffast-math -fopenmp replica.f
gfortran -c -O3 -ffast-math -fopenmp respa.f
gfortran -c -O3 -ffast-math -fopenmp rgdstep.f
gfortran -c -O3 -ffast-math -fopenmp richmond.f
gfortran -c -O3 -ffast-math -fopenmp rings.f
gfortran -c -O3 -ffast-math -fopenmp rmsfit.f
gfortran -c -O3 -ffast-math -fopenmp rotlist.f
gfortran -c -O3 -ffast-math -fopenmp rotpole.f
gfortran -c -O3 -ffast-math -fopenmp saddle.f
gfortran -c -O3 -ffast-math -fopenmp scan.f
gfortran -c -O3 -ffast-math -fopenmp sdstep.f
gfortran -c -O3 -ffast-math -fopenmp search.f
gfortran -c -O3 -ffast-math -fopenmp server.f
gfortran -c -O3 -ffast-math -fopenmp setprm.f
gfortran -c -O3 -ffast-math -fopenmp shakeup.f
gfortran -c -O3 -ffast-math -fopenmp sigmoid.f
gfortran -c -O3 -ffast-math -fopenmp simplex.f
gfortran -c -O3 -ffast-math -fopenmp sktstuf.f
gfortran -c -O3 -ffast-math -fopenmp sniffer.f
gfortran -c -O3 -ffast-math -fopenmp sort.f
gfortran -c -O3 -ffast-math -fopenmp spacefill.f
gfortran -c -O3 -ffast-math -fopenmp spectrum.f
gfortran -c -O3 -ffast-math -fopenmp square.f
gfortran -c -O3 -ffast-math -fopenmp suffix.f
gfortran -c -O3 -ffast-math -fopenmp superpose.f
gfortran -c -O3 -ffast-math -fopenmp surface.f
gfortran -c -O3 -ffast-math -fopenmp surfatom.f
gfortran -c -O3 -ffast-math -fopenmp switch.f
gfortran -c -O3 -ffast-math -fopenmp tcgstuf.f
gfortran -c -O3 -ffast-math -fopenmp temper.f
gfortran -c -O3 -ffast-math -fopenmp testgrad.f
gfortran -c -O3 -ffast-math -fopenmp testhess.f
gfortran -c -O3 -ffast-math -fopenmp testpair.f
gfortran -c -O3 -ffast-math -fopenmp testpol.f
gfortran -c -O3 -ffast-math -fopenmp testrot.f
gfortran -c -O3 -ffast-math -fopenmp testsurf.f
gfortran -c -O3 -ffast-math -fopenmp testvir.f
gfortran -c -O3 -ffast-math -fopenmp timer.f
gfortran -c -O3 -ffast-math -fopenmp timerot.f
gfortran -c -O3 -ffast-math -fopenmp tncg.f
gfortran -c -O3 -ffast-math -fopenmp torphase.f
gfortran -c -O3 -ffast-math -fopenmp torque.f
gfortran -c -O3 -ffast-math -fopenmp torsfit.f
gfortran -c -O3 -ffast-math -fopenmp torsions.f
gfortran -c -O3 -ffast-math -fopenmp trimtext.f
gfortran -c -O3 -ffast-math -fopenmp unionball.f
gfortran -c -O3 -ffast-math -fopenmp unitcell.f
gfortran -c -O3 -ffast-math -fopenmp valence.f
gfortran -c -O3 -ffast-math -fopenmp verlet.f
gfortran -c -O3 -ffast-math -fopenmp version.f
gfortran -c -O3 -ffast-math -fopenmp vibbig.f
gfortran -c -O3 -ffast-math -fopenmp vibrate.f
gfortran -c -O3 -ffast-math -fopenmp vibrot.f
gfortran -c -O3 -ffast-math -fopenmp volume.f
gfortran -c -O3 -ffast-math -fopenmp xtalfit.f
gfortran -c -O3 -ffast-math -fopenmp xtalmin.f
gfortran -c -O3 -ffast-math -fopenmp xyzatm.f
gfortran -c -O3 -ffast-math -fopenmp xyzedit.f
gfortran -c -O3 -ffast-math -fopenmp xyzint.f
gfortran -c -O3 -ffast-math -fopenmp xyzmol2.f
gfortran -c -O3 -ffast-math -fopenmp xyzpdb.f
gfortran -c -O3 -ffast-math -fopenmp zatom.f
