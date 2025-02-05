c
c
c     ###############################################################
c     ##        COPYRIGHT (C)  2002-2009  by  Patrice Koehl        ##
c     ##  COPYRIGHT (C) 2023 by Moses K. J. Chung & Jay W. Ponder  ##
c     ##                    All Rights Reserved                    ##
c     ###############################################################
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine unionball  --  alpha shapes surface & volume  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "unionball" computes the surface area and volume of a union of
c     spheres via the analytical inclusion-exclusion method of Herbert
c     Edelsbrunner based on alpha shapes, also finds derivatives of
c     surface area and volume with respect to Cartesian coordinates
c
c     original UnionBall code developed and provided by Patrice Koehl,
c     Computer Science, University of California, Davis
c
c     modified to facilitate calling of UnionBall from Tinker by
c     Moses K. J. Chung and Jay W. Ponder, Washington University,
c     October 2023 to May 2024
c
c     literature references:
c
c     P. Mach and P. Koehl, "Geometric Measures of Large Biomolecules:
c     Surface, Volume, and Pockets", Journal of Computational Chemistry,
c     32, 3023-3038 (2011)
c
c     P. Koehl, A. Akopyan and H. Edelsbrunner, "Computing the Volume,
c     Surface Area, Mean, and Gaussian Curvatures of Molecules and Their
c     Derivatives", Journal of Chemical Information and Modeling, 63,
c     973-985 (2023)
c 
c     variables and parameters:
c
c     n         total number of spheres in the current system
c     x         current x-coordinate for each sphere in the system
c     y         current y-coordinate for each sphere in the system
c     z         current z-coordinate for each sphere in the system
c     rad       radius value in Angstroms for each sphere
c     weight    weight value for each sphere in the system
c     probe     radius value in Angstroms of the probe sphere
c     doderiv   logical flag to find derivatives over coordinates
c     dovol     logical flag to compute the excluded volume
c     surf      weighted surface area of union of spheres
c     vol       weighted volume of the union of spheres
c     asurf     weighted contribution of each sphere to the area
c     avol      weighted contribution of each ball to the volume
c     dsurf     derivatives of weighted surface area over coordinates
c     dvol      derivatives of weighted volume over coordinates
c     usurf     unweighted surface area of union of spheres
c     uvol      unweighted volume of the union of spheres
c
c     
      subroutine unionball (n,x,y,z,rad,weight,probe,doderiv,dovol,
     &                         surf,vol,asurf,avol,dsurf,dvol)
      use iounit
      implicit none
      integer i,n,nsphere
      integer nsize,nfudge
      integer nredundant
      integer, allocatable :: redlist(:)                                 
      real*8 surf,usurf
      real*8 vol,uvol
      real*8 probe,alpha,eps
      real*8 x(*)
      real*8 y(*)
      real*8 z(*)
      real*8 rad(*)
      real*8 weight(*)
      real*8 asurf(*)
      real*8 avol(*)
      real*8 dsurf(3,*)
      real*8 dvol(3,*)
      real*8, allocatable :: radii(:)
      real*8, allocatable :: asurfx(:)
      real*8, allocatable :: avolx(:)
      real*8, allocatable :: coords(:,:)
      real*8, allocatable :: dsurfx(:,:)
      real*8, allocatable :: dvolx(:,:)
      logical doderiv,dovol
      logical dowiggle
      character*6 symmtyp
c
c
c     perform dynamic allocation of some local arrays
c
      nfudge = 10
      nsize = n + nfudge
      allocate (radii(nsize))
      allocate (asurfx(nsize))
      allocate (avolx(nsize))
      allocate (coords(3,nsize))
      allocate (dsurfx(3,nsize))
      allocate (dvolx(3,nsize))
      allocate (redlist(nsize))
c
c     increment the sphere radii by the radius of the probe
c
      nsphere = n
      do i = 1, n
         coords(1,i) = x(i)
         coords(2,i) = y(i)
         coords(3,i) = z(i)
         radii(i) = 0.0d0
         if (rad(i) .ne. 0.0d0)  radii(i) = rad(i) + probe
      end do
c
c     check coordinates for linearity, planarity and symmetry
c
      symmtyp = 'NONE'
      call chksymm (symmtyp)
      dowiggle = .false.
      if (n.gt.2 .and. symmtyp.eq.'LINEAR')  dowiggle = .true.
      if (n.gt.3 .and. symmtyp.eq.'PLANAR')  dowiggle = .true.
      if (symmtyp .eq. 'CENTER')  dowiggle = .true.
c
c     random coordinate perturbation to avoid numerical issues
c
      if (dowiggle) then
         write (iout,10)  symmtyp
   10    format (/,' UNIONBALL  --  Warning, ',a6,' Symmetry;'
     &              ' Wiggling Coordinates')
         eps = 0.001d0
         call wiggle (n,coords,eps)
      else if (symmtyp .ne. 'NONE') then
         write (iout,20)  symmtyp
   20    format (/,' UNIONBALL  --  Warning, ',a6,' Symmetry'
     &              ' Detected for the System')
      end if
c
c     transfer coordinates, complete to minimum of four spheres
c     if needed, set Delaunay and alpha complex arrays
c
      call setunion (nsphere,coords,radii)
c
c     compute the weighted Delaunay triangulation
c
      call regular3 (nredundant,redlist)
c
c     compute the alpha complex for fixed value of alpha
c
      alpha = 0.0d0
      call alfcx (alpha,nredundant,redlist)
c
c     if fewer than four balls, set artificial spheres as redundant
c
      call readjust_sphere (nsphere,nredundant,redlist)
c
c     get surface area and volume, then copy to Tinker arrays
c
      if (doderiv) then
         if (dovol) then
            call ball_dvol (weight,surf,vol,usurf,uvol,asurfx,avolx,
     &                         dsurfx,dvolx)
            do i = 1, n
               asurf(i) = asurfx(i)
               avol(i) = avolx(i)
               dsurf(1,i) = dsurfx(1,i)
               dsurf(2,i) = dsurfx(2,i)
               dsurf(3,i) = dsurfx(3,i)
               dvol(1,i) = dvolx(1,i)
               dvol(2,i) = dvolx(2,i)
               dvol(3,i) = dvolx(3,i)
            end do
         else
            call ball_dsurf (weight,surf,usurf,asurfx,dsurfx)
            do i = 1, n
               asurf(i) = asurfx(i)
               dsurf(1,i) = dsurfx(1,i)
               dsurf(2,i) = dsurfx(2,i)
               dsurf(3,i) = dsurfx(3,i)
            end do
         end if
      else
         if (dovol) then
            call ball_vol (weight,surf,vol,usurf,uvol,asurfx,avolx)
            do i = 1, n
               asurf(i) = asurfx(i)
               avol(i) = avolx(i)
            end do
         else
            call ball_surf (weight,surf,usurf,asurfx)
            do i = 1, n
               asurf(i) = asurfx(i)
            end do
         end if
      end if
c
c     perform deallocation of some local arrays
c
      deallocate (radii)
      deallocate (asurfx)
      deallocate (avolx)
      deallocate (coords)
      deallocate (dsurfx)
      deallocate (dvolx)
      deallocate (redlist)
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine setunion  --  get UnionBall coordinates & radii  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "setunion" gets the coordinates and radii of the balls, and
c     stores these into data structures used in UnionBall
c
c     variables and parameters:
c
c     nsphere   number of points (spheres) to be triangulated
c     coords    Cartesian coordinates of all spheres
c     radii     radius of each sphere, used to set weights for
c                 regular triangulation related to radius squared
c
c
      subroutine setunion (nsphere,coords,radii)
      use shapes
      implicit none
      integer ndigit
      integer nsize,nfudge
      integer nsphere
      integer new_points
      integer i,j,k,ip,jp
      integer, allocatable :: ranlist(:)
      real*8 crdmax,epsd
      real*8 x,xval,sum
      real*8 y,z,w,xi,yi,zi,wi,r
      real*8 brad(3),bcoord(9)
      real*8 coords(*)
      real*8 radii(*)
      real*8, allocatable :: ranval(:)
      save
c
c
c     define array sizes used for memory allocation
c
      nfudge = 10
      nsize = nsphere + nfudge
      maxtetra = 10 * nsize
c
c     set number of digits for truncation of real numbers
c
      ndigit = 8
c
c     perform dynamic allocation of some global arrays
c
      if (allocated(vinfo)) then
         if (size(vinfo) .lt. nsize) then
            deallocate (vinfo)
            deallocate (crdball)
            deallocate (radball)
            deallocate (wghtball)
         end if
      end if
      if (allocated(tinfo)) then
         if (size(tinfo) .lt. ntetra) then
            deallocate (tetra)
            deallocate (tneighbor)
            deallocate (tinfo)
            deallocate (tnindex)
         end if
      end if
      if (.not. allocated(vinfo))  allocate (vinfo(nsize))
      if (.not. allocated(crdball))  allocate (crdball(3*nsize))
      if (.not. allocated(radball))  allocate (radball(nsize))
      if (.not. allocated(wghtball))  allocate (wghtball(nsize))
      if (.not. allocated(tetra))  allocate (tetra(4,maxtetra))
      if (.not. allocated(tneighbor))  allocate (tneighbor(4,maxtetra))
      if (.not. allocated(tinfo))  allocate (tinfo(maxtetra))
      if (.not. allocated(tnindex))  allocate (tnindex(maxtetra))
c
c     perform dynamic allocation of some local arrays
c
      allocate (ranlist(nsize))
      allocate (ranval(3*nsize))
c
c     truncate input coordinates to desired precision
c
      npoint = nsphere
      crdmax = 0.0d0
      do i = 1, npoint
         vinfo(i) = 0
         vinfo(i) = ibset(vinfo(i),0)
         x = radii(i)
         call truncate_real (x,xval,ndigit)
         radball(i) = xval
         do j = 1, 3
            k = 3*(i-1) + j
            x = coords(k)
            call truncate_real (x,xval,ndigit)
            crdball(k) = xval
            if (abs(crdball(k)) .gt. crdmax)  crdmax = abs(crdball(k))
         end do
      end do
      crdmax = max(100.0d0,crdmax)
c
c     machine precision is smallest value different from zero;
c     note "epsd" may become zero if compiled with optimization
c
      sum = 10.0d0
      epsd = 1.0d0
      do while (sum .gt. 1.0d0)
         epsd = epsd / 2.0d0
         sum = 1.0d0 + epsd
      end do
      epsd = 2.0d0 * epsd
c
c     use typical value from compilation without optimization
c
      epsd = 0.222045d-15
c
c     set tolerance values based upon the machine precision
c
      epsln2 = epsd * crdmax * crdmax
      epsln3 = epsln2 * crdmax
      epsln4 = epsln3 * crdmax
      epsln5 = epsln4 * crdmax
      epsln2 = 1.0d-1
      epsln3 = 1.0d-1
      epsln4 = 1.0d-1
      epsln5 = 1.0d-1
c
c     precompute the weight value for each of the points
c
      do i = 1, npoint
         x = crdball(3*(i-1)+1)
         y = crdball(3*(i-1)+2)
         z = crdball(3*(i-1)+3)
         r = radball(i)
         call build_weight (x,y,z,r,w)
         wghtball(i) = w
      end do
c
c     check for trivial redundancy with same point twice
c
      do i = 1, 3*npoint
         ranval(i) = crdball(i)
      end do
      call hpsort_three (ranval,ranlist,npoint)
      jp = ranlist(1)
      x = crdball(3*jp-2)
      y = crdball(3*jp-1)
      z = crdball(3*jp)
      w = radball(jp)
      do i = 2, npoint
         ip = ranlist(i)
         xi = crdball(3*ip-2)
         yi = crdball(3*ip-1)
         zi = crdball(3*ip)
         wi = radball(ip)
         if ((xi-x)**2+(yi-y)**2+(zi-z)**2 .le. 100.0d0*epsd) then
            if (wi .le. w) then
               vinfo(ip) = ibclr(vinfo(ip),0)
            else
               vinfo(jp) = ibclr(vinfo(jp),0)
               jp = ip
               w = wi
            end if
         else
            x = xi
            y = yi
            z = zi
            w = wi
            jp = ip
         end if
      end do
      if (npoint .lt. 4) then
         new_points = 4 - npoint;
         call addbogus (bcoord, brad)
         do i = 1, new_points
            npoint = npoint + 1
            x = bcoord(3*(i-1)+1);
            y = bcoord(3*(i-1)+2);
            z = bcoord(3*(i-1)+3);
            r = brad(i);
            call build_weight (x,y,z,r,w)
            crdball(3*(npoint-1)+1) = x
            crdball(3*(npoint-1)+2) = y
            crdball(3*(npoint-1)+3) = z
            radball(npoint) = r
            wghtball(npoint) = w
            vinfo(npoint) = 0
            vinfo(npoint) = ibset(vinfo(npoint),0)
         end do
      end if
c
c     initialization for the four added infinite points
c
      do i = 3*npoint, 1, -1
         crdball(i+12) = crdball(i)
      end do
      do i = npoint, 1, -1
         radball(i+4) = radball(i)
         wghtball(i+4) = wghtball(i)
         vinfo(i+4) = vinfo(i)
      end do
      nvertex = npoint + 4
      do i = 1, 12
         crdball(i) = 0.0d0
      end do
      do i = 1, 4
         radball(i) = 0.0d0
         wghtball(i) = 0.0d0
         vinfo(i) = 0
         vinfo(i) = ibset(vinfo(i),0)
      end do
c
c     initialize tetrahedra for Delaunay calculation
c
      ntetra = 1
      tetra(1,ntetra) = 1
      tetra(2,ntetra) = 2
      tetra(3,ntetra) = 3
      tetra(4,ntetra) = 4
      tneighbor(1,ntetra) = 0
      tneighbor(2,ntetra) = 0
      tneighbor(3,ntetra) = 0
      tneighbor(4,ntetra) = 0
      tinfo(ntetra) = 0
      tinfo(ntetra) = ibset(tinfo(ntetra),1)
c
c     orientation is right most bit, bit=0 means -1, bit=1 means 1;
c     the orientation of the first tetrahedron is -1
c
      tinfo(ntetra) = ibclr(tinfo(ntetra),0)
c
c     perform deallocation of some local arrays
c
      deallocate (ranlist)
      deallocate (ranval)
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine regular3  --  triangulation of a set of points  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "regular3" computes the regular triangulation of a set of N
c     weighted points in 3D using the incremental flipping algorithm
c     of Herbert Edelsbrunner
c
c     literature reference:
c
c     H. Edelsbrunner and N. R. Shah, "Incremental Topological
c     Flipping Works for Regular Triangulations", Algorithmica,
c     15, 223-241 (1996)
c
c     algorithm summary:
c
c     (1) initialize the procedure with a big tetrahedron, all four
c     vertices of this tetrahedron are set at "infinite", (2) all N
c     points are added one by one, (3) for each point localize the
c     tetrahedron in the current regular triangulation that contains
c     this point, (4) test if the point is redundant, and is so then
c     remove it, (5) if the point is not redundant, insert it in the
c     tetrahedron via a "1-4" flip, (6) collect all "link facets",
c     (i.e., all triangles in tetrahedron containing the new point,
c     that face this new point) that are not regular, (7) for each
c     non-regular link facet, check if it is "flippable", (8) if yes,
c     perform a "2-3", "3-2" or "1-4" flip, add new link facets in
c     the list if needed, (9) when link facet list is empty, move to
c     next point, (10) remove "infinite" tetrahedra, which are those
c     with one vertex at "infinite", and (11) collect the remaining
c     tetrahedra, and define convex hull
c
c
      subroutine regular3 (nredundant,redlist)
      use shapes
      implicit none
      integer i,ival
      integer iredundant
      integer iflag,iseed
      integer tetra_loc
      integer tetra_last
      integer nredundant
      integer maxfree,maxkill
      integer maxlink,maxnew
      integer npeel_try
      integer redlist(*)
      save
c
c
c     perform dynamic allocation of some global arrays
c
      maxnew = 20000
      maxfree = 20000
      maxkill = 20000
      maxlink = 20000
      allocate (newlist(maxnew))
      allocate (freespace(maxfree))
      allocate (killspace(maxkill))
      allocate (linkfacet(2,maxlink))
      allocate (linkindex(2,maxlink))
c
c     initialize the size of "free" space to zero
c
      nfree = 0
      nnew = 0
c
c     build regular triangulation, now loop over all points
c
      tetra_last = -1
      iseed = -1
      do i = 1, npoint
         ival = i + 4
         nnew = 0
         if (btest(vinfo(ival),0)) then
            tetra_loc = tetra_last
            call locate_jw (iseed,ival,tetra_loc,iredundant)
            if (iredundant .eq. 1) then
               vinfo(ival) = ibclr(vinfo(ival),0)
               goto 10
            end if
            call flipjw_1_4 (ival,tetra_loc,tetra_last)
            call flipjw (tetra_last)
            if (ntetra .gt. (9*maxtetra)/10)  call resize_tet
   10       continue
         end if
      end do
c
c     reorder tetrahedra, so vertices are in increasing order
c
      iflag = 1
      call reorder_tetra (iflag,nnew,newlist)
c
c     regular triangulation complete; remove the simplices
c     including infinite points, and define the convex hull
c
      call remove_inf
c
c     peel off flat tetrahedra at the boundary of the DT
c
      npeel_try = 1
      do while (npeel_try .gt. 0)
         call peel (npeel_try)
      end do
c
c     define the list of redundant points
c
      nredundant = 0
      do i = 1, npoint
         if (.not. btest(vinfo(i+4),0)) then
            nredundant = nredundant + 1
            redlist(nredundant) = i
         end if
      end do
c
c     perform deallocation of some global arrays
c
      deallocate (newlist)
      deallocate (freespace)
      deallocate (killspace)
      deallocate (linkfacet)
      deallocate (linkindex)
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine alfcx  --  construction of the alpha complex  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "alfcx" builds the alpha complex based on the weighted
c     Delaunay triangulation used by UnionBall
c
c
      subroutine alfcx (alpha,nred,redlist)
      use shapes
      implicit none
      integer i,j,k,l,m
      integer ia,ib,i1,i2
      integer ntrig,icheck
      integer ntet_del,ntet_alp
      integer idx,iflag,nred
      integer irad,iattach,ival
      integer itrig,jtrig,iedge
      integer trig1,trig2,trig_in
      integer trig_out,triga,trigb
      integer jtetra,itetra,ktetra
      integer npass,ipair,i_out
      integer other3(3,4)
      integer face_info(2,6)
      integer face_pos(2,6)
      integer pair(2,6)
      integer redlist(*)
      integer, allocatable :: chklist(:)
      integer, allocatable :: tmask(:)
      real*8 ra,rb,rc,rd,re
      real*8 alpha
      real*8 a(4),b(4),c(4)
      real*8 d(4),e(4),cg(3)
      logical testa,testb,test_edge
      data other3   / 2, 3, 4, 1, 3, 4, 1, 2, 4, 1, 2, 3 /
      data face_info  / 1, 2, 1, 3, 1, 4, 2, 3, 2, 4, 3, 4 /
      data face_pos  / 2, 1, 3, 1, 4, 1, 3, 2, 4, 2, 4, 3 /
      data pair  / 3, 4, 2, 4, 2, 3, 1, 4, 1, 3, 1, 2 /
      save
c
c
c     perform dynamic allocation of some local arrays
c
      allocate (chklist(40000))
      allocate (tmask(ntetra))
c
c     perform dynamic allocation of some global arrays
c
      if (allocated(tedge)) then
         if (size(tedge) .lt. ntetra)  deallocate (tedge)
      end if
      if (.not. allocated(tedge))  allocate (tedge(ntetra))
c
c     initialization and setup of masking variables
c
      ival = 0
      do i = 1, ntetra
         tmask(i) = 0
         call mvbits (ival,0,5,tinfo(i),3)
      end do
c
c     loop over all tetrahedra, any "dead" tetrahedra are ignored
c
      ntet_del = 0
      ntet_alp = 0
      do idx = 1, ntetra
         if (btest(tinfo(idx),1)) then
            ntet_del = ntet_del + 1
            i = tetra(1,idx)
            j = tetra(2,idx)
            k = tetra(3,idx)
            l = tetra(4,idx)
            call get_coord4 (i,j,k,l,a,b,c,d,ra,rb,rc,rd,cg)
            call alf_tetra (a,b,c,d,ra,rb,rc,rd,iflag,alpha)
            if (iflag .eq. 1) then
               tinfo(idx) = ibset(tinfo(idx),7)
               ntet_alp = ntet_alp + 1
            end if
         end if
      end do
c
c     loop over all triangles; each triangle is defined implicitly
c     as the interface between two tetrahedra i and j with i < j
c
      ntrig = 0
      do idx = 1, ntetra
         if (btest(tinfo(idx),1)) then
            do itrig = 1, 4
               jtetra = tneighbor(itrig,idx)
               ival = ibits(tnindex(idx),2*(itrig-1),2)
               jtrig = ival + 1
               if (jtetra.eq.0 .or. jtetra.gt.idx) then
c
c     checking the triangle defined by itetra and jtetra,
c     if one of them belongs to the alpha complex, then
c     the triangle belongs to the alpha complex
c
                  if (btest(tinfo(idx),7)) then
                     tinfo(idx) = ibset(tinfo(idx),2+itrig)
                     ntrig = ntrig + 1
                     if (jtetra .ne. 0) then
                        tinfo(jtetra) = ibset(tinfo(jtetra),2+jtrig)
                     end if
                     goto 10
                  end if
                  if (jtetra .ne. 0) then
                     if (btest(tinfo(jtetra),7)) then
                        tinfo(idx) = ibset(tinfo(idx),2+itrig)
                        tinfo(jtetra) = ibset(tinfo(jtetra),2+jtrig)
                        ntrig = ntrig + 1
                        goto 10
                     end if
                  end if
c
c     the two attached tetrahedra do not belong to the alpha complex,
c     so need to check the triangle itself; define the three vertices
c     of the triangle, as well as the two remaining vertices of the
c     two tetrahedra attached to triangle
c
                  i = tetra(other3(1,itrig),idx)
                  j = tetra(other3(2,itrig),idx)
                  k = tetra(other3(3,itrig),idx)
                  l = tetra(itrig,idx)
                  if (jtetra .ne. 0) then
                     m = tetra(jtrig,jtetra)
                     call get_coord5 (i,j,k,l,m,a,b,c,d,e,
     &                                ra,rb,rc,rd,re,cg)
                  else
                     m = 0
                     call get_coord4 (i,j,k,l,a,b,c,d,ra,rb,rc,rd,cg)
                  end if
                  call alf_trig (a,b,c,d,e,ra,rb,rc,rd,re,
     &                           m,irad,iattach,alpha)
                  if (iattach.eq.0 .and. irad.eq.1) then
                     l = 1
                     tinfo(idx) = ibset(tinfo(idx),2+itrig)
                     ntrig = ntrig + 1
                     if (jtetra .ne. 0) then
                        tinfo(jtetra) = ibset(tinfo(jtetra),2+jtrig)
                     end if
                  end if
               end if
   10          continue
            end do
         end if
      end do
c
c     loop over all edges; each edge is defined implicitly
c     by the tetrahedra to which it belongs
c
      do idx = 1, ntetra
         tmask(idx) = 0
         tedge(idx) = 0
      end do
      maxedge = 0
      do itetra = 1, ntetra
         if (btest(tinfo(itetra),1)) then
            do iedge = 1, 6
               if (btest(tmask(itetra),iedge-1))  goto 50
               test_edge = .false.
c
c     for each edge, check triangles attached to the edge
c     if at least one of these triangles is in alpha complex,
c     then the edge is in the alpha complex;
c     put the two vertices directly in the alpha complex;
c     otherwise, build list of triangles to check
c
c     itetra is one tetrahedron (a,b,c,d) containing the edge
c
c     iedge is the edge number in the tetrahedron itetra, with:
c     iedge=1 (c,d), iedge=2 (b,d), iedge=3 (b,c),
c     iedge=4 (a,d), iedge=5 (a,c), iedge=6 (a,b)
c
c     define indices of the edge
c
               i = tetra(pair(1,iedge),itetra)
               j = tetra(pair(2,iedge),itetra)
c
c     trig1 and trig2 are the two faces of itetra sharing iedge, i1
c     and i2 are positions of the third vertices of trig1 and trig2
c
               trig1 = face_info(1,iedge)
               i1 = face_pos(1,iedge)
               trig2 = face_info(2,iedge)
               i2 = face_pos(2,iedge)
               ia = tetra(i1,itetra)
               ib = tetra(i2,itetra)
               icheck = 0
               if (btest(tinfo(itetra),2+trig1)) then
                  test_edge = .true.
               else
                  icheck = icheck + 1
                  chklist(icheck) = ia
               end if
               if (btest(tinfo(itetra),2+trig2)) then
                  test_edge = .true.
               else
                  icheck = icheck + 1
                  chklist(icheck) = ib
               end if
c
c     now we look at the star of the edge
c
               ktetra = itetra
               npass = 1
               trig_out = trig1
               jtetra = tneighbor(trig_out,ktetra)
   20          continue
c
c     leave this side of the star if we hit the convex hull
c
               if (jtetra .eq. 0)  goto 30
c
c     leave the loop completely if we have described the full cycle
c
               if (jtetra .eq. itetra)  goto 40
c
c     identify the position of iedge in tetrahedron jtetra
c
               if (i .eq. tetra(1,jtetra)) then
                  if (j .eq. tetra(2,jtetra)) then
                     ipair = 6
                  else if (j .eq. tetra(3,jtetra)) then
                     ipair = 5
                  else
                     ipair = 4
                  end if
               else if (i .eq. tetra(2,jtetra)) then
                  if (j .eq. tetra(3,jtetra)) then
                     ipair = 3
                  else
                     ipair = 2
                  end if
               else
                  ipair = 1
               end if
               tmask(jtetra) = ibset(tmask(jtetra),ipair-1)
c
c     determine the face we "went in"
c
               ival = ibits(tnindex(ktetra),2*(trig_out-1),2)
               trig_in = ival + 1
c
c     we know the two faces of jtetra that share iedge
c
               triga = face_info(1,ipair)
               i1 = face_pos(1,ipair)
               trigb = face_info(2,ipair)
               i2 = face_pos(2,ipair)
               trig_out = triga
               i_out = i1
               if (trig_in .eq. triga) then
                  i_out = i2
                  trig_out = trigb
               end if
c
c     check if trig_out is already in the alpha complex; if it
c     is then iedge is in, otherwise, will need an attach test
c
               if (btest(tinfo(jtetra),2+trig_out)) then
                  test_edge = .true.
               end if
               ktetra = jtetra
               jtetra = tneighbor(trig_out,ktetra)
               if (jtetra .eq. itetra)  goto 40
               icheck = icheck + 1
               chklist(icheck) = tetra(i_out,ktetra)
               goto 20
   30          continue
               if (npass .eq. 2)  goto 40
               npass = npass + 1
               ktetra = itetra
               trig_out = trig2
               jtetra = tneighbor(trig_out,ktetra)
               goto 20
   40          continue
               if (test_edge) then
                  tedge(itetra) = ibset(tedge(itetra),iedge-1)
                  maxedge = maxedge + 1
                  vinfo(i) = ibset(vinfo(i),7)
                  vinfo(j) = ibset(vinfo(j),7)
                  goto 50
               end if
c
c     if here, it means that none of the triangles in the star
c     of the edge belongs to the alpha complex, so a singular edge
c    
c     check if the edge is attached, and if alpha is smaller than
c     the radius of the sphere orthogonal to the two balls
c     corresponding to the edge
c
               call get_coord2 (i,j,a,b,ra,rb,cg)
               call alf_edge (a,b,ra,rb,cg,icheck,chklist,
     &                        irad,iattach,alpha)
               if (iattach.eq.0 .and. irad.eq.1) then
                  tedge(itetra) = ibset(tedge(itetra),iedge-1)
                  maxedge = maxedge + 1
                  vinfo(i) = ibset(vinfo(i),7)
                  vinfo(j) = ibset(vinfo(j),7)
                  goto 50
               end if
c
c     edge is not in alpha complex: now check if the two vertices
c     could be attached to each other: 
c
               call vertex_attach (a,b,ra,rb,testa,testb)        
               if (testa)  vinfo(i) = ibset(vinfo(i),6)
               if (testb)  vinfo(j) = ibset(vinfo(j),6)
   50          continue
            end do
         end if
      end do
c
c     safeguard minimum edge count to handle small system dimensions
c
      maxedge = max(maxedge,nvertex+10)
c
c     loop over each of the vertices; nothing to do if vertex
c     was already set in alpha complex; vertex is in alpha complex,
c     unless it is attached
c
      nred = 0
      do i = 1, nvertex
         if (btest(vinfo(i),0)) then
            if (.not. btest(vinfo(i),7)) then
               if (.not. btest(vinfo(i),6)) then
                  vinfo(i) = ibset(vinfo(i),7)
               else
                  nred = nred + 1
                  redlist(nred) = i
               end if
            end if
         end if
      end do
c
c     perform deallocation of some local arrays
c
      deallocate (chklist)
      deallocate (tmask)
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine readjust_sphere  --  remove artificial spheres  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "readjust_sphere" removes artificial spheres for UnionBall
c     systems containing fewer than four spheres
c
c
      subroutine readjust_sphere (nsphere,nredundant,redlist)
      use shapes
      implicit none
      integer i,j
      integer nsphere
      integer nredundant
      integer redlist(*)
      save
c
c
c     if fewer than four balls, set artificial spheres as redundant
c
      if (nsphere .lt. 4) then
         do i = nsphere+5, 8
            vinfo(i) = 1
         end do
         npoint = nsphere
         nvertex = npoint + 4
         j = 0
         do i = 1, nredundant
            if (redlist(i) .le. nsphere) then
               j = j + 1
               redlist(j) = redlist(i)
            end if
         end do
      end if
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine ball_surf  --  find area of union of spheres  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "ball_surf" computes the weighted accessible surface area of
c     a union of spheres
c
c     variables and parameters:
c
c     coef        sphere weights for the weighted surface
c     wsurf       weighted surface area
c     surf        unweighted surface area
c     ballwsurf   weighted contribution of each ball
c
c
      subroutine ball_surf (coef,wsurf,surf,ballwsurf)
      use math
      use shapes
      implicit none
      integer i,j
      integer ia,ib,ic,id
      integer i1,nedge
      integer idx,ilast
      integer itrig,iedge
      integer ival,it1,it2
      integer jtetra
      integer face_info(2,6)
      integer face_pos(2,6)
      integer pair(2,6)
      integer, allocatable :: sparse_row (:)
      integer, allocatable :: edges (:,:)
      real*8 ra,rb,rc,rd
      real*8 ra2,rb2,rc2,rd2
      real*8 rab,rac,rad
      real*8 rbc,rbd,rcd
      real*8 rab2,rac2,rad2
      real*8 rbc2,rbd2,rcd2
      real*8 coefval
      real*8 surfa,surfb,surfc,surfd
      real*8 a(3),b(3),c(3),d(3)
      real*8 angle(6),cosine(6),sine(6)
      real*8 wsurf,surf
      real*8 coef(*),ballwsurf(*)
      real*8, allocatable :: coef_edge(:)
      real*8, allocatable :: coef_vertex(:)
      data face_info  / 1, 2, 1, 3, 1, 4, 2, 3, 2, 4, 3, 4 /
      data face_pos  / 2, 1, 3, 1, 4, 1, 3, 2, 4, 2, 4, 3 /
      data pair  / 3, 4, 2, 4, 2, 3, 1, 4, 1, 3, 1, 2 /
      save
c
c
c     perform dynamic allocation of some local arrays
c
      allocate (sparse_row(nvertex+10))
      allocate (edges(2,maxedge))
      allocate (coef_edge(maxedge))
      allocate (coef_vertex(nvertex))
c
c     initialize result values
c
      wsurf = 0.0d0
      surf = 0.0d0
      do i = 1, nvertex
         ballwsurf(i) = 0.0d0
      end do
c
c     find list of all edges in the alpha complex
c
      nedge = 0
      call find_edges (nedge,edges)
c
c     define sparse structure for edges
c
      ilast = 0
      do i = 1, nedge
         ia = edges(1,i)
         ib = edges(2,i)
         if (ia .ne. ilast) then
            do j = ilast+1, ia
               sparse_row(j) = i
            end do 
            ilast = ia
         end if
         coef_edge(i) = 1.0d0
      end do
      do i = ia+1, nvertex
         sparse_row(i) = nedge + 1
      end do
c
c     build list of fully buried vertices; these vertices are part
c     of the alpha complex, and all edges that start or end at these
c     vertices are buried
c
      do i = 1, nvertex
         coef_vertex(i) = 1.0d0
      end do
c
c     contribution of four spheres; use the weighted inclusion-exclusion
c     formula; each tetrahedron in the Alpha Complex only contributes
c     to the weight of each its edges and each of its vertices
c
      do idx = 1, ntetra
         if (btest(tinfo(idx),7)) then
            ia = tetra(1,idx)
            ib = tetra(2,idx)
            ic = tetra(3,idx)
            id = tetra(4,idx)
            do i = 1, 3
               a(i) = crdball(3*(ia-1)+i)
               b(i) = crdball(3*(ib-1)+i)
               c(i) = crdball(3*(ic-1)+i)
               d(i) = crdball(3*(id-1)+i)
            end do
            ra = radball(ia)
            rb = radball(ib)
            rc = radball(ic)
            rd = radball(id)
            ra2 = ra * ra
            rb2 = rb * rb
            rc2 = rc * rc
            rd2 = rd * rd
            call distance2 (crdball,ia,ib,rab2)
            call distance2 (crdball,ia,ic,rac2)
            call distance2 (crdball,ia,id,rad2)
            call distance2 (crdball,ib,ic,rbc2)
            call distance2 (crdball,ib,id,rbd2)
            call distance2 (crdball,ic,id,rcd2)
            rab = sqrt(rab2)
            rac = sqrt(rac2)
            rad = sqrt(rad2)
            rbc = sqrt(rbc2)
            rbd = sqrt(rbd2)
            rcd = sqrt(rcd2)
            call tetra_dihed (rab2,rac2,rad2,rbc2,rbd2,
     &                        rcd2,angle,cosine,sine)
c
c     weights on each vertex; fraction of solid angle
c
            coef_vertex(ia) = coef_vertex(ia) + 0.25d0
     &                           - (angle(1)+angle(2)+angle(3))/2.0d0
            coef_vertex(ib) = coef_vertex(ib) + 0.25d0
     &                           - (angle(1)+angle(4)+angle(5))/2.0d0
            coef_vertex(ic) = coef_vertex(ic) + 0.25d0
     &                           - (angle(2)+angle(4)+angle(6))/2.0d0
            coef_vertex(id) = coef_vertex(id) + 0.25d0
     &                           - (angle(3)+angle(5)+angle(6))/2.0d0
c
c     weights on each edge; fraction of dihedral angle
c
c     iedge is the edge number in the tetrahedron idx with:
c     iedge = 1 (c,d), iedge = 2 (b,d), iedge = 3 (b,c),
c     iedge = 4 (a,d), iedge = 5 (a,c), iedge = 6 (a,b)
c
c     define indices of the edge
c
            do iedge = 1, 6
               i = tetra(pair(1,iedge),idx)
               j = tetra(pair(2,iedge),idx)
c
c     find which edge this corresponds to
c
               do i1 = sparse_row(i), sparse_row(i+1)-1
                  if (edges(2,i1) .eq. j)  goto 10
               end do
               goto 20
   10          continue
               if (coef_edge(i1) .ne. 0.0d0) then
                  coef_edge(i1) = coef_edge(i1) - angle(7-iedge)
               end if
   20          continue
            end do
c
c     all the edge lengths have been precomputed, check triangles
c
c     check the four faces of the tetrahedron; any exposed face
c     (on the convex hull, or facing a tetrahedron from the Delaunay
c     that is not part of the alpha complex), contributes
c
            do itrig = 1, 4
               jtetra = tneighbor(itrig,idx)
               if (jtetra.eq.0 .or. jtetra.gt.idx) then
                  if (btest(tinfo(idx),2+itrig)) then
                     if (jtetra .ne. 0) then
                        call mvbits (tinfo(jtetra),7,1,it2,0)
                     else
                        it2 = 0
                     end if
                     ival = 1 - it2
                     if (ival .eq. 0)  goto 30
                     coefval = 0.5d0 * dble(ival)
                     if (itrig .eq. 1) then
                        surfa = 0.0d0
                        call threesphere_surf (rb,rc,rd,rb2,rc2,rd2,
     &                                         rbc,rbd,rcd,rbc2,rbd2,
     &                                         rcd2,surfb,surfc,surfd)
                     else if (itrig .eq. 2) then
                        surfb = 0.0d0
                        call threesphere_surf (ra,rc,rd,ra2,rc2,rd2,
     &                                         rac,rad,rcd,rac2,rad2,
     &                                         rcd2,surfa,surfc,surfd)
                     else if (itrig .eq. 3) then
                        surfc = 0.0d0
                        call threesphere_surf (ra,rb,rd,ra2,rb2,rd2,
     &                                         rab,rad,rbd,rab2,rad2,
     &                                         rbd2,surfa,surfb,surfd)
                     else if (itrig .eq. 4) then
                        surfd = 0.0d0
                        call threesphere_surf (ra,rb,rc,ra2,rb2,rc2,
     &                                         rab,rac,rbc,rab2,rac2,
     &                                         rbc2,surfa,surfb,surfc)
                     end if
                     ballwsurf(ia) = ballwsurf(ia) + coefval*surfa
                     ballwsurf(ib) = ballwsurf(ib) + coefval*surfb
                     ballwsurf(ic) = ballwsurf(ic) + coefval*surfc
                     ballwsurf(id) = ballwsurf(id) + coefval*surfd
                  end if
               end if
   30          continue
            end do
         end if
      end do
c
c     contribution of three balls (triangles of the alpha complex);
c     already checked the triangles from tetrahedra that belongs
c     to the alpha complex; now we check any singular triangles
c     (face of a tetrahedron in the Delaunay complex, but not in
c     the alpha shape)
c
c     loop over all tetrahedra, and check its four faces; any face
c     that is exposed (on the convex hull, or facing a tetrahedron
c     from the Delaunay that is not in the alpha complex), contributes
c
      do idx = 1, ntetra
         if (btest(tinfo(idx),1)) then
            if (.not. btest(tinfo(idx),7)) then
               ia = tetra(1,idx)
               ib = tetra(2,idx)
               ic = tetra(3,idx)
               id = tetra(4,idx)
               do i = 1, 3
                  a(i) = crdball(3*(ia-1)+i)
                  b(i) = crdball(3*(ib-1)+i)
                  c(i) = crdball(3*(ic-1)+i)
                  d(i) = crdball(3*(id-1)+i)
               end do
               ra = radball(ia)
               rb = radball(ib)
               rc = radball(ic)
               rd = radball(id)
               ra2 = ra * ra
               rb2 = rb * rb
               rc2 = rc * rc
               rd2 = rd * rd
               rab = 0.0d0
               rac = 0.0d0
               rad = 0.0d0
               rbc = 0.0d0
               rbd = 0.0d0
               rcd = 0.0d0
c
c     check triangles
c
               do itrig = 1, 4
                  jtetra = tneighbor(itrig,idx)
                  if (jtetra.eq.0 .or. jtetra.gt.idx) then
                     if (btest(tinfo(idx),2+itrig)) then
                        call mvbits (tinfo(idx),7,1,it1,0)
                        if (jtetra .ne. 0) then
                           call mvbits (tinfo(jtetra),7,1,it2,0)
                        else
                            it2 = 0
                        end if
                        ival = 2 - it1 - it2
                        if (ival .eq. 0)  goto 40
                        coefval = 0.5d0 * dble(ival)
                        surfa = 0.0d0
                        surfb = 0.0d0
                        surfc = 0.0d0
                        surfd = 0.0d0
                        if (itrig .eq. 1) then
                           call triangle_surf (b,c,d,rbc,rbd,rcd,
     &                                         rbc2,rbd2,rcd2,rb,
     &                                         rc,rd,rb2,rc2,rd2,
     &                                         surfb,surfc,surfd)
                        else if (itrig .eq. 2) then
                           call triangle_surf (a,c,d,rac,rad,rcd,
     &                                         rac2,rad2,rcd2,ra,
     &                                         rc,rd,ra2,rc2,rd2,
     &                                         surfa,surfc,surfd)
                        else if (itrig .eq. 3) then
                           call triangle_surf (a,b,d,rab,rad,rbd,
     &                                         rab2,rad2,rbd2,ra,
     &                                         rb,rd,ra2,rb2,rd2,
     &                                         surfa,surfb,surfd)
                        else if (itrig .eq. 4) then
                           call triangle_surf (a,b,c,rab,rac,rbc,
     &                                         rab2,rac2,rbc2,ra,
     &                                         rb,rc,ra2,rb2,rc2,
     &                                         surfa,surfb,surfc)
                        end if
                        ballwsurf(ia) = ballwsurf(ia) + coefval*surfa
                        ballwsurf(ib) = ballwsurf(ib) + coefval*surfb
                        ballwsurf(ic) = ballwsurf(ic) + coefval*surfc
                        ballwsurf(id) = ballwsurf(id) + coefval*surfd
                     end if
                  end if
   40             continue
               end do
            end if
         end if
      end do
c
c     now add the contribution of two sphere
c
      do iedge = 1, nedge
         if (coef_edge(iedge) .ne. 0.0d0) then
            ia = edges(1,iedge)
            ib = edges(2,iedge)
            do i = 1, 3
               a(i) = crdball(3*(ia-1)+i)
               b(i) = crdball(3*(ib-1)+i)
            end do
            ra = radball(ia)
            rb = radball(ib)
            ra2 = ra * ra
            rb2 = rb * rb
            call distance2 (crdball,ia,ib,rab2)
            rab = sqrt(rab2)
            call twosphere_surf (ra,ra2,rb,rb2,rab,rab2,surfa,surfb)
            ballwsurf(ia) = ballwsurf(ia) - coef_edge(iedge)*surfa
            ballwsurf(ib) = ballwsurf(ib) - coef_edge(iedge)*surfb
         end if
      end do
c
c     next loop over all of the vertices
c
      do i = 1, nvertex
         if (.not. btest(vinfo(i),0))  goto 50
c
c     if vertex is not in alpha-complex, then nothing to do
c
         if (.not. btest(vinfo(i),7))  goto 50
c
c     vertex is in alpha complex; if its weight is 0 such
c     that it is buried, then nothing to do
c
         if (coef_vertex(i) .eq. 0.0d0)  goto 50
         ra = radball(i)
         ballwsurf(i) = ballwsurf(i) + coef_vertex(i)*4.0d0*pi*ra*ra
   50    continue
      end do
c
c     compute total surface (weighted, and unweighted)
c
      do i = 5, nvertex
         if (btest(vinfo(i),0)) then
            surf = surf + ballwsurf(i)
            ballwsurf(i-4) = ballwsurf(i) * coef(i-4)
            wsurf = wsurf + ballwsurf(i-4)
         end if
      end do
c
c     perform deallocation of some local arrays
c
      deallocate (sparse_row)
      deallocate (edges)
      deallocate (coef_edge)
      deallocate (coef_vertex)
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine ball_vol  --  find volume of union of spheres  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "ball_vol" computes the weighted surface area of a union of
c     spheres and the corresponding weighted excluded volume
c
c     variables and parameters:
c
c     coef        weight of each sphere for the weighted surface
c     wsurf       weighted surface area
c     wvol        weighted volume
c     surf        unweighted surface area
c     vol         unweighted volume
c     ballwsurf   weighted contribution of each ball to wsurf
c     ballwvol    weighted contribution of each ball to wvol
c
c
      subroutine ball_vol (coef,wsurf,wvol,surf,
     &                     vol,ballwsurf,ballwvol)
      use math
      use shapes
      implicit none
      integer i,j,i1
      integer ia,ib,ic,id
      integer nedge,ntrig
      integer idx,ilast
      integer itrig,iedge,nred
      integer ival,it1,it2
      integer jtetra
      integer face_info(2,6)
      integer face_pos(2,6)
      integer pair(2,6)
      integer flag(6)
      integer, allocatable :: sparse_row (:)
      integer, allocatable :: edges (:,:)
      real*8 ra,rb,rc,rd
      real*8 ra2,rb2,rc2,rd2
      real*8 rab,rac,rad
      real*8 rbc,rbd,rcd
      real*8 rab2,rac2,rad2
      real*8 rbc2,rbd2,rcd2
      real*8 coefval
      real*8 surfa,surfb,surfc,surfd
      real*8 vola,volb,volc,vold
      real*8 a(3),b(3),c(3),d(3)
      real*8 angle(6),cosine(6),sine(6)
      real*8 coef(*)
      real*8 wsurf,surf
      real*8 wvol,vol
      real*8 ballwsurf(*)
      real*8 ballwvol(*)
      real*8, allocatable :: coef_edge(:)
      real*8, allocatable :: coef_vertex(:)
      data face_info  / 1, 2, 1, 3, 1, 4, 2, 3, 2, 4, 3, 4 /
      data face_pos  / 2, 1, 3, 1, 4, 1, 3, 2, 4, 2, 4, 3 /
      data pair  / 3, 4, 2, 4, 2, 3, 1, 4, 1, 3, 1, 2 /
      save
c
c
c     perform dynamic allocation of some local arrays
c
      allocate (sparse_row(nvertex+10))
      allocate (edges(2,maxedge))
      allocate (coef_edge(maxedge))
      allocate (coef_vertex(nvertex))      
c
c     initialize results arrays
c
      wsurf = 0.0d0
      wvol = 0.0d0
      surf = 0.0d0
      vol = 0.0d0
      do i = 1, nvertex
         ballwsurf(i) = 0.0d0
         ballwvol(i) = 0.0d0
      end do
c
c     find list of all edges in the alpha complex
c
      nedge = 0
      call find_edges (nedge,edges)
c
c     sort list of all edges in increasing order
c
      ilast = 0
      do i = 1, nedge
         ia = edges(1,i)
         ib = edges(2,i)
         if (ia .ne. ilast) then
            do j = ilast+1, ia
               sparse_row(j) = i
            end do
            ilast = ia
         end if
         coef_edge(i) = 1
      end do
      do i = ia+1, nvertex
         sparse_row(i) = nedge + 1
      end do
c
c     set the weight of each vertex to one
c
      do i = 1, nvertex
         coef_vertex(i) = 1.0d0
      end do
c
c     contribution of four spheres using the weighted
c     inclusion-exclusion formula; each tetrahedron in the
c     alpha complex only contributes to the weight of each
c     its edges and each of its vertices
c
      ntrig = 0
      do idx = 1, ntetra
         if (btest(tinfo(idx),7)) then
            ia = tetra(1,idx)
            ib = tetra(2,idx)
            ic = tetra(3,idx)
            id = tetra(4,idx)
            do i = 1, 3
               a(i) = crdball(3*(ia-1)+i)
               b(i) = crdball(3*(ib-1)+i)
               c(i) = crdball(3*(ic-1)+i)
               d(i) = crdball(3*(id-1)+i)
            end do
            ra = radball(ia)
            rb = radball(ib)
            rc = radball(ic)
            rd = radball(id)
            ra2 = ra * ra
            rb2 = rb * rb
            rc2 = rc * rc
            rd2 = rd * rd
            call distance2 (crdball,ia,ib,rab2)
            call distance2 (crdball,ia,ic,rac2)
            call distance2 (crdball,ia,id,rad2)
            call distance2 (crdball,ib,ic,rbc2)
            call distance2 (crdball,ib,id,rbd2)
            call distance2 (crdball,ic,id,rcd2)
            rab = sqrt(rab2)
            rac = sqrt(rac2)
            rad = sqrt(rad2)
            rbc = sqrt(rbc2)
            rbd = sqrt(rbd2)
            rcd = sqrt(rcd2)
            call tetra_dihed (rab2,rac2,rad2,rbc2,rbd2,
     &                        rcd2,angle,cosine,sine)
c
c     if each ball has the same weight, add volume of the tetrahedron
c
            call tetra_voronoi (ra2,rb2,rc2,rd2,rab,rac,rad,rbc,rbd,
     &                          rcd,rab2,rac2,rad2,rbc2,rbd2,rcd2,
     &                          cosine,sine,vola,volb,volc,vold)
            ballwvol(ia) = ballwvol(ia) + vola
            ballwvol(ib) = ballwvol(ib) + volb
            ballwvol(ic) = ballwvol(ic) + volc
            ballwvol(id) = ballwvol(id) + vold
c
c     weights on each vertex: fraction of solid angle
c
            coef_vertex(ia) = coef_vertex(ia) + 0.25d0
     &                           - (angle(1)+angle(2)+angle(3))/2.0d0
            coef_vertex(ib) = coef_vertex(ib) + 0.25d0
     &                           - (angle(1)+angle(4)+angle(5))/2.0d0
            coef_vertex(ic) = coef_vertex(ic) + 0.25d0
     &                           - (angle(2)+angle(4)+angle(6))/2.0d0
            coef_vertex(id) = coef_vertex(id) + 0.25d0
     &                           - (angle(3)+angle(5)+angle(6))/2.0d0
c
c     weights on each edge: fraction of dihedral angle
c
c     iedge is the edge number in the tetrahedron idx, with
c     iedge = 1 (c,d), iedge = 2 (b,d), iedge = 3 (b,c),
c     iedge = 4 (a,d), iedge = 5 (a,c), iedge = 6 (a,b)
c
c     define indices of the edge
c
            do iedge = 1, 6
               i = tetra(pair(1,iedge),idx)
               j = tetra(pair(2,iedge),idx)
c
c     find which edge this corresponds to
c
               do i1 = sparse_row(i), sparse_row(i+1)-1
                  if (edges(2,i1) .eq. j)  goto 10
               end do
               goto 20
   10          continue
               if (coef_edge(i1) .ne. 0) then
                  coef_edge(i1) = coef_edge(i1) - angle(7-iedge)
               end if
   20          continue
            end do
c
c     since we have precomputed all the edge lengths, check triangles
c
c     we check the four faces of the tetrahedron; any face that
c     is exposed (on the convex hull, or facing a tetrahedron from
c     the Delaunay that is not part of the alpha complex), contributes
c
            do itrig = 1, 4
               jtetra = tneighbor(itrig,idx)
               if (jtetra.eq.0 .or. jtetra.gt.idx) then
                  if (btest(tinfo(idx),2+itrig)) then
                     if (jtetra .ne. 0) then
                        call mvbits (tinfo(jtetra),7,1,it2,0)
                     else
                        it2 = 0
                     end if
                     ival = 1 - it2
                     if (ival .eq. 0)  goto 30
                     coefval = 0.5d0 * dble(ival)
                     ntrig = ntrig + 1
                     if (itrig .eq. 1) then
                        surfa = 0.0d0
                        vola = 0.0d0
                        call threesphere_vol (rb,rc,rd,rb2,rc2,rd2,
     &                                        rbc,rbd,rcd,rbc2,rbd2,
     &                                        rcd2,surfb,surfc,surfd,
     &                                        volb,volc,vold)
                     else if (itrig.eq.2) then
                        surfb = 0.0d0
                        volb = 0.0d0
                        call threesphere_vol (ra,rc,rd,ra2,rc2,rd2,
     &                                        rac,rad,rcd,rac2,rad2,
     &                                        rcd2,surfa,surfc,surfd,
     &                                        vola,volc,vold)
                     else if (itrig .eq. 3) then
                        surfc = 0.0d0
                        volc = 0.0d0
                        call threesphere_vol (ra,rb,rd,ra2,rb2,rd2,
     &                                        rab,rad,rbd,rab2,rad2,
     &                                        rbd2,surfa,surfb,surfd,
     &                                        vola,volb,vold)
                     else if (itrig .eq. 4) then
                        surfd = 0.0d0
                        vold = 0.0d0
                        call threesphere_vol (ra,rb,rc,ra2,rb2,rc2,
     &                                        rab,rac,rbc,rab2,rac2,
     &                                        rbc2,surfa,surfb,surfc,
     &                                        vola,volb,volc)
                     end if
                     ballwsurf(ia) = ballwsurf(ia) + coefval*surfa
                     ballwsurf(ib) = ballwsurf(ib) + coefval*surfb
                     ballwsurf(ic) = ballwsurf(ic) + coefval*surfc
                     ballwsurf(id) = ballwsurf(id) + coefval*surfd
                     ballwvol(ia) = ballwvol(ia) + coefval*vola
                     ballwvol(ib) = ballwvol(ib) + coefval*volb
                     ballwvol(ic) = ballwvol(ic) + coefval*volc
                     ballwvol(id) = ballwvol(id) + coefval*vold
                  end if
               end if
   30          continue
            end do
         end if
      end do
c
c     contribution of 3-balls (i.e. triangles of the alpha complex);
c     already checked the triangles from tetrahedra that belongs to the
c     alpha complex; now we check any singular triangles (a face of a
c     tetrahedron in the Delaunay complex, but not in the alpha shape);
c     we loop over all tetrahedra, and check its four faces; any face
c     that is exposed (on the convex hull, or facing a tetrahedron from
c     the Delaunay that is not part of the alpha complex), contributes
c
      do idx = 1, ntetra
         if (btest(tinfo(idx),1)) then
            if (.not. btest(tinfo(idx),7)) then
               ia = tetra(1,idx)
               ib = tetra(2,idx)
               ic = tetra(3,idx)
               id = tetra(4,idx)
               do i = 1, 6
                  flag(i) = 0
               end do
               do i = 1, 3
                  a(i) = crdball(3*(ia-1)+i)
                  b(i) = crdball(3*(ib-1)+i)
                  c(i) = crdball(3*(ic-1)+i)
                  d(i) = crdball(3*(id-1)+i)
               end do
               ra = radball(ia)
               rb = radball(ib)
               rc = radball(ic)
               rd = radball(id)
               ra2 = ra * ra
               rb2 = rb * rb
               rc2 = rc * rc
               rd2 = rd * rd
               rab = 0.0d0
               rac = 0.0d0
               rad = 0.0d0
               rbc = 0.0d0
               rbd = 0.0d0
               rcd = 0.0d0
c
c     check triangles
c
               do itrig = 1, 4
                  jtetra = tneighbor(itrig,idx)
                  if (jtetra.eq.0 .or. jtetra.gt.idx) then
                     if (btest(tinfo(idx),2+itrig)) then
                        call mvbits (tinfo(idx),7,1,it1,0)
                        if (jtetra .ne. 0) then
                           call mvbits (tinfo(jtetra),7,1,it2,0)
                        else
                           it2 = 0
                        end if
                        ival = 2 - it1 - it2
                        if (ival .eq. 0)  goto 40
                        coefval = 0.5d0 * dble(ival)
                        ntrig = ntrig + 1
                        surfa = 0.0d0
                        surfb = 0.0d0
                        surfc = 0.0d0
                        surfd = 0.0d0
                        vola = 0.0d0
                        volb = 0.0d0
                        volc = 0.0d0
                        vold = 0.0d0
                        if (itrig .eq. 1) then
                           call triangle_vol (b,c,d,rbc,rbd,rcd,rbc2,
     &                                        rbd2,rcd2,rb,rc,rd,rb2,
     &                                        rc2,rd2,surfb,surfc,
     &                                        surfd,volb,volc,vold)
                        else if (itrig .eq. 2) then
                           call triangle_vol (a,c,d,rac,rad,rcd,rac2,
     &                                        rad2,rcd2,ra,rc,rd,ra2,
     &                                        rc2,rd2,surfa,surfc,
     &                                        surfd,vola,volc,vold)
                        else if (itrig .eq. 3) then
                           call triangle_vol (a,b,d,rab,rad,rbd,rab2,
     &                                        rad2,rbd2,ra,rb,rd,ra2,
     &                                        rb2,rd2,surfa,surfb,
     &                                        surfd,vola,volb,vold)
                        else if (itrig .eq. 4) then
                           call triangle_vol (a,b,c,rab,rac,rbc,rab2,
     &                                        rac2,rbc2,ra,rb,rc,ra2,
     &                                        rb2,rc2,surfa,surfb,
     &                                        surfc,vola,volb,volc)
                        end if
                        ballwsurf(ia) = ballwsurf(ia) + coefval*surfa
                        ballwsurf(ib) = ballwsurf(ib) + coefval*surfb
                        ballwsurf(ic) = ballwsurf(ic) + coefval*surfc
                        ballwsurf(id) = ballwsurf(id) + coefval*surfd
                        ballwvol(ia) = ballwvol(ia) + coefval*vola
                        ballwvol(ib) = ballwvol(ib) + coefval*volb
                        ballwvol(ic) = ballwvol(ic) + coefval*volc
                        ballwvol(id) = ballwvol(id) + coefval*vold
                     end if
                  end if
   40             continue
               end do
            end if
         end if
      end do
c
c     now add contribution of two sphere
c
      do iedge = 1, nedge
         if (coef_edge(iedge) .ne. 0.0d0) then
            ia = edges(1,iedge)
            ib = edges(2,iedge)
            do i = 1, 3
               a(i) = crdball(3*(ia-1)+i)
               b(i) = crdball(3*(ib-1)+i)
            end do
            ra = radball(ia)
            rb = radball(ib)
            ra2 = ra * ra
            rb2 = rb * rb
            call distance2 (crdball,ia,ib,rab2)
            rab = sqrt(rab2)
            call twosphere_vol (ra,ra2,rb,rb2,rab,rab2,
     &                          surfa,surfb,vola,volb)
            ballwsurf(ia) = ballwsurf(ia) - coef_edge(iedge)*surfa
            ballwsurf(ib) = ballwsurf(ib) - coef_edge(iedge)*surfb
            ballwvol(ia) = ballwvol(ia) - coef_edge(iedge)*vola
            ballwvol(ib) = ballwvol(ib) - coef_edge(iedge)*volb
         end if
      end do
c
c     next loop over all of the vertices
c
      nred = 0
      do i = 1, nvertex
         if (.not. btest(vinfo(i),0))  goto 50
c
c     if vertex is not in alpha complex, nothing to do
c
         if (.not. btest(vinfo(i),7))  goto 50
c
c     vertex is in alpha complex if its weight is 0 (buried)
c     in that case there is nothing to do
c
         if (coef_vertex(i) .eq. 0.0d0)  goto 50
         ra = radball(i)
         surfa = 4.0d0 * pi * ra * ra
         vola = ra * surfa / 3.0d0
         ballwsurf(i) = ballwsurf(i) + coef_vertex(i)*surfa
         ballwvol(i) = ballwvol(i) + coef_vertex(i)*vola
   50    continue
      end do
c
c     compute total surface, both weighted and unweighted
c
      do i = 1, nvertex
         if (btest(vinfo(i),0)) then
            surf = surf + ballwsurf(i)
            ballwsurf(i-4) = coef(i-4) * ballwsurf(i)
            wsurf = wsurf + ballwsurf(i-4)
            vol = vol + ballwvol(i)
            ballwvol(i-4) = coef(i-4) * ballwvol(i)
            wvol = wvol + ballwvol(i-4)
         end if
      end do
c
c     perform deallocation of some local arrays
c
      deallocate (sparse_row)
      deallocate (edges)
      deallocate (coef_edge)
      deallocate (coef_vertex)
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine ball_dsurf  --  find area & derivs of spheres  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "ball_dsurf" computes the weighted surface area of a union
c     of spheres as well as its derivatives with respect to the
c     coordinates of the spheres
c
c     variables and parameters:
c
c     coef          weight of each sphere for weighted surface
c     option        flag to compute or not compute derivatives
c     wsurf         weighted surface area
c     surf          unweighted surface area
c     ballwsurf     weighted contribution of each ball
c     dsurf_dist    derivatives of surface area over distances
c     dsurf_coord   derivatives of surface area over coordinates
c
c
      subroutine ball_dsurf (coef,wsurf,surf,ballwsurf,dsurf_coord)
      use math
      use shapes
      implicit none
      integer i,j,i1
      integer ia,ib,ic,id
      integer nedge
      integer idx,ilast
      integer itrig,iedge
      integer ival,it1,it2
      integer jtetra,option
      integer pair(2,6)
      integer edge_list(6)
      integer, allocatable :: sparse_row(:)
      integer, allocatable :: edges(:,:)
      real*8 ra,rb,rc,rd
      real*8 ra2,rb2,rc2,rd2
      real*8 rab,rac,rad
      real*8 rbc,rbd,rcd
      real*8 rab2,rac2,rad2
      real*8 rbc2,rbd2,rcd2
      real*8 val,val1,val2,val3
      real*8 val4,vala,valb
      real*8 r1,r2,r1_2,r2_2,r12
      real*8 coefval
      real*8 surfa,surfb
      real*8 surfc,surfd
      real*8 u(3),dist(6)
      real*8 deriv(6,6)
      real*8 dsurfa3(3),dsurfb3(3)
      real*8 dsurfc3(3),dsurfd3(3)
      real*8 dsurfa2,dsurfb2
      real*8 angle(6),cosine(6),sine(6)
      real*8 wsurf,surf
      real*8 coef(*),ballwsurf(*)
      real*8 dsurf_coord(3,*)
      real*8, allocatable :: coef_edge(:)
      real*8, allocatable :: edge_dist(:)
      real*8, allocatable :: coef_vertex(:)
      real*8, allocatable :: dsurf_dist(:)
      data pair  / 3, 4, 2, 4, 2, 3, 1, 4, 1, 3, 1, 2 /
      save
c
c
c     perform dynamic allocation of some local arrays
c
      allocate (sparse_row(10*maxedge))
      allocate (edges(2,maxedge))
      allocate (coef_edge(maxedge))
      allocate (coef_vertex(nvertex))
      allocate (edge_dist(maxedge))
      allocate (dsurf_dist(10*maxedge))
c
c     initialize some input and result values
c
      option = 1
      wsurf = 0.0d0
      surf = 0.0d0
      do i = 1, nvertex
         ballwsurf(i) = 0.0d0
      end do
c
c     find list of all edges in the alpha complex
c
      nedge = 0
      call find_all_edges (nedge,edges)
c
c     define sparse structure for edges
c
      ilast = 0
      do i = 1, nedge
         ia = edges(1,i)
         ib = edges(2,i)
         if (ia .ne. ilast) then
            do j = ilast+1, ia
               sparse_row(j) = i
            end do
            ilast = ia
         end if
         coef_edge(i) = 1
         ra = radball(ia)
         ra2 = ra * ra
         rb = radball(ib)
         rb2 = rb * rb
         call distance2 (crdball,ia,ib,rab2)
         rab = sqrt(rab2)
         edge_dist(i) = rab
         dsurf_dist(i) = 0.0d0
      end do
      do i = ia+1, nvertex
         sparse_row(i) = nedge + 1
      end do
c
c     build list of fully buried vertices; these vertices are part
c     of the alpha complex, and all edges that start or end at these
c     vertices are buried
c
      do i = 1, nvertex
         coef_vertex(i) = 1.0d0
      end do
c
c     contribution of four spheres; use weighted inclusion-exclusion
c     formula; each tetrahedron in the Alpha Complex only contributes
c     to the weight of each its edges and each of its vertices
c
      do idx = 1, ntetra
         if (btest(tinfo(idx),7)) then
            ia = tetra(1,idx)
            ib = tetra(2,idx)
            ic = tetra(3,idx)
            id = tetra(4,idx)
            ra = radball(ia)
            rb = radball(ib)
            rc = radball(ic)
            rd = radball(id)
            ra2 = ra * ra
            rb2 = rb * rb
            rc2 = rc * rc
            rd2 = rd * rd
c
c     weights on each edge; fraction of dihedral angle
c
c     iedge is the edge number in the tetrahedron idx with:
c     iedge = 1 (c,d), iedge = 2 (b,d), iedge = 3 (b,c),
c     iedge = 4 (a,d), iedge = 5 (a,c), iedge = 6 (a,b)
c               
c     define indices of the edge
c
            do iedge = 1, 6
               i = tetra(pair(1,iedge),idx)
               j = tetra(pair(2,iedge),idx)
c
c     find which edge this corresponds to
c
               do i1 = sparse_row(i), sparse_row(i+1)-1
                  if (edges(2,i1) .eq. j)  goto 10
               end do
               goto 20
   10          continue
               edge_list(7-iedge) = i1
   20          continue
            end do
            rab = edge_dist(edge_list(1))
            rac = edge_dist(edge_list(2))
            rad = edge_dist(edge_list(3))
            rbc = edge_dist(edge_list(4))
            rbd = edge_dist(edge_list(5))
            rcd = edge_dist(edge_list(6))
            rab2 = rab * rab
            rac2 = rac * rac
            rad2 = rad * rad
            rbc2 = rbc * rbc
            rbd2 = rbd * rbd
            rcd2 = rcd * rcd
            dist(1) = rab
            dist(2) = rac
            dist(3) = rad
            dist(4) = rbc
            dist(5) = rbd
            dist(6) = rcd
c
c     weights on each vertex, fraction of solid angle
c
            if (option .eq. 0) then
               call tetra_dihed (rab2,rac2,rad2,rbc2,rbd2,
     &                           rcd2,angle,cosine,sine)
            else
               call tetra_dihed_der (rab2,rac2,rad2,rbc2,rbd2,
     &                               rcd2,angle,cosine,sine,deriv)
            end if
c
c     weights on each vertex, fraction of solid angle
c
            coef_vertex(ia) = coef_vertex(ia) + 0.25d0
     &                           - (angle(1)+angle(2)+angle(3))/2.0d0
            coef_vertex(ib) = coef_vertex(ib) + 0.25d0
     &                           - (angle(1)+angle(4)+angle(5))/2.0d0
            coef_vertex(ic) = coef_vertex(ic) + 0.25d0
     &                           - (angle(2)+angle(4)+angle(6))/2.0d0
            coef_vertex(id) = coef_vertex(id) + 0.25d0
     &                           - (angle(3)+angle(5)+angle(6))/2.0d0
c
c     weights on each edge, fraction of dihedral angle
c
            do iedge = 1, 6
               i1 = edge_list(iedge)
               if (coef_edge(i1) .ne. 0.0d0) then
                  coef_edge(i1) = coef_edge(i1) - angle(iedge)
               end if
            end do
c
c     take into account the der ivatives of the edge weight
c     in weighted inclusion-exclusion formula
c
            if (option .eq. 1) then
               do iedge = 1, 6
                  i1 = edge_list(iedge)
                  ia = edges(1,i1)
                  ib = edges(2,i1)
                  r1 = radball(ia)
                  r1_2 = r1 * r1
                  r2 = radball(ib)
                  r2_2 = r2 * r2
                  r12 = edge_dist(i1)
                  val1 = (r1_2-r2_2) / r12
                  vala = r1 * (2.0d0*r1-r12-val1)
                  valb = r2 * (2.0d0*r2-r12+val1)
                  val = coef(ia-4)*vala + coef(ib-4)*valb
                  do i = 1, 6
                     j = edge_list(i)
                     dsurf_dist(j) = dsurf_dist(j)
     &                                  + dist(i)*deriv(iedge,i)*val
                  end do
               end do
c
c     take into account the derivatives of the vertex weight 
c     in weightedinclusion-exclusion formula
c
               val1 = ra2 * coef(ia-4)
               val2 = rb2 * coef(ib-4)
               val3 = rc2 * coef(ic-4)
               val4 = rd2 * coef(id-4)
               do i = 1, 6
                  j = edge_list(i)
                  val = val1*(deriv(1,i)+deriv(2,i)+deriv(3,i))
     &                     + val2*(deriv(1,i)+deriv(4,i)+deriv(5,i))
     &                     + val3*(deriv(2,i)+deriv(4,i)+deriv(6,i))
     &                     + val4*(deriv(3,i)+deriv(5,i)+deriv(6,i))
                  dsurf_dist(j) = dsurf_dist(j) - 2.0d0*dist(i)*val
               end do
            end if
         end if
      end do
c
c     contribution of three balls (triangles of the alpha complex)
c
c     we loop over all tetrahedra, and check its four faces;
c     any face that is exposed (on the convex hull, or facing
c     a tetrahedron from the Delaunay that is not part of the
c     alpha complex), contributes
c
      do idx = 1, ntetra
         if (btest(tinfo(idx),1)) then
            ia = tetra(1,idx)
            ib = tetra(2,idx)
            ic = tetra(3,idx)
            id = tetra(4,idx)
            ra = radball(ia)
            rb = radball(ib)
            rc = radball(ic)
            rd = radball(id)
            ra2 = ra * ra
            rb2 = rb * rb
            rc2 = rc * rc
            rd2 = rd * rd
c
c     define indices of the edge
c
            do iedge = 1, 6
               i = tetra(pair(1,iedge),idx)
               j = tetra(pair(2,iedge),idx)
c
c     find which edge this corresponds to
c
               do i1 = sparse_row(i), sparse_row(i+1)-1
                  if (edges(2,i1) .eq. j)  goto 30
               end do
               goto 40
   30          continue
               edge_list(7-iedge) = i1
   40          continue
            end do
c
c     check triangles
c
            do itrig = 1, 4
               jtetra = tneighbor(itrig,idx)
               if (jtetra.eq.0 .or. jtetra.gt.idx) then
                  if (btest(tinfo(idx),2+itrig)) then
                     call mvbits (tinfo(idx),7,1,it1,0)
                     if (jtetra .ne. 0) then
                        call mvbits (tinfo(jtetra),7,1,it2,0)
                     else
                        it2 = 0
                     end if
                     ival = 2 - it1 - it2
                     if (ival .eq. 0)  goto 50
                     coefval = 0.5d0 * dble(ival)
                     surfa = 0.0d0
                     surfb = 0.0d0
                     surfc = 0.0d0
                     surfd = 0.0d0
                     if (itrig .eq. 1) then
                        rbc = edge_dist(edge_list(4))
                        rbd = edge_dist(edge_list(5))
                        rcd = edge_dist(edge_list(6))
                        rbc2 = rbc * rbc
                        rbd2 = rbd * rbd
                        rcd2 = rcd * rcd
                        call threesphere_dsurf (rb,rc,rd,rb2,rc2,rd2,
     &                                          rbc,rbd,rcd,rbc2,rbd2,
     &                                          rcd2,surfb,surfc,surfd,
     &                                          dsurfb3,dsurfc3,
     &                                          dsurfd3,option)
                        if (option .eq. 1) then
                           call update_deriv (dsurf_dist,dsurfb3,
     &                                        dsurfc3,dsurfd3,
     &                                        coef(ib-4),coef(ic-4),
     &                                        coef(id-4),coefval,
     &                                        edge_list(4),
     &                                        edge_list(5),
     &                                        edge_list(6))
                        end if
                     else if (itrig .eq. 2) then
                        rac = edge_dist(edge_list(2))
                        rad = edge_dist(edge_list(3))
                        rcd = edge_dist(edge_list(6))
                        rac2 = rac * rac
                        rad2 = rad * rad
                        rcd2 = rcd * rcd
                        call threesphere_dsurf (ra,rc,rd,ra2,rc2,rd2,
     &                                          rac,rad,rcd,rac2,rad2,
     &                                          rcd2,surfa,surfc,surfd,
     &                                          dsurfa3,dsurfc3,
     &                                          dsurfd3,option)
                        if (option .eq. 1) then
                           call update_deriv (dsurf_dist,dsurfa3,
     &                                        dsurfc3,dsurfd3,
     &                                        coef(ia-4),coef(ic-4),
     &                                        coef(id-4),coefval,
     &                                        edge_list(2),
     &                                        edge_list(3),
     &                                        edge_list(6))
                        end if
                     else if (itrig .eq. 3) then
                        rab = edge_dist(edge_list(1))
                        rad = edge_dist(edge_list(3))
                        rbd = edge_dist(edge_list(5))
                        rab2 = rab * rab
                        rad2 = rad * rad
                        rbd2 = rbd * rbd
                        call threesphere_dsurf (ra,rb,rd,ra2,rb2,rd2,
     &                                          rab,rad,rbd,rab2,rad2,
     &                                          rbd2,surfa,surfb,surfd,
     &                                          dsurfa3,dsurfb3,
     &                                          dsurfd3,option)
                        if (option .eq. 1) then
                           call update_deriv (dsurf_dist,dsurfa3,
     &                                        dsurfb3,dsurfd3,
     &                                        coef(ia-4),coef(ib-4),
     &                                        coef(id-4),coefval,
     &                                        edge_list(1),
     &                                        edge_list(3),
     &                                        edge_list(5))
                        end if
                     else if (itrig .eq. 4) then
                        rab = edge_dist(edge_list(1))
                        rac = edge_dist(edge_list(2))
                        rbc = edge_dist(edge_list(4))
                        rab2 = rab * rab
                        rac2 = rac * rac
                        rbc2 = rbc * rbc
                        call threesphere_dsurf (ra,rb,rc,ra2,rb2,rc2,
     &                                          rab,rac,rbc,rab2,rac2,
     &                                          rbc2,surfa,surfb,surfc,
     &                                          dsurfa3,dsurfb3,
     &                                          dsurfc3,option)
                        if (option .eq. 1) then
                           call update_deriv (dsurf_dist,dsurfa3,
     &                                        dsurfb3,dsurfc3,
     &                                        coef(ia-4),coef(ib-4),
     &                                        coef(ic-4),coefval,
     &                                        edge_list(1),
     &                                        edge_list(2),
     &                                        edge_list(4))
                        end if
                     end if
                     ballwsurf(ia) = ballwsurf(ia) + coefval*surfa
                     ballwsurf(ib) = ballwsurf(ib) + coefval*surfb
                     ballwsurf(ic) = ballwsurf(ic) + coefval*surfc
                     ballwsurf(id) = ballwsurf(id) + coefval*surfd
                  end if
               end if
   50          continue
            end do
         end if
      end do
c
c     now add contribution of two sphere
c
      do iedge = 1, nedge
         if (coef_edge(iedge) .ne. 0.0d0) then
            ia = edges(1,iedge)
            ib = edges(2,iedge)
            ra = radball(ia)
            rb = radball(ib)
            ra2 = ra * ra
            rb2 = rb * rb
            rab = edge_dist(iedge)
            rab2 = rab * rab
            call twosphere_dsurf (ra,ra2,rb,rb2,rab,rab2,surfa,
     &                            surfb,dsurfa2,dsurfb2,option)
            ballwsurf(ia) = ballwsurf(ia) - coef_edge(iedge)*surfa
            ballwsurf(ib) = ballwsurf(ib) - coef_edge(iedge)*surfb
            if (option .eq. 1) then
               dsurf_dist(iedge) = dsurf_dist(iedge)
     &                                - coef_edge(iedge)
     &                      *(coef(ia-4)*dsurfa2+coef(ib-4)*dsurfb2)
            end if
         end if
      end do
c
c     now loop over vertices
c
      do i = 1, nvertex
         if (.not. btest(vinfo(i),0))  goto 60
c
c     if vertex is not in alpha complex, then nothing to do
c
         if (.not. btest(vinfo(i),7))  goto 60
c
c     vertex is in alpha complex; if its weight is 0 (i.e., buried)
c     nothing to do
c
         if (coef_vertex(i) .eq. 0)  goto 60
         ra = radball(i)
         ballwsurf(i) = ballwsurf(i) + 4.0d0*pi*ra*ra*coef_vertex(i)
   60    continue
      end do
c
c     compute total surface area, weighted and unweighted
c
      do i = 1, nvertex
         if (btest(vinfo(i),0)) then
            surf = surf + ballwsurf(i)
            ballwsurf(i-4) = ballwsurf(i) * coef(i-4)
            wsurf = wsurf + ballwsurf(i-4)
         end if
      end do
      if (option .ne. 1)  return
c
c     convert distance derivatives to coordinate derivatives
c
      do i = 1, nvertex
         do j = 1, 3
            dsurf_coord(j,i) = 0.0d0
         end do
      end do
      do iedge = 1, nedge
         if (dsurf_dist(iedge) .ne. 0.0d0) then
            ia = edges(1,iedge)
            ib = edges(2,iedge)
            do i = 1, 3
               u(i) = crdball(3*(ia-1)+i) - crdball(3*(ib-1)+i)
            end do
            rab = edge_dist(iedge)
            val = dsurf_dist(iedge) / rab
            do j = 1, 3
               dsurf_coord(j,ia-4) = dsurf_coord(j,ia-4) + u(j)*val
               dsurf_coord(j,ib-4) = dsurf_coord(j,ib-4) - u(j)*val
            end do
         end if
      end do
c
c     perform deallocation of some local arrays
c
      deallocate (sparse_row)
      deallocate (edges)
      deallocate (coef_edge)
      deallocate (coef_vertex)
      deallocate (edge_dist)
      deallocate (dsurf_dist)
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine ball_dvol  --  find volume & derivs of spheres  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "ball_dvol" computes the weighted surface area of a union of
c     spheres as well as the corresponding weighted excluded volume,
c     also finds their derivatives with respect sphere coordinates
c
c     variables and parameters:
c
c     coef          weight of each sphere for the weighted surface
c     option        computes derivatives or not
c     wsurf         weighted accessible surface area
c     wvol          weighted excluded volume
c     surf          unweighted accessible surface area
c     vol           unweighted excluded volume 
c     ballwsurf     weighted contribution of each sphere to the area
c     ballwvol      weighted contribution of each ball to the volume
c     dsurf_dist    derivatives of surface area over distances
c     dsurf_coord   derivatives of surface area over coordinates
c     dvol_dist     derivatives of volume over distances
c     dvol_coord    derivatives of volume over coordinates
c
c
      subroutine ball_dvol (coef,wsurf,wvol,surf,vol,ballwsurf,
     &                      ballwvol,dsurf_coord,dvol_coord)
      use math
      use shapes
      implicit none
      integer i,j,i1
      integer ia,ib,ic,id
      integer nedge
      integer idx,ilast
      integer itrig,iedge
      integer ival,it1,it2
      integer jtetra,option
      integer pair(2,6)
      integer edge_list(6)
      integer, allocatable :: sparse_row(:)
      integer, allocatable :: edges(:,:)
      real*8 ra,rb,rc,rd
      real*8 ra2,rb2,rc2,rd2
      real*8 rab,rac,rad
      real*8 rbc,rbd,rcd
      real*8 rab2,rac2,rad2
      real*8 rbc2,rbd2,rcd2
      real*8 val,val1,val2,val3,val4
      real*8 vala,valb,valc,vald
      real*8 coefval
      real*8 surfa,surfb,surfc,surfd
      real*8 dsurfa2,dsurfb2
      real*8 dvola2,dvolb2
      real*8 vola,volb,volc,vold
      real*8 wsurf,surf,wvol,vol
      real*8 u(3),dist(6)
      real*8 dsurfa3(3),dsurfb3(3)
      real*8 dsurfc3(3),dsurfd3(3)
      real*8 dvola3(3),dvolb3(3)
      real*8 dvolc3(3),dvold3(3)
      real*8 dvola(6),dvolb(6)
      real*8 dvolc(6),dvold(6)
      real*8 angle(6),cosine(6),sine(6)
      real*8 deriv(6,6)
      real*8 coef(*)
      real*8 ballwsurf(*),ballwvol(*)
      real*8 dsurf_coord(3,*)
      real*8 dvol_coord(3,*)
      real*8, allocatable :: coef_edge(:)
      real*8, allocatable :: coef_vertex(:)
      real*8, allocatable :: edge_dist(:)
      real*8, allocatable :: edge_surf(:)
      real*8, allocatable :: edge_vol(:)
      real*8, allocatable :: dsurf_dist(:)
      real*8, allocatable :: dvol_dist(:)
      data pair  / 3, 4, 2, 4, 2, 3, 1, 4, 1, 3, 1, 2 /
      save
c
c
c     perform dynamic allocation of some local arrays
c
      allocate (sparse_row(10*maxedge))
      allocate (edges(2,maxedge))
      allocate (coef_edge(maxedge))
      allocate (coef_vertex(nvertex))
      allocate (edge_surf(maxedge))
      allocate (edge_vol(maxedge))
      allocate (edge_dist(maxedge))
      allocate (dsurf_dist(10*maxedge))
      allocate (dvol_dist(10*maxedge))
c
c     initialize some input and result values
c
      option = 1
      wsurf = 0.0d0
      surf = 0.0d0
      wvol = 0.0d0
      vol = 0.0d0
      do i = 1, nvertex
         ballwsurf(i) = 0.0d0
         ballwvol(i) = 0.0d0
      end do
c
c     find list of all edges in the alpha complex
c
      nedge = 0
      call find_all_edges (nedge,edges)
c
c     define sparse structure for edges
c
      ilast = 0
      do i = 1, nedge
         ia = edges(1,i)
         ib = edges(2,i)
         if (ia .ne. ilast) then
            do j = ilast+1, ia
               sparse_row(j) = i
            end do
            ilast = ia
         end if
         coef_edge(i) = 1
         ra = radball(ia)
         ra2 = ra * ra
         rb = radball(ib)
         rb2 = rb * rb
         call distance2 (crdball,ia,ib,rab2)
         rab = sqrt(rab2)
         call twosphere_vol (ra,ra2,rb,rb2,rab,rab2,
     &                       surfa,surfb,vola,volb)
         edge_dist(i) = rab
         edge_surf(i) = (coef(ia-4)*surfa+coef(ib-4)*surfb) / twopi
         edge_vol(i) = (coef(ia-4)*vola+coef(ib-4)*volb) / twopi
         dsurf_dist(i) = 0.0d0
         dvol_dist(i) = 0.0d0
      end do
      do i = ia+1, nvertex
         sparse_row(i) = nedge + 1
      end do
c
c     build list of fully buried vertices; these vertices are part
c     of the alpha complex, and all edges that start or end at these
c     vertices are buried
c
      do i = 1, nvertex
         coef_vertex(i) = 1.0d0
      end do
c
c     contribution of four spheres; use the weighted inclusion-exclusion
c     formula; each tetrahedron in the Alpha Complex only contributes
c     to the weight of each its edges and each of its vertices
c
      do idx = 1, ntetra
         if (btest(tinfo(idx),7)) then
            ia = tetra(1,idx)
            ib = tetra(2,idx)
            ic = tetra(3,idx)
            id = tetra(4,idx)
            ra = radball(ia)
            rb = radball(ib)
            rc = radball(ic)
            rd = radball(id)
            ra2 = ra * ra
            rb2 = rb * rb
            rc2 = rc * rc
            rd2 = rd * rd
c
c     weights on each edge; fraction of dihedral angle
c
c     iedge is the edge number in the tetrahedron idx with:
c     iedge = 1 (c,d), iedge = 2 (b,d), iedge = 3 (b,c),
c     iedge = 4 (a,d), iedge = 5 (a,c), iedge = 6 (a,b)
c               
c     define indices of the edge
c
            do iedge = 1, 6
               i = tetra(pair(1,iedge),idx)
               j = tetra(pair(2,iedge),idx)
c
c     find which edge this corresponds to
c
               do i1 = sparse_row(i), sparse_row(i+1)-1
                  if (edges(2,i1) .eq. j)  goto 10
               end do
               goto 20
   10          continue
               edge_list(7-iedge) = i1
   20          continue
            end do
            rab = edge_dist(edge_list(1))
            rac = edge_dist(edge_list(2))
            rad = edge_dist(edge_list(3))
            rbc = edge_dist(edge_list(4))
            rbd = edge_dist(edge_list(5))
            rcd = edge_dist(edge_list(6))
            rab2 = rab * rab
            rac2 = rac * rac
            rad2 = rad * rad
            rbc2 = rbc * rbc
            rbd2 = rbd * rbd
            rcd2 = rcd * rcd
            dist(1) = rab
            dist(2) = rac
            dist(3) = rad
            dist(4) = rbc
            dist(5) = rbd
            dist(6) = rcd
c
c     characterize the tetrahedron based on A, B, C and D
c
            if (option .eq. 0) then
               call tetra_dihed (rab2,rac2,rad2,rbc2,rbd2,
     &                           rcd2,angle,cosine,sine)
            else
               call tetra_dihed_der (rab2,rac2,rad2,rbc2,rbd2,
     &                               rcd2,angle,cosine,sine,deriv)
            end if
c
c     add fraction of tetrahedron that belongs to each ball
c
            call tetra_voronoi_der (ra2,rb2,rc2,rd2,rab,rac,rad,rbc,
     &                              rbd,rcd,rab2,rac2,rad2,rbc2,rbd2,
     &                              rcd2,cosine,sine,deriv,vola,volb,
     &                              volc,vold,dvola,dvolb,dvolc,
     &                              dvold,option)
            ballwvol(ia) = ballwvol(ia) + vola
            ballwvol(ib) = ballwvol(ib) + volb
            ballwvol(ic) = ballwvol(ic) + volc
            ballwvol(id) = ballwvol(id) + vold
            if (option .eq. 1) then
               do iedge = 1, 6
                  i1 = edge_list(iedge)
                  dvol_dist(i1) = dvol_dist(i1)
     &                               + coef(ia-4)*dvola(iedge)
     &                               + coef(ib-4)*dvolb(iedge)
     &                               + coef(ic-4)*dvolc(iedge)
     &                               + coef(id-4)*dvold(iedge)
               end do
            end if
c       
c     weights on each vertex, fraction of solid angle
c
            coef_vertex(ia) = coef_vertex(ia) + 0.25d0
     &                           - (angle(1)+angle(2)+angle(3))/2.0d0
            coef_vertex(ib) = coef_vertex(ib) + 0.25d0
     &                           - (angle(1)+angle(4)+angle(5))/2.0d0
            coef_vertex(ic) = coef_vertex(ic) + 0.25d0
     &                           - (angle(2)+angle(4)+angle(6))/2.0d0
            coef_vertex(id) = coef_vertex(id) + 0.25d0
     &                           - (angle(3)+angle(5)+angle(6))/2.0d0
c
c     weights on each edge, fraction of dihedral angle
c
            do iedge = 1, 6
               i1 = edge_list(iedge)
               if (coef_edge(i1) .ne. 0.0d0) then
                  coef_edge(i1) = coef_edge(i1) - angle(iedge)
               end if
            end do
c
c     take into account the derivatives of the edge weight
c     in weighted inclusion-exclusion formula
c
            if (option .eq. 1) then
               do iedge = 1, 6
                  i1 = edge_list(iedge)
                  val1 = 2.0d0 * edge_surf(i1)
                  val2 = 2.0d0 * edge_vol(i1)
                  do i = 1, 6
                     j = edge_list(i)
                     dsurf_dist(j) = dsurf_dist(j)
     &                                  + dist(i)*deriv(iedge,i)*val1
                     dvol_dist(j) = dvol_dist(j)
     &                                 + dist(i)*deriv(iedge,i)*val2
                  end do
               end do
c
c     take into account the derivatives of the vertex weight
c     in weighted inclusion-exclusion formula
c
               val1 = ra2 * coef(ia-4)
               val2 = rb2 * coef(ib-4)
               val3 = rc2 * coef(ic-4)
               val4 = rd2 * coef(id-4)
               vala = val1 * ra/3.0d0
               valb = val2 * rb/3.0d0
               valc = val3 * rc/3.0d0
               vald = val4 * rd/3.0d0
               do i = 1, 6
                  j = edge_list(i)
                  val = val1*(deriv(1,i)+deriv(2,i)+deriv(3,i))
     &                     + val2*(deriv(1,i)+deriv(4,i)+deriv(5,i))
     &                     + val3*(deriv(2,i)+deriv(4,i)+deriv(6,i))
     &                     + val4*(deriv(3,i)+deriv(5,i)+deriv(6,i))
                  dsurf_dist(j) = dsurf_dist(j) - 2.0d0*dist(i)*val
                  val = vala*(deriv(1,i)+deriv(2,i)+deriv(3,i))
     &                     + valb*(deriv(1,i)+deriv(4,i)+deriv(5,i))
     &                     + valc*(deriv(2,i)+deriv(4,i)+deriv(6,i))
     &                     + vald*(deriv(3,i)+deriv(5,i)+deriv(6,i))
                  dvol_dist(j) = dvol_dist(j) - 2.0d0*dist(i)*val
               end do
            end if
         end if
      end do
c
c     contribution of three balls (triangles of the alpha complex)
c
c     we loop over all tetrahedra, and check its four faces;
c     any face that is exposed (on the convex hull, or facing
c     a tetrahedron from the Delaunay that is not part of the
c     alpha complex), contributes
c
      do idx = 1, ntetra
         if (btest(tinfo(idx),1)) then
            ia = tetra(1,idx)
            ib = tetra(2,idx)
            ic = tetra(3,idx)
            id = tetra(4,idx)
            ra = radball(ia)
            rb = radball(ib)
            rc = radball(ic)
            rd = radball(id)
            ra2 = ra * ra
            rb2 = rb * rb
            rc2 = rc * rc
            rd2 = rd * rd
            do iedge = 1, 6
c
c     define indices of the edge
c
               i = tetra(pair(1,iedge),idx)
               j = tetra(pair(2,iedge),idx)
c
c     find which edge this corresponds to:
c
               do i1 = sparse_row(i), sparse_row(i+1)-1
                  if (edges(2,i1) .eq. j)  goto 30
               end do
               goto 40
   30          continue
               edge_list(7-iedge) = i1
   40          continue
            end do
c
c     check triangles
c
            do itrig = 1, 4
               jtetra = tneighbor(itrig,idx)
               if (jtetra.eq.0 .or. jtetra.gt.idx) then
                  if (btest(tinfo(idx),2+itrig)) then
                     call mvbits (tinfo(idx),7,1,it1,0)
                     if (jtetra .ne. 0) then
                        call mvbits (tinfo(jtetra),7,1,it2,0)
                     else
                        it2 = 0
                     end if
                     ival = 2 - it1 - it2
                     if (ival .eq. 0)  goto 50
                     coefval = 0.5d0 * dble(ival)
                     surfa = 0.0d0
                     surfb = 0.0d0
                     surfc = 0.0d0
                     surfd = 0.0d0
                     vola = 0.0d0
                     volb = 0.0d0
                     volc = 0.0d0
                     vold = 0.0d0
                     if (itrig .eq. 1) then
                        rbc = edge_dist(edge_list(4))
                        rbd = edge_dist(edge_list(5))
                        rcd = edge_dist(edge_list(6))
                        rbc2 = rbc * rbc
                        rbd2 = rbd * rbd
                        rcd2 = rcd * rcd
                        call threesphere_dvol (rb,rc,rd,rb2,rc2,rd2,
     &                                         rbc,rbd,rcd,rbc2,rbd2,
     &                                         rcd2,surfb,surfc,surfd,
     &                                         volb,volc,vold,dsurfb3,
     &                                         dsurfc3,dsurfd3,dvolb3,
     &                                         dvolc3,dvold3,option)
                        if (option .eq. 1) then
                           call update_deriv (dsurf_dist,dsurfb3,
     &                                        dsurfc3,dsurfd3,
     &                                        coef(ib-4),coef(ic-4),
     &                                        coef(id-4),coefval,
     &                                        edge_list(4),
     &                                        edge_list(5),
     &                                        edge_list(6))
                           call update_deriv (dvol_dist,dvolb3,
     &                                        dvolc3,dvold3,
     &                                        coef(ib-4),coef(ic-4),
     &                                        coef(id-4),coefval,
     &                                        edge_list(4),
     &                                        edge_list(5),
     &                                        edge_list(6))
                        end if
                     else if (itrig .eq. 2) then
                        rac = edge_dist(edge_list(2))
                        rad = edge_dist(edge_list(3))
                        rcd = edge_dist(edge_list(6))
                        rac2 = rac * rac
                        rad2 = rad * rad
                        rcd2 = rcd * rcd
                        call threesphere_dvol (ra,rc,rd,ra2,rc2,rd2,
     &                                         rac,rad,rcd,rac2,rad2,
     &                                         rcd2,surfa,surfc,surfd,
     &                                         vola,volc,vold,dsurfa3,
     &                                         dsurfc3,dsurfd3,dvola3,
     &                                         dvolc3,dvold3,option)
                        if (option .eq. 1) then
                           call update_deriv (dsurf_dist,dsurfa3,
     &                                        dsurfc3,dsurfd3,
     &                                        coef(ia-4),coef(ic-4),
     &                                        coef(id-4),coefval,
     &                                        edge_list(2),
     &                                        edge_list(3),
     &                                        edge_list(6))
                           call update_deriv (dvol_dist,dvola3,
     &                                        dvolc3,dvold3,
     &                                        coef(ia-4),coef(ic-4),
     &                                        coef(id-4),coefval,
     &                                        edge_list(2),
     &                                        edge_list(3),
     &                                        edge_list(6))
                        end if
                     else if (itrig .eq. 3) then
                        rab = edge_dist(edge_list(1))
                        rad = edge_dist(edge_list(3))
                        rbd = edge_dist(edge_list(5))
                        rab2 = rab * rab
                        rad2 = rad * rad
                        rbd2 = rbd * rbd
                        call threesphere_dvol (ra,rb,rd,ra2,rb2,rd2,
     &                                         rab,rad,rbd,rab2,rad2,
     &                                         rbd2,surfa,surfb,surfd,
     &                                         vola,volb,vold,dsurfa3,
     &                                         dsurfb3,dsurfd3,dvola3,
     &                                         dvolb3,dvold3,option)
                        if (option .eq. 1) then
                           call update_deriv (dsurf_dist,dsurfa3,
     &                                        dsurfb3,dsurfd3,
     &                                        coef(ia-4),coef(ib-4),
     &                                        coef(id-4),coefval,
     &                                        edge_list(1),
     &                                        edge_list(3),
     &                                        edge_list(5))
                           call update_deriv (dvol_dist,dvola3,
     &                                        dvolb3,dvold3,
     &                                        coef(ia-4),coef(ib-4),
     &                                        coef(id-4),coefval,
     &                                        edge_list(1),
     &                                        edge_list(3),
     &                                        edge_list(5))
                        end if
                     else if (itrig .eq. 4) then
                        rab = edge_dist(edge_list(1))
                        rac = edge_dist(edge_list(2))
                        rbc = edge_dist(edge_list(4))
                        rab2 = rab * rab
                        rac2 = rac * rac
                        rbc2 = rbc * rbc
                        call threesphere_dvol (ra,rb,rc,ra2,rb2,rc2,
     &                                         rab,rac,rbc,rab2,rac2,
     &                                         rbc2,surfa,surfb,surfc,
     &                                         vola,volb,volc,dsurfa3,
     &                                         dsurfb3,dsurfc3,dvola3,
     &                                         dvolb3,dvolc3,option)
                        if (option .eq. 1) then
                           call update_deriv (dsurf_dist,dsurfa3,
     &                                        dsurfb3,dsurfc3,
     &                                        coef(ia-4),coef(ib-4),
     &                                        coef(ic-4),coefval,
     &                                        edge_list(1),
     &                                        edge_list(2),
     &                                        edge_list(4))
                           call update_deriv (dvol_dist,dvola3,
     &                                        dvolb3,dvolc3,
     &                                        coef(ia-4),coef(ib-4),
     &                                        coef(ic-4),coefval,
     &                                        edge_list(1),
     &                                        edge_list(2),
     &                                        edge_list(4))
                         end if
                      end if
                      ballwsurf(ia) = ballwsurf(ia) + coefval*surfa
                      ballwsurf(ib) = ballwsurf(ib) + coefval*surfb
                      ballwsurf(ic) = ballwsurf(ic) + coefval*surfc
                      ballwsurf(id) = ballwsurf(id) + coefval*surfd
                      ballwvol(ia) = ballwvol(ia) + coefval*vola
                      ballwvol(ib) = ballwvol(ib) + coefval*volb
                      ballwvol(ic) = ballwvol(ic) + coefval*volc
                      ballwvol(id) = ballwvol(id) + coefval*vold
                   end if
                end if
   50           continue
            end do
         end if
      end do
c
c     now add contribution of two sphere
c
      do iedge = 1, nedge
         if (coef_edge(iedge) .ne. 0.0d0) then
            ia = edges(1,iedge)
            ib = edges(2,iedge)
            ra = radball(ia)
            rb = radball(ib)
            ra2 = ra * ra
            rb2 = rb * rb
            rab = edge_dist(iedge)
            rab2 = rab * rab
            call twosphere_dvol (ra,ra2,rb,rb2,rab,rab2,surfa,surfb,
     &                           vola,volb,dsurfa2,dsurfb2,dvola2,
     &                           dvolb2,option)
            ballwsurf(ia) = ballwsurf(ia) - coef_edge(iedge)*surfa
            ballwsurf(ib) = ballwsurf(ib) - coef_edge(iedge)*surfb
            ballwvol(ia) = ballwvol(ia) - coef_edge(iedge)*vola
            ballwvol(ib) = ballwvol(ib) - coef_edge(iedge)*volb
            if (option .eq. 1) then
               dsurf_dist(iedge) = dsurf_dist(iedge) - coef_edge(iedge)
     &            * (coef(ia-4)*dsurfa2+coef(ib-4)*dsurfb2)
               dvol_dist(iedge) = dvol_dist(iedge) - coef_edge(iedge)
     &            * (coef(ia-4)*dvola2 + coef(ib-4)*dvolb2)
            end if
         end if
      end do
c
c     now loop over vertices
c
      do i = 1, nvertex
         if (.not. btest(vinfo(i),0))  goto 60
c
c     if vertex is not in alpha complex, then nothing to do
c
         if (.not. btest(vinfo(i),7))  goto 60
c
c     vertex is in alpha complex if its weight is 0 (buried),
c     then nothing to do
c
         if (coef_vertex(i) .eq. 0.0d0)  goto 60
         ra = radball(i)
         surfa = 4.0d0 * pi * ra * ra
         vola = surfa * ra / 3.0d0
         ballwsurf(i) = ballwsurf(i) + coef_vertex(i)*surfa
         ballwvol(i) = ballwvol(i) + coef_vertex(i)*vola
   60    continue
      end do
c
c     compute total surface (weighted, and unweighted):
c
      do i = 1, nvertex
         if (btest(vinfo(i),0)) then
            surf = surf + ballwsurf(i)
            ballwsurf(i-4) = ballwsurf(i) * coef(i-4)
            wsurf = wsurf + ballwsurf(i-4)
            vol = vol + ballwvol(i)
            ballwvol(i-4) = ballwvol(i) * coef(i-4)
            wvol = wvol + ballwvol(i-4)
         end if
      end do
      if (option .ne. 1)  return
c
c     convert distance derivatives to coordinate derivatives
c
      do i = 1, nvertex
         do j = 1, 3
            dsurf_coord(j,i) = 0.0d0
            dvol_coord(j,i) = 0.0d0
         end do
      end do
      do iedge = 1,nedge
         ia = edges(1,iedge)
         ib = edges(2,iedge)
         do i = 1, 3
            u(i) = crdball(3*(ia-1)+i) - crdball(3*(ib-1)+i)
         end do
         rab = edge_dist(iedge)
         val = dsurf_dist(iedge) / rab
         val2 = dvol_dist(iedge) / rab
         do j = 1, 3
            dsurf_coord(j,ia-4) = dsurf_coord(j,ia-4) + u(j)*val
            dsurf_coord(j,ib-4) = dsurf_coord(j,ib-4) - u(j)*val
            dvol_coord(j,ia-4) = dvol_coord(j,ia-4) + u(j)*val2
            dvol_coord(j,ib-4) = dvol_coord(j,ib-4) - u(j)*val2
         end do
      end do
c
c     perform deallocation of some local arrays
c
      deallocate (sparse_row)
      deallocate (edges)
      deallocate (coef_edge)
      deallocate (coef_vertex)
      deallocate (edge_surf)
      deallocate (edge_vol)
      deallocate (edge_dist)
      deallocate (dsurf_dist)
      deallocate (dvol_dist)
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine alf_tetra  --  sphere radius orthogonal to four  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "alf_tetra" computes the radius of the sphere orthogonal
c     to the four spheres that define a tetrahedron
c
c     need to know how the radius compares to alpha, so the output
c     is the result of the comparison, not the radius itself
c
c     variables and parameters:
c
c     a,b,c,d       coordinates of four points defining tetrahedron
c     ra,rb,rc,rd   radii of the four points
c     alpha         value of alpha for the alpha shape (usually 0)
c     iflag         set to 1 if tetrahedron belongs to alpha complex,
c                     set to 0 otherwise
c
c
      subroutine alf_tetra (a,b,c,d,ra,rb,rc,rd,iflag,alpha)
      use shapes
      implicit none
      integer i,j,k
      integer iflag
      real*8 dabc,dabd,dacd,dbcd
      real*8 d1,d2,d3,d4,det
      real*8 num,den,alpha
      real*8 test,val
      real*8 ra,rb,rc,rd
      real*8 a(4),b(4),c(4),d(4)
      real*8 sab(3),sac(3),sad(3)
      real*8 sbc(3),sbd(3),scd(3)
      real*8 sa(3),sb(3),sc(3),sd(3)
      real*8 sam1(3),sbm1(3)
      real*8 scm1(3),sdm1(3)
      real*8 deter(3)
      save
c
c
      iflag = 0
      val = a(4)+b(4) - 2.0d0*(a(1)*b(1)+a(2)*b(2)+a(3)*b(3)+ra*rb)
      if (val .gt. 0)  return
      val = a(4)+c(4) - 2.0d0*(a(1)*c(1)+a(2)*c(2)+a(3)*c(3)+ra*rc)
      if (val .gt. 0)  return
      val = a(4)+d(4) - 2.0d0*(a(1)*d(1)+a(2)*d(2)+a(3)*d(3)+ra*rd)
      if (val .gt. 0)  return
      val = b(4)+c(4) - 2.0d0*(b(1)*c(1)+b(2)*c(2)+b(3)*c(3)+rb*rc)
      if (val .gt. 0)  return
      val = b(4)+d(4) - 2.0d0*(b(1)*d(1)+b(2)*d(2)+b(3)*d(3)+rb*rd)
      if (val .gt. 0)  return
      val = c(4)+d(4) - 2.0d0*(c(1)*d(1)+c(2)*d(2)+c(3)*d(3)+rc*rd)
      if (val .gt. 0)  return
c
c     compute all minors of the form:
c
c     Smn(i+j-2) = M(m,n,i,j) = Det | m(i) m(j) |
c                                   | n(i) n(j) |
c
c     for all i in [1,2] and all j in [i+1,3]
c
      do i = 1, 2
         do j = i+1, 3
            k = i + j - 2
            sab(k) = a(i)*b(j) - a(j)*b(i)
            sac(k) = a(i)*c(j) - a(j)*c(i)
            sad(k) = a(i)*d(j) - a(j)*d(i)
            sbc(k) = b(i)*c(j) - b(j)*c(i)
            sbd(k) = b(i)*d(j) - b(j)*d(i)
            scd(k) = c(i)*d(j) - c(j)*d(i)
         end do
      end do
c
c     compute all Minors of the form:
c
c     sq(i+j-2) = M(m,n,p,i,j,0) = Det | m(i) m(j) 1 |
c                                      | n(i) n(j) 1 |
c                                      | p(i) p(j) 1 |
c
c     and all Minors of the form:
c
c     det(i+j-2) = M(m,n,p,q,i,j,4,0) = Det | m(i) m(j) m(4) 1 |
c                                           | n(i) n(j) n(4) 1 |
c                                           | p(i) p(j) p(4) 1 |
c                                           | q(i) q(j) q(4) 1 |
c
c     m,n,p,q are the four vertices of the tetrahedron, i and j
c     correspond to two of the coordinates of the vertices, and
c     m(4) refers to the "weight" of vertices m
c
      do i = 1, 3
         sa(i) = scd(i) - sbd(i) + sbc(i)
         sb(i) = scd(i) - sad(i) + sac(i)
         sc(i) = sbd(i) - sad(i) + sab(i)
         sd(i) = sbc(i) - sac(i) + sab(i)
         sam1(i) = -sa(i)
         sbm1(i) = -sb(i)
         scm1(i) = -sc(i)
         sdm1(i) = -sd(i)
      end do
      do i = 1, 3
         deter(i) = a(4)*sa(i) - b(4)*sb(i) + c(4)*sc(i) - d(4)*sd(i)
      end do
c
c     find the determinant needed to compute the radius of the
c     sphere orthogonal to the four balls defining the tetrahedron
c
c     d1 = Minor(a,b,c,d,4,2,3,0)
c     d2 = Minor(a,b,c,d,1,3,4,0)
c     d3 = Minor(a,b,c,d,1,2,4,0)
c     d4 = Minor(a,b,c,d,1,2,3,0)
c
      d1 = deter(3)
      d2 = deter(2)
      d3 = deter(1)
      d4 = a(1)*sa(3) - b(1)*sb(3) + c(1)*sc(3) - d(1)*sd(3)
c
c     compute all minors of the form:
c
c     Dmnp = Minor(m,n,p,1,2,3) = Det | m(1) m(2) m(3) |
c                                     | n(1) n(2) n(3) |
c                                     | p(1) p(2) p(3) |
c
      dabc = a(1)*sbc(3) - b(1)*sac(3) + c(1)*sab(3)
      dabd = a(1)*sbd(3) - b(1)*sad(3) + d(1)*sab(3)
      dacd = a(1)*scd(3) - c(1)*sad(3) + d(1)*sac(3)
      dbcd = b(1)*scd(3) - c(1)*sbd(3) + d(1)*sbc(3)
c
c     also need to determine:
c
c     det = Det | m(1) m(2) m(3) m(4) |
c               | n(1) n(2) n(3) n(4) |
c               | p(1) p(2) p(3) p(4) |
c               | q(1) q(2) q(3) q(4) |
c
      det = -a(4)*dbcd + b(4)*dacd - c(4)*dabd + d(4)*dabc
c
c     get radius of the circumsphere of the weighted tetrahedron
c
      num = d1*d1 + d2*d2 + d3*d3 + 4*d4*det
      den = 4.0d0 * d4 * d4
c
c     if radius is too close to the value of alpha
c
      test = alpha*den - num
c
c     spectrum for a tetrahedron is [R_t Infinity]. If alpha is in
c     that interval, the tetrahedron is part of the alpha shape,
c     otherwise it is discarded
c
c     if tetrahedron is part of the alpha shape, then its triangles,
c     the edges and the vertices are also part of the alpha complex
c
      iflag = 0
      if (test .gt. 0)  iflag = 1
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine alf_trig  --  checks triangle in alpha complex  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "alf_trig" checks if whether a triangle belongs to the alpha
c     complex; computes the radius of the sphere orthogonal to the
c     three balls defining the triangle; if this radius is smaller
c     than alpha the triangle belongs to the alpha complex
c
c     also check if the triangle is "attached", i.e., if the fourth
c     vertex of any of the tetrahedra attached to the triangle is
c     "hidden" by the triangle (there are up to two such vertices,
c     D and E, depending if the triangle is on convex hull or not)
c
c     variables and parameters:
c
c     a,b,c,d,e         coordinates of the points A, B, C, D and E
c                         defining the triangle and the two vertices
c                         "attached" to it (from the two tetrahedra
c                         sharing A, B and C)
c     ra,rb,rc,rd,re    radii of the five points
c     ie                flag: 0 is e does not exist, not 0 otherwise
c     alpha             value of alpha for the alpha shape
c                         (usually 0 for measures of molecule)
c     irad              integer flag set to 1 if radius(trig) < alpha
c     iattach           integer flag set to 1 if triangle is attached
c
c
      subroutine alf_trig (a,b,c,d,e,ra,rb,rc,rd,re,
     &                     ie,irad,iattach,alpha)
      use shapes
      implicit none
      integer i,j,ie
      integer irad,iattach
      real*8 ra,rb,rc,rd,re,val
      real*8 alpha,dabc
      real*8 a(4),b(4),c(4),d(4),e(4)
      real*8 sab(3,4),sac(3,4),sbc(3,4)
      real*8 s(3,4),t(2,3)
      logical attach,testr
      save
c
c
      irad = 0
      val = a(4) + b(4) - 2.0d0*(a(1)*b(1)+a(2)*b(2)+a(3)*b(3)+ra*rb)
      if (val .gt. 0)  return
      val = a(4) + c(4) - 2.0d0*(a(1)*c(1)+a(2)*c(2)+a(3)*c(3)+ra*rc)
      if (val .gt. 0)  return
      val = b(4) + c(4) - 2.0d0*(b(1)*c(1)+b(2)*c(2)+b(3)*c(3)+rb*rc)
      if (val .gt. 0)  return
      iattach = 0
      irad = 0
c
c     compute all Minors of the form
c
c     smn(i,j) = M(m,n,i,j) = Det | m(i)  m(j) |
c                                 | n(i)  n(j) |
c
c     m,n are two vertices of the triangle, i and j correspond
c     to two of the coordinates of the vertices
c
c     for all i in [1,3] and all j in [i+1,4]
c
      do i = 1, 3
         do j = i+1, 4
            sab(i,j) = a(i)*b(j) - a(j)*b(i)
            sac(i,j) = a(i)*c(j) - a(j)*c(i)
            sbc(i,j) = b(i)*c(j) - b(j)*c(i)
         end do
      end do
c
c     next compute all Minors of the form
c 
c     s(i,j) = M(a,b,c,i,j,0) = Det | a(i) a(j) 1 |
c                                   | b(i) b(j) 1 |
c                                   | c(i) c(j) 1 |
c
c     A, B and C are the vertices of the triangle, i and j
c     correspond to two of the coordinates of the vertices
c
c     for all i in [1,3] and all j in [i+1,4]
c
      do i = 1, 3
         do j = i+1, 4
            s(i,j) = sbc(i,j) - sac(i,j) + sab(i,j)
         end do
      end do
c
c     now compute all Minors of the form
c
c     t(i,j) = M(a,b,c,i,j,4) = Det | a(i) a(j) a(4) |
c                                   | b(i) b(j) b(4) |
c                                   | c(i) c(j) c(4) |
c
c     for all i in [1,2] and all j in [i+1,3]
c
      do i = 1, 2
         do j = i+1, 3
            t(i,j) = a(4)*sbc(i,j) - b(4)*sac(i,j) + c(4)*sab(i,j)
         end do
      end do
c
c     finally, find dabc = M(a,b,c,1,2,3) = Det | a(1) a(2) a(3) |
c                                               | b(2) b(2) b(3) |
c                                               | c(3) c(2) c(3) |
c
      dabc = a(1)*sbc(2,3) - b(1)*sac(2,3) + c(1)*sab(2,3)
c
c     first check if A, B and C ate attached to D
c
      call triangle_attach (a,b,c,d,ra,rb,rc,rd,s,t,dabc,attach)
c
c     if attached, stop here as the triangle will not be part
c     of the alpha complex
c
      if (attach) then
         iattach = 1
         return
      end if
c
c     if E exists, check if A,B,C attached to E
c
      if (ie .ne. 0) then
         call triangle_attach (a,b,c,e,ra,rb,rc,re,s,t,dabc,attach)
c
c     if attached, stop here as the triangle will not be part
c     of the alpha complex
c
         if (attach) then
            iattach = 1
            return
         end if
      end if
c
c     now check if alpha is bigger than the radius of the sphere
c     orthogonal to the three balls at A, B and C
c
      call triangle_radius (a,b,c,ra,rb,rc,s,t,dabc,testr,alpha)
      if (testr)  irad = 1
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine alf_edge  --  checks edge in to alpha complex  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "alf_edge" checks if an edge belongs to the alpha complex;
c     computes the radius of the sphere orthogonal to the two
c     balls defining the edge, if this radius is smaller than
c     alpha then the edge belongs to the alpha complex
c
c     also checked if the edge is "attached", i.e., if the third
c     vertex of any of the triangles attached to the edge is
c     hidden by the edge
c
c     variables and parameters:
c
c     a,b         coordinates of the points defining the edge
c     ra,rb       radii of the two points
c     ncheck      number of triangles in the star of the edge
c     chklist   list of vertices to check
c     alpha       value of alpha for the alpha shape
c                   (usually 0 for measures of molecule)
c     irad        integer flag set to 1 if radius(edge) < alpha
c     iattach     integer flag set to 1 if edge is attached
c
c
      subroutine alf_edge (a,b,ra,rb,cg,ncheck,chklist,
     &                        irad,iattach,alpha)
      use shapes
      implicit none
      integer i,j,k,ic
      integer ncheck
      integer irad
      integer iattach
      integer chklist(*)
      real*8 alpha,val
      real*8 ra,rb,rc
      real*8 dab(4),sab(3),tab(3)
      real*8 a(4),b(4),c(4),cg(3)
      logical attach,rad
      save
c
c
      iattach = 1
      irad = 0
      val = a(4) + b(4) - 2.0d0*(a(1)*b(1)+a(2)*b(2)+a(3)*b(3)+ra*rb)
      if (val .gt. 0)  return
c
c     compute all Minors of the form
c
c     dab(i) = M(a,b,i,0) = Det | a(i) 1 |
c                               | b(i) 1 |
c
c     for all i in [1,4]
c
      do i = 1, 4
         dab(i) = a(i) - b(i)
      end do
c
c     compute all Minors of the form
c
c     sab(i,j) = M(a,b,i,j) = Det | a(i)  a(j) |
c                                 | b(i)  b(j) |
c
      do i = 1, 2
         do j = i+1, 3
            k = i + j - 2
            sab(k) = a(i)*b(j) - b(i)*a(j)
         end do
      end do
c
c     compute all Minors of the form
c
c     tab(i) = M(a,b,i,4) = Det | a(i)  a(4) |
c                               | b(i)  b(4) |
c
      do i = 1, 3
         tab(i) = a(i)*b(4) - b(i)*a(4)
      end do
c
c     first check the attachment
c
      do i = 1, ncheck
         ic = chklist(i)
         do j = 1, 3
            c(j) = crdball(3*(ic-1)+j) - cg(j)
         end do
         rc = radball(ic)
         c(4) = c(1)*c(1) + c(2)*c(2) + c(3)*c(3) - rc*rc
         call edge_attach (a,b,c,ra,rb,rc,dab,sab,tab,attach)
         if (attach)  return
      end do
      iattach = 0
c
c     edge is not attached, check radius
c
      call edge_radius (a,b,ra,rb,dab,sab,tab,rad,alpha)
      if (rad)  irad = 1
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine edge_radius  --  radius to edge circumsphere  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "edge_radius" computes the radius of the smallest circumsphere
c     to an edge, and compares it to alpha
c
c     variables and parameters:
c
c     a,b      coordinate of the two vertices defining the edge
c     dab      minor(a,b,i,0) for all i=1,2,3,4
c     sab      minor(a,b,i,j) for i = 1,2 and j =i+1,3
c     tab      minor(a,b,i,4) for i = 1,2,3
c     alpha    value of alpha considered
c     testr    flag that defines if radius smaller than alpha
c
c
      subroutine edge_radius (a,b,ra,rb,dab,sab,tab,testr,alpha)
      use iounit
      use shapes
      implicit none
      integer i
      real*8 d0,d1,d2,d3,d4
      real*8 alpha
      real*8 num,den,rho2
      real*8 ra,rb
      real*8 r_11,r_22,r_33
      real*8 r_14,r_313,r_212,diff
      real*8 a(4),b(4)
      real*8 sab(3),dab(4),tab(3)
      real*8 res(0:3,1:4)
      logical testr
      save
c
c
c     formula have been derived by projection on 4D space, which
c     requires caution when some coordinates are equal
c
      testr = .false.
      res(0,4) = dab(4)
      if (a(1) .ne. b(1)) then
         do i = 1, 3
            res(0,i) = dab(i)
            res(i,4) = tab(i)
         end do
         res(1,2) = sab(1)
         res(1,3) = sab(2)
         res(2,3) = sab(3)
      else if (a(2) .ne. b(2)) then
         res(0,1) = dab(2)
         res(0,2) = dab(3)
         res(0,3) = dab(1)
         res(1,2) = sab(3)
         res(1,3) = -sab(1)
         res(2,3) = -sab(2)
         res(1,4) = tab(2)
         res(2,4) = tab(3)
         res(3,4) = tab(1)
      else if (a(3) .ne. b(3)) then
         res(0,1) = dab(3)
         res(0,2) = dab(1)
         res(0,3) = dab(2)
         res(1,2) = -sab(2)
         res(1,3) = -sab(3)
         res(2,3) = sab(1)
         res(1,4) = tab(3)
         res(2,4) = tab(1)
         res(3,4) = tab(2)
      else
         write (iout,10)
   10    format (/,' EDGE_RADIUS  --  A Fatal Error has Occurred')
         call fatal
      end if
      r_11 = res(0,1) * res(0,1)
      r_22 = res(0,2) * res(0,2)
      r_33 = res(0,3) * res(0,3)
      r_14 = res(0,1) * res(0,4)
      r_313 = res(0,3) * res(1,3)
      r_212 = res(0,2) * res(1,2)
      diff = res(0,3)*res(1,2) - res(0,2)*res(1,3)
c
c     first compute the radius of circumsphere
c
      d0 = -2.0d0 * res(0,1) * (r_11+r_22+r_33)
      d1 = res(0,1) * (2.0d0*(r_313+r_212)-r_14)
      d2 = -2.0d0*res(1,2)*(r_11+r_33) - res(0,2)*(r_14-2.0d0*r_313)
      d3 = -2.0d0*res(1,3)*(r_11+r_22) - res(0,3)*(r_14-2*r_212)
      d4 = 2.0d0 * res(0,1) * (res(0,1)*res(1,4) + res(0,2)*res(2,4)
     &        + res(0,3)*res(3,4)) + 4.0d0*(res(2,3)*diff
     &        - res(0,1)*(res(1,2)*res(1,2) + res(1,3)*res(1,3)))
      num = d1*d1 + d2*d2 + d3*d3 - d0*d4
      den = d0 * d0
c
c     for efficiency, assume this routine is only used to compute
c     the dual complex (i.e., alpha=0) and thus do not consider
c     the denominator as it is always positive
c
c     rho2 = num / den
      rho2 = num
      if (alpha .gt. rho2)  testr = .true.
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine edge_attach  --  edge attached to tetrahedron  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "edge_attach" checks if edge AB of a tetrahedron is "attached"
c     to a given vertex C
c
c     variables and parameters:
c
c     a,b,c       coordinates of the three points
c     ra,rb,rc    radii of the three pointd
c     dab         minor(a,b,i,0) for all i=1,2,3,4
c     sab         minor(a,b,i,j) for i = 1,2 and j =i+1,3
c     tab         minor(a,b,i,4) for all i=1,2,3
c     testa       logical flag marks if edge is attached or not
c
c
      subroutine edge_attach (a,b,c,ra,rb,rc,dab,sab,tab,testa)
      use iounit
      use shapes
      implicit none
      integer i,j,k
      real*8 dtest
      real*8 r_11,r_22,r_33
      real*8 diff,d0,d5
      real*8 ra,rb,rc
      real*8 sab(3),dab(4),tab(3)
      real*8 sc(3),tc(3)
      real*8 a(4),b(4),c(4)
      real*8 res(0:3,1:3)
      real*8 res2_c(3,4)
      logical testa
      save
c
c
c     need to compute:
c     sc as minor(a,b,c,i,j,0) for i = 1,2 and j = i+1,3
c     tc as minor(a,b,c,i,4,0) for i = 1,2,3
c
      testa = .false.
      do i = 1, 2
         do j = i+1, 3
            k = i + j - 2
            sc(k) = c(i)*dab(j) - c(j)*dab(i) + sab(k)
         end do
      end do
      do i = 1, 3
         tc(i) = c(i)*dab(4) - c(4)*dab(i) + tab(i)
      end do
c
c     formula have been derived by projection on 4D space, which
c     requires caution when some coordinates are equal
c
      if (a(1) .ne. b(1)) then
         do i = 1, 3
            res(0,i) = dab(i)
            res2_c(i,4) = tc(i)
         end do
         res(1,2) = sab(1)
         res(1,3) = sab(2)
         res(2,3) = sab(3)
         res2_c(1,2) = sc(1)
         res2_c(1,3) = sc(2)
         res2_c(2,3) = sc(3)
      else if (a(2) .ne. b(2)) then
         res(0,1) = dab(2)
         res(0,2) = dab(3)
         res(0,3) = dab(1)
         res(1,2) = sab(3)
         res(1,3) = -sab(1)
         res(2,3) = -sab(2)
         res2_c(1,2) = sc(3)
         res2_c(1,3) = -sc(1)
         res2_c(2,3) = -sc(2)
         res2_c(1,4) = tc(2)
         res2_c(2,4) = tc(3)
         res2_c(3,4) = tc(1)
      else if (a(3) .ne. b(3)) then
         res(0,1) = dab(3)
         res(0,2) = dab(1)
         res(0,3) = dab(2)
         res(1,2) = -sab(2)
         res(1,3) = -sab(3)
         res(2,3) = sab(1)
         res2_c(1,2) = -sc(2)
         res2_c(1,3) = -sc(3)
         res2_c(2,3) = sc(1)
         res2_c(1,4) = tc(3)
         res2_c(2,4) = tc(1)
         res2_c(3,4) = tc(2)
      else
         write (iout,10)
   10    format (/,' EDGE_ATTACH  --  A Fatal Error has Occurred')
         call fatal
      end if
      r_11 = res(0,1) * res(0,1)
      r_22 = res(0,2) * res(0,2)
      r_33 = res(0,3) * res(0,3)
      diff = res(0,3)*res(1,2) - res(0,2)*res(1,3)
c
c     check the attachment with vertex C
c
      d0 = -2.0d0 * res(0,1) * (r_11+r_22+r_33)
      d5 = res(0,1) * (res(0,1)*res2_c(1,4) + res(0,2)*res2_c(2,4)
     &        + res(0,3)*res2_c(3,4) - 2.0d0*(res(1,3)*res2_c(1,3)
     &        + res(1,2)*res2_c(1,2))) + 2.0d0*res2_c(2,3)*diff
      dtest = d0 * d5
      if (dtest .lt. 0)  testa = .true.
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine triangle_attach  --  test point in circumsphere  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "triangle_attach" tests whether a point D is inside the
c     circumsphere defined by three other points A, B and C
c
c     for the three points A,B,C that form the triangles, the code
c     needs as input the following determinants:
c
c     s(i,j) = Minor(a,b,c,i,j,0) = det | a(i) a(j) 1 |
c                                       | b(i) b(j) 1 |
c                                       | c(i) c(j) 1 |
c     for all i in [1,3], j in [i+1,4]
c
c     t(i,j) = Minor(a,b,c,i,j,4) = det | a(i) a(j) a(4) |
c                                       | b(i) b(j) b(4) |
c                                       | c(i) c(j) c(4) |
c
c     for all i in [1,2] and all j in [i+1,3]
c
c     dabc = det | a(1) a(2) a(3) |
c                | b(1) b(2) b(3) |
c                | c(1) c(2) c(3) |
c
c     and the coordinates of the fourth vertex d
c
c     upon output "testa" is set to 1 if the fourth point d is
c     inside the circumsphere of {a,b,c}
c
c
      subroutine triangle_attach (a,b,c,d,ra,rb,rc,rd,s,t,dabc,testa)
      use shapes
      implicit none
      real*8 test
      real*8 dabc,deter
      real*8 det1,det2,det3
      real*8 ra,rb,rc,rd
      real*8 a(4),b(4)
      real*8 c(4),d(4)
      real*8 s(3,4),t(2,3)
      logical testa
      save
c
c
      testa = .false.
      det1 = -d(2)*s(3,4) + d(3)*s(2,4) - d(4)*s(2,3) + t(2,3)
      det2 = -d(1)*s(3,4) + d(3)*s(1,4) - d(4)*s(1,3) + t(1,3)
      det3 = -d(1)*s(2,4) + d(2)*s(1,4) - d(4)*s(1,2) + t(1,2)
      deter = -d(1)*s(2,3) + d(2)*s(1,3) - d(3)*s(1,2) + dabc
c
c     check if the face is attached to the fourth vertex of
c     the parent tetrahedron
c
      test = det1*s(2,3) + det2*s(1,3) + det3*s(1,2)
     &          - 2.0d0*deter*dabc 
      if (test .gt. 0)  testa = .true.
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine triangle_radius  --  radius containing triangle  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "triangle_radius" finds the radius of the smallest circumsphere
c     to a triangle
c
c     for the three points A,B,C that form the triangles, the code
c     needs as input the following determinants:
c
c     s(i,j) = Minor(a,b,c,i,j,0) = det | a(i) a(j) 1 |
c                                       | b(i) b(j) 1 |
c                                       | c(i) c(j) 1 |
c
c     for i in [1,3] and j in [i+1,4]
c
c     t(i,j) = Minor(a,b,c,i,j,4) = det | a(i) a(j) a(4) |
c                                       | b(i) b(j) b(4) |
c                                       | c(i) c(j) c(4) |
c
c     dabc = Minor(a,b,c,1,2,3)
c
c     upon output "testr" is set to 1 if alpha is larger than rho,
c     the radius of the circumsphere of the triangle
c
c
      subroutine triangle_radius (a,b,c,ra,rb,rc,s,t,
     &                            dabc,testr,alpha)
      use shapes
      implicit none
      real*8 dabc
      real*8 d0,d1,d2,d3,d4
      real*8 alpha
      real*8 sums2,num
      real*8 ra,rb,rc
      real*8 a(4),b(4),c(4)
      real*8 s(3,4),t(2,3)
      logical testr
      save
c
c
      testr = .false.
      sums2 = s(1,2)*s(1,2) + s(1,3)*s(1,3) + s(2,3)*s(2,3)
      d0 = sums2
      d1 = s(1,3)*s(3,4) + s(1,2)*s(2,4) - 2.0d0*dabc*s(2,3)
      d2 = s(1,2)*s(1,4) - s(2,3)*s(3,4) - 2.0d0*dabc*s(1,3)
      d3 = s(2,3)*s(2,4) + s(1,3)*s(1,4) + 2.0d0*dabc*s(1,2)
      d4 = s(1,2)*t(1,2) + s(1,3)*t(1,3) + s(2,3)*t(2,3)
     &        - 2.0d0*dabc*dabc
      num = 4.0d0*(d1*d1+d2*d2+d3*d3) + 16.0d0*d0*d4
      if (alpha .gt. num)  testr = .true.
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine vertex_attach  --  vertex-vertex attachment  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "vertex_attach" tests for a vertex is attached to another
c     vertex, the computation is done in both directions
c
c     let S be a simplex, and y_S the center of the ball orthogonal
c     to all balls in S; point p is attached to S if and only if
c     pi(y_S, p) < 0, where pi is the power distance between the
c     two weighted points y_S and p
c
c     let S = {a}, with a weight of ra**2, then y_S is the ball
c     centered at a, but with weight -ra**2, the power distance
c     between y_S and a point b is:
c
c     pi(y_S, b) = dist(a,b)**2 + ra**2 - rb**2
c
c
      subroutine vertex_attach (a,b,ra,rb,testa,testb)
      use shapes
      implicit none
      integer i
      real*8 ra,rb,ra2,rb2
      real*8 dist2
      real*8 test1,test2
      real*8 dab(3)
      real*8 a(4),b(4)
      logical testa,testb
      save
c
c
      testa = .false.
      testb = .false.
      do i = 1, 3
         dab(i) = a(i) - b(i)
      end do
      ra2 = ra * ra
      rb2 = rb * rb
      dist2 = dab(1)*dab(1) + dab(2)*dab(2) + dab(3)*dab(3)
      test1 = dist2 + ra2 - rb2
      test2 = dist2 - ra2 + rb2
      if (test1 .lt. 0)  testa = .true.
      if (test2 .lt. 0)  testb = .true.
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine locate_jw  --  find tetrahedron with new point  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "locate_jw" finds the tetrahedron containing a new point to be
c     added in the triangulation
c
c     variables and parameters:
c
c     ival         index of the points to be located
c     tetra_loc    tetrahedron containing the point
c     iredundant   flag set to 0 if not redundant, 1 otherwise
c
c     the point location scheme uses a "jump-and-walk" technique;
c     first, N active tetrahedra are chosen at random, the distances
c     between these tetrahedra and the point to be added are computed,
c     and the tetrahedron closest to the point is chosen as a starting
c     point, then walk from that tetrahedron to the point, until a
c     tetrahedron containing the point is found; also checks if the
c     point is redundant in the current tetrahedron, ending the search
c
c
      subroutine locate_jw (iseed,ival,tetra_loc,iredundant)
      use shapes
      implicit none
      integer i,ival,itetra
      integer a,b,c,d
      integer idx,iorient,iseed
      integer tetra_loc,iredundant
      logical test_in,test_red
      save
c
c
c     start at the root of the history dag with tetra(1)
c
      iredundant = 0
      if (ntetra .eq. 1) then
         tetra_loc = 1
         return
      end if
      if (tetra_loc .le. 0) then
         do i = ntetra, 1, -1
            if (btest(tinfo(i),1)) then
               itetra = i
               goto 10
            end if
         end do
   10    continue
      else
         itetra = tetra_loc
      end if
   20 continue
      a = tetra(1,itetra)
      b = tetra(2,itetra)
      c = tetra(3,itetra)
      d = tetra(4,itetra)
      iorient = -1
      if (btest(tinfo(itetra),0))  iorient = 1
      call inside_tetra_jw (ival,a,b,c,d,iorient,test_in,test_red,idx)
      if (test_in)  goto 30
      itetra = tneighbor(idx,itetra)
      goto 20
   30 continue
      tetra_loc = itetra
c
c     tetrahedron is found, so check if point is redundant
c
      if (test_red)  iredundant = 1
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine inside_tetra_jw  --  tests point in tetrahedron  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "inside_tetra_jw" tests if a point P is inside the tetrahedron
c     defined by four points ABCD with orientation "iorient", if P
c     is inside the tetrahedron, then also checks if it is redundant
c
c     variables and parameters:
c
c     p           index of the point to be checked
c     a,b,c,d     four vertices of the tetrahedron
c     iorient     orientation of the tetrahedron
c     inside      logical flag to mark P inside the ABCD tetrahedron
c     redundant   logical flag to mark whether point P is redundant
c     ifail       index of the face that fails the orientation test
c                   in case where P is not inside the tetrahedron
c
c
      subroutine inside_tetra_jw (p,a,b,c,d,iorient,inside,
     &                               redundant,ifail)
      use shapes
      implicit none
      integer i,j,k,l,m
      integer p,a,b,c,d
      integer ia,ib,ic,id,ie,idx
      integer ic1,ic5,ic1_k,ic1_l
      integer sign,sign5
      integer sign_k,sign_l
      integer nswap,iswap,ninf
      integer iorient,ifail,val
      integer list(4)
      integer sign4_3(4)
      integer infpoint(4)
      integer inf4_1(4),sign4_1(4)
      integer inf4_2(4,4),sign4_2(4,4)
      integer inf5_2(4,4),sign5_2(4,4)
      integer inf5_3(4),sign5_3(4)
      integer order1(3,4),order2(2,6)
      integer order3(2,6)
      real*8 sij_1,sij_2,sij_3
      real*8 skl_1,skl_2,skl_3
      real*8 det_pijk,det_pjil
      real*8 det_pkjl,det_pikl
      real*8 det_pijkl
      real*8 detij(3)
      real*8 coordp(3)
      real*8 i_p(4),j_p(4)
      real*8 k_p(4),l_p(4)
      logical test_pijk,test_pjil
      logical test_pkjl,test_pikl
      logical inside,redundant
      logical doweight
      data inf4_1  / 2, 2, 1, 1 /
      data sign4_1  / -1, 1, 1, -1 /
      data inf4_2  / 0, 2, 3, 3, 2, 0, 3, 3, 3, 3, 0, 1, 3, 3, 1, 0 /
      data sign4_2  / 0, 1, -1, 1, -1, 0, 1, -1,
     &                1, -1, 0, 1, -1, 1, -1, 0 /
      data sign4_3  / -1, 1, -1, 1 /
      data inf5_2  / 0, 2, 1, 1, 2, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0 /
      data sign5_2  / 0, -1, -1, 1, 1, 0, -1, 1,
     &                1, 1, 0, 1, -1, -1, -1, 0 /
      data inf5_3  / 1, 1, 3, 3/
      data sign5_3  / 1, 1, -1, 1 /
      data order1  / 3, 2, 4, 1, 3, 4, 2, 1, 4, 1, 2, 3 /
      data order2  / 3, 4, 4, 2, 2, 3, 1, 4, 3, 1, 1, 2 /
      data order3  / 1, 2, 1, 3, 1, 4, 2, 3, 2, 4, 3, 4 /
      save
c
c
c     if IJKL is the tetrahedron in positive orientation, then test
c     PIJK, PJIL, PKJL and PIKL, if all four are positive, than P is
c     inside the tetrahedron, all four tests rely on the sign of the
c     corresponding 4x4 determinant. Interestingly, these four
c     determinants share some common lines, which can be used to
c     speed up the computation
c
c     consider:  det(p,i,j,k) = | p(1) p(2) p(3) 1 |
c                               | i(1) i(2) i(3) 1 |
c                               | j(1) j(2) j(3) 1 |
c                               | k(1) k(2) k(3) 1 |
c
c     note P appears in each determinant, so the corresponding line
c     can be substraced from all other lines; using the example
c     above gives:
c
c     det(i,j,k,l) = - | ip(1) ip(2) ip(3) |
c                      | jp(1) jp(2) jp(3) |
c                      | kp(1) kp(2) kp(3) |
c
c     where xp(m) = x(m)-p(m) for x = i,j,k and m = 1,2,3
c
c     notice the first two lines of det(p,i,j,k) and det(p,i,j,l)
c     are the same
c
c     let us define:
c
c     Sij_3=|ip(1) ip(2)|  Sij_2=|ip(1) ip(3)|  Sij_1=|ip(2) ip(3)|
c           |jp(1) jp(2)|        |jp(1) jp(3)|        |jp(2) jp(3)|
c
c     then det(p,i,j,k) = -kp(1)*Sij_1 + kp(2)*Sij_2 - kp(3)*Sij_3,
c     and det(p,j,i,l) = lp(1)*Sij_1 - lp(2)*Sij_2 + lp(3)*Sij_3
c
c     similarly, define: 
c
c     Skl_3=|kp(1) kp(2)|  Skl_2=|kp(1) kp(3)|  Skl_1=|kp(2) kp(3)|
c           |lp(1) lp(2)|        |lp(1) lp(3)|        |lp(2) lp(3)|
c
c     then det(p,k,j,l) = jp(1)*Skl_1 - jp(2)*Skl_2 + jp(3)*Skl_3,
c     and det(p,i,k,l) = -ip(1)*Skl_1 + ip(2)*Skl_2 - ip(3)*Skl_3
c
c     furthermore:
c
c     det(p,i,j,k,l) = -ip(4)*det(p,k,j,l) - jp(4)*det(p,i,k,l)
c                         - kp(4)*det(p,j,i,l) - lp(4)*det(p,i,j,k)
c
c     the equations above hold for the general case, but special
c     care is required to take in account infinite points
c
      doweight = .true.
      inside = .false.
      redundant = .false.
      list(1) = a
      list(2) = b
      list(3) = c
      list(4) = d
      infpoint(1) = 0
      infpoint(2) = 0
      infpoint(3) = 0
      infpoint(4) = 0
      if (a .le. 4)  infpoint(1) = 1
      if (b .le. 4)  infpoint(2) = 1
      if (c .le. 4)  infpoint(3) = 1
      if (d .le. 4)  infpoint(4) = 1
      ninf = infpoint(1) + infpoint(2) + infpoint(3) + infpoint(4)
c
c     the general case, with no infinite point
c
      do m = 1, 3
         coordp(m) = crdball(3*p-3+m)
      end do
c
c     set coordinates using i=a, j=b, k=c and l=d for convenience
c
      if (ninf .eq. 0) then
         do m = 1, 3
            i_p(m) = crdball(3*a-3+m) - coordp(m)
            j_p(m) = crdball(3*b-3+m) - coordp(m)
            k_p(m) = crdball(3*c-3+m) - coordp(m)
            l_p(m) = crdball(3*d-3+m) - coordp(m)
         end do
c
c     compute the 2x2 determinants for Sij and Skl
c
         sij_1 = i_p(2)*j_p(3) - i_p(3)*j_p(2)
         sij_2 = i_p(1)*j_p(3) - i_p(3)*j_p(1)
         sij_3 = i_p(1)*j_p(2) - i_p(2)*j_p(1)
         skl_1 = k_p(2)*l_p(3) - k_p(3)*l_p(2)
         skl_2 = k_p(1)*l_p(3) - k_p(3)*l_p(1)
         skl_3 = k_p(1)*l_p(2) - k_p(2)*l_p(1)
c
c     tests for all determinants, start with inside set to false
c
         inside = .false.
         det_pijk = -k_p(1)*sij_1 + k_p(2)*sij_2 - k_p(3)*sij_3
         det_pijk = det_pijk * dble(iorient)
         test_pijk = (abs(det_pijk) .gt. epsln4)
         if (test_pijk .and. det_pijk.gt.0.0d0) then
            ifail = 4
            return
         end if
         det_pjil = l_p(1)*sij_1 - l_p(2)*sij_2 + l_p(3)*sij_3
         det_pjil = det_pjil * dble(iorient)
         test_pjil = (abs(det_pjil) .gt. epsln4)
         if (test_pjil .and. det_pjil.gt.0.0d0) then
            ifail = 3
            return
         end if
         det_pkjl = j_p(1)*skl_1 - j_p(2)*skl_2 + j_p(3)*skl_3
         det_pkjl = det_pkjl * dble(iorient)
         test_pkjl = (abs(det_pkjl) .gt. epsln4)
         if (test_pkjl .and. det_pkjl.gt.0.0d0) then
            ifail = 1
            return
         end if
         det_pikl = -i_p(1)*skl_1 + i_p(2)*skl_2 - i_p(3)*skl_3
         det_pikl = det_pikl * dble(iorient)
         test_pikl = (abs(det_pikl) .gt. epsln4)
         if (test_pikl .and. det_pikl.gt.0.0d0) then
            ifail = 2
            return
         end if
c
c     either all four determinants are positive, or one of the
c     determinants is imprecise in which case pecial care is
c     needed and the indices will be ranked
c
         if (.not. test_pijk) then
            call valsort4 (p,a,b,c,ia,ib,ic,id,nswap)
            call minor4 (crdball,ia,ib,ic,id,val)
            val = val * nswap * iorient
            if (val .eq. 1) then
               ifail = 4
               return
            end if
         end if
         if (.not. test_pjil) then
            call valsort4 (p,b,a,d,ia,ib,ic,id,nswap)
            call minor4 (crdball,ia,ib,ic,id,val)
            val = val * nswap * iorient
            if (val .eq. 1) then
               ifail = 3
               return
            end if
         end if
         if (.not. test_pkjl) then
            call valsort4 (p,c,b,d,ia,ib,ic,id,nswap)
            call minor4 (crdball,ia,ib,ic,id,val)
            val = val * nswap * iorient
            if (val .eq. 1) then
               ifail = 1
               return
            end if
         end if
         if (.not. test_pikl) then
            call valsort4 (p,a,c,d,ia,ib,ic,id,nswap)
            call minor4 (crdball,ia,ib,ic,id,val)
            val = val * nswap * iorient
            if (val .eq. 1) then
               ifail = 2
               return
            end if
         end if
c
c     at this point P is inside the tetrahedron, then check
c     to see whether P is redundant
c
         inside = .true.
         if (.not. doweight)  return
         i_p(4) = wghtball(a) - wghtball(p)
         j_p(4) = wghtball(b) - wghtball(p)
         k_p(4) = wghtball(c) - wghtball(p)
         l_p(4) = wghtball(d) - wghtball(p)
         det_pijkl = -i_p(4)*det_pkjl - j_p(4)*det_pikl
     &                  - k_p(4)*det_pjil - l_p(4)*det_pijk
         if (abs(det_pijkl) .lt. epsln5) then
            call valsort5 (p,a,b,c,d,ia,ib,ic,id,ie,nswap)
            call minor5 (crdball,radball,ia,ib,ic,id,ie,val)
            det_pijkl = val * nswap * iorient
         end if
         redundant = (det_pijkl .lt. 0.0d0)
c
c     one of the vertices A, B, C or D is infinite, to find which
c     it is, we use a map between (inf(a),inf(b),inf(c),inf(d))
c     and X, where inf(i) is 1 if i is infinite, 0 otherwise,
c     and X = 1,2,3,4 if A, B, C or D are infinite, respectively;
c     a good mapping function is: X = 3-inf(a)-inf(a)-inf(b)+inf(d)
c
      else if (ninf .eq. 1) then
         idx = 3 - infpoint(1) - infpoint(1) - infpoint(2) + infpoint(4)
         l = list(idx)
         i = list(order1(1,idx))
         j = list(order1(2,idx))
         k = list(order1(3,idx))
         ic1 = inf4_1(l)
         sign = sign4_1(l)
c
c     there are four determinants that need to be computed:
c
c     det_pijk   unchanged
c     det_pjil   1 infinite point (l), becomes det3_pji
c                  where det3_pij = | p(ic1) p(ic2) 1 |
c                                   | i(ic1) i(ic2) 1 |
c                                   | j(ic1) j(ic2) 1 |
c                  and ic1 and ic2 depends on which infinite
c                  (ic2 is always 3) point is considered
c     det_pkjl   1 infinite point (l), becomes det3_pkj
c     det_pikl   1 infinite point (l), becomes det3_pik
c
         do m = 1, 3
            i_p(m) = crdball(3*i-3+m) - coordp(m)
            j_p(m) = crdball(3*j-3+m) - coordp(m)
            k_p(m) = crdball(3*k-3+m) - coordp(m)
         end do
         detij(1) = i_p(1)*j_p(3) - i_p(3)*j_p(1)
         detij(2) = i_p(2)*j_p(3) - i_p(3)*j_p(2)
         detij(3) = i_p(1)*j_p(2) - i_p(2)*j_p(1)
c
c     tests for all determinants, start with inside set to false
c
         inside = .false.
         det_pijk = -k_p(1)*detij(2) + k_p(2)*detij(1)
     &                 - k_p(3)*detij(3)
         det_pijk = det_pijk * dble(iorient)
         test_pijk = (abs(det_pijk) .gt. epsln4)
         if (test_pijk .and. det_pijk.gt.0) then
            ifail = idx
            return
         end if
         det_pjil = -detij(ic1) * sign * iorient
         test_pjil = (abs(det_pjil) .gt. epsln3)
         if (test_pjil .and. det_pjil.gt.0.0d0) then
            ifail = order1(3,idx)
            return
         end if
         det_pkjl = k_p(ic1)*j_p(3) - k_p(3)*j_p(ic1)
         det_pkjl = det_pkjl * sign * iorient
         test_pkjl = (abs(det_pkjl) .gt. epsln3)
         if (test_pkjl .and. det_pkjl.gt.0.0d0) then
            ifail = order1(1,idx)
            return
         end if
         det_pikl = i_p(ic1)*k_p(3) - i_p(3)*k_p(ic1)
         det_pikl = det_pikl * sign * iorient
         test_pikl = (abs(det_pikl) .gt. epsln3)
         if (test_pikl .and. det_pikl.gt.0.0d0) then
            ifail = order1(2,idx)
            return
         end if
c
c     either all four determinants are positive, or one of the
c     determinants is imprecise in which case special care is
c     needed and the indices will be ranked
c
         if (.not. test_pijk) then
            call valsort4 (p,i,j,k,ia,ib,ic,id,nswap)
            call minor4 (crdball,ia,ib,ic,id,val)
            val = val * nswap * iorient
            if (val .eq. 1) then
               ifail = idx
               return
            end if
         end if
         if (.not. test_pjil) then
            call valsort3 (p,j,i,ia,ib,ic,nswap)
            call minor3 (crdball,ia,ib,ic,ic1,3,val)
            val = val * sign * nswap * iorient
            if (val .eq. 1) then
               ifail = order1(3,idx)
               return
            end if
         end if
         if (.not. test_pkjl) then
            call valsort3 (p,k,j,ia,ib,ic,nswap)
            call minor3 (crdball,ia,ib,ic,ic1,3,val)
            val = val * sign * nswap * iorient
            if (val .eq. 1) then
               ifail = order1(1,idx)
               return
            end if
         end if
         if (.not. test_pikl) then
            call valsort3 (p,i,k,ia,ib,ic,nswap)
            call minor3 (crdball,ia,ib,ic,ic1,3,val)
            val = val * sign * nswap * iorient
            if (val .eq. 1) then
               ifail = order1(2,idx)
               return
            end if
         end if
c
c     at this point P is inside the tetrahedron, and since
c     det_pijkl = det_pijk > 1, P cannot be redundant
c
         inside = .true.
         redundant = .false.
c
c     two of the vertices A, B, C and D are infinite, to find which
c     they are, we use a map between (inf(a),inf(b),inf(c),inf(d))
c     and X, where inf(i) is 1 if i is infinite, 0 otherwise,
c     and X = 1,2,3,4,5,6 if (a,b), (a,c), (a,d), (b,c), (b,d) or
c     (c,d) are infinite, respectively, a good mapping function is:
c     X = 3-inf(a)-inf(a)+inf(c)+inf(d)+inf(d)
c
      else if (ninf .eq. 2) then
         idx = 3 - infpoint(1) - infpoint(1) + infpoint(3)
     &            + infpoint(4) + infpoint(4)
         k = list(order3(1,idx))
         l = list(order3(2,idx))
         i = list(order2(1,idx))
         j = list(order2(2,idx))
         ic1_k = inf4_1(k)
         ic1_l = inf4_1(l)
         sign_k = sign4_1(k)
         sign_l = sign4_1(l)
         ic1 = inf4_2(k,l)
         sign = sign4_2(k,l)
c
c     tests for all determinants, start with inside set to false
c
         do m = 1, 3
            i_p(m) = crdball(3*i-3+m) - coordp(m)
            j_p(m) = crdball(3*j-3+m) - coordp(m)
         end do
         inside = .false.
         det_pijk = i_p(ic1_k)*j_p(3) - i_p(3)*j_p(ic1_k)
         det_pijk = det_pijk * sign_k * iorient
         test_pijk = (abs(det_pijk) .gt. epsln3)
         if (test_pijk .and. det_pijk.gt.0.0d0) then
            ifail = order3(2,idx)
            return
         end if
         det_pjil = i_p(3)*j_p(ic1_l) - i_p(ic1_l)*j_p(3)
         det_pjil = det_pjil * sign_l * iorient
         test_pjil = (abs(det_pjil) .gt. epsln3)
         if (test_pjil .and. det_pjil.gt.0.0d0) then
            ifail = order3(1,idx)
            return
         end if
         det_pkjl = j_p(ic1) * sign * iorient
         test_pkjl = (abs(det_pkjl) .gt. epsln2)
         if (test_pkjl .and. det_pkjl.gt.0.0d0) then
            ifail = order2(1,idx)
            return
         end if
         det_pikl = -i_p(ic1) * sign * iorient
         test_pikl = (abs(det_pikl) .gt. epsln2)
         if (test_pikl .and. det_pikl.gt.0.0d0) then
            ifail = order2(2,idx)
            return
         end if
c
c     either all four determinants are positive, or one of the
c     determinants is imprecise in which case special care is
c     needed and the indices will be ranked
c
         if (.not. test_pijk) then
            call valsort3 (p,i,j,ia,ib,ic,nswap)
            call minor3 (crdball,ia,ib,ic,ic1_k,3,val)
            val = val * sign_k * nswap * iorient
            if (val .eq. 1) then
               ifail = order3(2,idx)
               return
            end if
         end if
         if (.not. test_pjil) then
            call valsort3 (p,j,i,ia,ib,ic,nswap)
            call minor3 (crdball,ia,ib,ic,ic1_l,3,val)
            val = val * sign_l * nswap * iorient
            if (val .eq. 1) then
               ifail = order3(1,idx)
               return
            end if
         end if
         if (.not. test_pkjl) then
            call valsort2 (p,j,ia,ib,nswap)
            call minor2 (crdball,ia,ib,ic1,val)
            val = -val * sign * nswap * iorient
            if (val .eq. 1) then
               ifail = order2(1,idx)
               return
            end if
         end if
         if (.not. test_pikl) then
            call valsort2 (p,i,ia,ib,nswap)
            call minor2 (crdball,ia,ib,ic1,val)
            val = val * sign * nswap * iorient
            if (val .eq. 1) then
               ifail = order2(2,idx)
               return
            end if
         end if
c
c     at this point P is inside the tetrahedron, then check
c     to see whether P is redundant
c
         inside = .true.
         redundant = .false.
         if (.not. doweight)  return
         ic5 = inf5_2(k,l)
         sign5 = sign5_2(k,l)
         det_pijkl = i_p(ic5)*j_p(3) - i_p(3)*j_p(ic5)
         if (abs(det_pijkl) .lt. epsln3) then
            call valsort3 (p,i,j,ia,ib,ic,nswap)
            call minor3 (crdball,ia,ib,ic,ic5,3,val)
            det_pijkl = val * nswap
         end if
         det_pijkl = det_pijkl * sign5 * iorient
         redundant = (det_pijkl .lt. 0.0d0)
c
c     three of vertices a, b, c and d are infinite, to find which
c     is finite, use a map between (inf(a),inf(b),inf(c),inf(d))
c     and X, where inf(i) is 1 if i is infinite, 0 otherwise, and
c     X = 1,2,3,4 if a,b,c or d are finite, respectively; a good
c     mapping function is X = 1+inf(a)+inf(a)+inf(b)-inf(d)
c
      else if (ninf .eq. 3) then
         idx = 1 + infpoint(1) + infpoint(1)
     &             + infpoint(2) - infpoint(4)
         i = list(idx) 
         j = list(order1(1,idx))
         k = list(order1(2,idx))
         l = list(order1(3,idx))
         call missinf_sign (j,k,l,ie,iswap)
         do m = 1, 3
            i_p(m) = crdball(3*i-3+m) - coordp(m)
         end do
c
c     tests for all determinants, start with inside set to false
c
         inside = .false.
         det_pijk = i_p(inf4_2(j,k)) * iorient * sign4_2(j,k)
         test_pijk = (abs(det_pijk) .gt. epsln2)
         if (test_pijk .and. det_pijk.gt.0.0d0) then
            ifail = order1(3,idx)
            return
         end if
         det_pjil = -i_p(inf4_2(j,l)) * iorient * sign4_2(j,l)
         test_pjil = (abs(det_pjil) .gt. epsln2)
         if (test_pjil .and. det_pjil.gt.0.0d0) then
            ifail = order1(2,idx)
            return
         end if
         det_pkjl = iorient * iswap * sign4_3(ie)
         if (det_pkjl .gt. 0.0d0) then
            ifail = idx
            return
         end if
         det_pikl = i_p(inf4_2(k,l)) * iorient * sign4_2(k,l)
         test_pikl = (abs(det_pikl) .gt. epsln2)
         if (test_pikl .and. det_pikl.gt.0.0d0) then
            ifail = order1(1,idx)
            return
         end if
c
c     either all four determinants are positive, or one of the
c     determinants is imprecise in which case special care is
c     needed and the indices will be ranked
c
         if (.not. test_pijk) then
            call valsort2 (p,i,ia,ib,nswap)
            call minor2 (crdball,ia,ib,inf4_2(j,k),val)
            val = -val * sign4_2(j,k) * iorient * nswap
            if (val .eq. 1) then
               ifail = order1(3,idx)
               return
            end if
         end if
         if (.not. test_pjil) then
            call valsort2 (p,i,ia,ib,nswap)
            call minor2 (crdball,ia,ib,inf4_2(j,l),val)
            val = val * sign4_2(j,l) * iorient * nswap
            if (val .eq. 1) then
               ifail = order1(2,idx)
               return
            end if
         end if
         if (.not. test_pikl) then
            call valsort2 (p,i,ia,ib,nswap)
            call minor2 (crdball,ia,ib,inf4_2(k,l),val)
            val = -val * sign4_2(k,l) * iorient * nswap
            if (val .eq. 1) then
               ifail = order1(1,idx)
               return
            end if
         end if
c
c     at this point P is inside the tetrahedron, then check
c     to see whether P is redundant
c
         inside = .true.
         redundant = .false.
         if (.not. doweight)  return
         ic1 = inf5_3(ie)
         sign5 = sign5_3(ie)
         det_pijkl = -i_p(ic1)
         if (abs(det_pijkl) .lt. epsln2) then
            call valsort2 (p,i,ia,ib,nswap)
            call minor2 (crdball,ia,ib,ic1,val)
            det_pijkl = val * nswap
         end if
         det_pijkl = -det_pijkl * sign5 * iorient * iswap
         redundant = (det_pijkl .lt. 0.0d0)
c
c     if all four points ia, ib, ic and id are infinite,
c     then inside must be true and redundant is false
c
      else
         inside = .true.
         redundant = .false.
      end if
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine regular_convex  --  locally regular link facet  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "regular_convex" checks if a link facet (a,b,c) is locally
c     regular, as well as if the union of the two tetrahedra ABCP
c     and ABCO that connect to the facet is convex
c
c     for floating point, points need not be in lexicographic order
c     prior to computing a determinant; this is not true if the
c     value is near zero where special care is needed and the points
c     are ordered using a series of "valsort" routines
c
c     variables and parameters:
c
c     a,b,c        three points defining the link facet
c     p            current point inserted in the triangulation
c     o            fourth point of the tetrahedron that attaches
c                    to ABC opposite to the tetrahedron ABCP
c     itest_abcp   orientation of the tetrahedron ABCP
c     convex       set "true" if ABCP U ABCO is convex, else "false"
c     regular      set "true" if ABC is locally regular, in which
c                    case it does not matter if convex
c
c
      subroutine regular_convex (a,b,c,p,o,itest_abcp,regular,convex,
     &                              test_abpo,test_bcpo,test_capo)
      use iounit
      use shapes
      implicit none
      integer i,j,k,l,m
      integer p,a,b,c,o
      integer ia,ib,ic,id,ie
      integer ninf,infp,info
      integer iswap,iswap2,idx,val
      integer icol1,sign1,icol2,sign2
      integer icol4,sign4,icol5,sign5
      integer itest_abcp
      integer list(3)
      integer sign4_3(4)
      integer infpoint(4)
      integer inf4_1(4),sign4_1(4)
      integer inf5_3(4),sign5_3(4)
      integer inf4_2(4,4),sign4_2(4,4)
      integer inf5_2(4,4),sign5_2(4,4)
      integer order(2,3)
      integer order1(3,3)
      real*8 det_abpo,det_bcpo,det_capo
      real*8 det_abcpo,det_abpc
      real*8 a_p(4),b_p(4),c_p(4),o_p(0:4)
      real*8 i_p(0:3),j_p(0:3)
      real*8 mbo(3),mca(3),mjo(3),mio(0:3)
      real*8 coordp(3)
      logical convex,regular
      logical test_abpo,test_bcpo
      logical test_capo
      logical testc(3)
      data inf4_1  / 2, 2, 1, 1 /
      data sign4_1  / -1, 1, 1, -1 /
      data inf4_2  / 0, 2, 3, 3, 2, 0, 3, 3, 3, 3, 0, 1, 3, 3, 1, 0 /
      data sign4_2  / 0, 1, -1, 1, -1, 0, 1, -1,
     &                1, -1, 0, 1, -1, 1, -1, 0 /
      data sign4_3  / -1, 1, -1, 1 /
      data inf5_2  / 0, 2, 1, 1, 2, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0 /
      data sign5_2  / 0, -1, -1, 1, 1, 0, -1, 1,
     &                1, 1, 0, 1, -1, -1, -1, 0 /
      data inf5_3  / 1, 1, 3, 3 /
      data sign5_3  / 1, 1, -1, 1 /
      data order1  / 1, 2, 3, 3, 1, 2, 2, 3, 1 /
      data order  / 2, 3, 3, 1, 1, 2 /
      save
c
c
c     test if the union of the two tetrahedra is convex; check the
c     position of O with respect to the three faces ABP, BCP and CAP
c     of ABCP; to do that, we evaluate the three determinants:
c     det(ABPO), det(BCPO) and det(CAPO)
c
c     if the determinants are positive, and det(ABCP) is negative,
c     then the union is convex; also, if the three determinants are
c     negative, and det(ABCP) is positive, then the union is convex;
c     in all other cases, the union is non convex
c
c     the regularity is tested by computing det(ABCPO) 
c
c     count how many infinite points we have, except for O, note
c     only A, B and C can be infinite points
c
      regular = .true.
      convex  = .true.
      test_abpo = .false.
      test_bcpo = .false.
      test_capo = .false.
      list(1) = a
      list(2) = b
      list(3) = c
      infpoint(1) = 0
      infpoint(2) = 0
      infpoint(3) = 0
      if (a .le. 4)  infpoint(1) = 1
      if (b .le. 4)  infpoint(2) = 1
      if (c .le. 4)  infpoint(3) = 1
      ninf = infpoint(1) + infpoint(2) + infpoint(3)
      do m = 1, 3
         coordp(m) = crdball(3*p-3+m)
      end do
c
c     handle the general case with no infinite points; first is
c     when O is infinite, then det(ABCPO) = -det(ABCP) and thus 
c     ABCPO is regular, so there is nothing to do
c
      if (ninf .eq. 0) then
         if (o .le. 4) then
            regular = .true.
            return
         end if
c
c     determinants det(ABPO), det(BCPO), and det(CAPO) are "real"
c     4x4 determinants; first substract the row corresponding to
c     P from the other row, and develop with respect to P
c
c     the determinants become:
c
c     det(a,b,p,o) = - | ap(1) ap(2) ap(3) |
c                      | bp(1) bp(2) bp(3) |
c                      | op(1) op(2) op(3) |
c
c     det(b,c,p,o) = - | bp(1) bp(2) bp(3) |
c                      | cp(1) cp(2) cp(3) |
c                      | op(1) op(2) op(3) |
c
c     det(c,a,p,o) = - | cp(1) cp(2) cp(3) |
c                      | ap(1) ap(2) ap(3) |
c                      | op(1) op(2) op(3) |
c
c     where ip(j) = i(j)-p(j) for all i in {a,b,c,o} and j in {1,2,3}
c
c     compute two types of minors: mbo_ij = bp(i)op(j) - bp(j)op(i)
c     and mca_ij = cp(i)ap(j) - cp(j)op(i), store mbo_12 in mbo(3),
c     mbo_13 in mbo(2), and so on
c
         do m = 1, 3
            a_p(m) = crdball(3*a-3+m) - coordp(m)
            b_p(m) = crdball(3*b-3+m) - coordp(m)
            c_p(m) = crdball(3*c-3+m) - coordp(m)
            o_p(m) = crdball(3*o-3+m) - coordp(m)
         end do
         a_p(4) = wghtball(a) - wghtball(p)
         b_p(4) = wghtball(b) - wghtball(p)
         c_p(4) = wghtball(c) - wghtball(p)
         o_p(4) = wghtball(o) - wghtball(p)
         mbo(1) = b_p(2)*o_p(3) - b_p(3)*o_p(2)
         mbo(2) = b_p(1)*o_p(3) - b_p(3)*o_p(1)
         mbo(3) = b_p(1)*o_p(2) - b_p(2)*o_p(1)
         mca(1) = c_p(2)*a_p(3) - c_p(3)*a_p(2)
         mca(2) = c_p(1)*a_p(3) - c_p(3)*a_p(1)
         mca(3) = c_p(1)*a_p(2) - c_p(2)*a_p(1)
         det_abpo = -a_p(1)*mbo(1) + a_p(2)*mbo(2) - a_p(3)*mbo(3)
         det_bcpo = c_p(1)*mbo(1) - c_p(2)*mbo(2) + c_p(3)*mbo(3)
         det_capo = -o_p(1)*mca(1) + o_p(2)*mca(2) - o_p(3)*mca(3)
         det_abpc = -b_p(1)*mca(1) + b_p(2)*mca(2) - b_p(3)*mca(3)
c
c     now compute det(a,b,c,p,o) = | a(1) a(2) a(3) a(4) 1 |
c                                  | b(1) b(2) b(3) b(4) 1 |
c                                  | c(1) c(2) c(3) c(4) 1 |
c                                  | p(1) p(2) p(3) p(4) 1 |
c                                  | o(1) o(2) o(3) o(4) 1 |
c
c     which after substraction of row P gives:
c
c               det(a,b,c,p,o) = - | ap(1) ap(2) ap(3) ap(4) |
c                                  | bp(1) bp(2) bp(3) bp(4) |
c                                  | cp(1) cp(2) cp(3) cp(4) |
c                                  | op(1) op(2) op(3) op(4) |
c
c     then developing with respect to the last column yields:
c
         det_abcpo = -a_p(4)*det_bcpo - b_p(4)*det_capo 
     &                  - c_p(4)*det_abpo + o_p(4)*det_abpc
c
c     test if (ABCPO) is regular, in which case no flip is needed
c
         if (abs(det_abcpo) .lt. epsln5) then
            call valsort5 (a,b,c,p,o,ia,ib,ic,id,ie,iswap)
            call minor5 (crdball,radball,ia,ib,ic,id,ie,val)
            det_abcpo = val * iswap
         end if
         if (det_abcpo*itest_abcp .lt. 0.0d0) then
            regular = .true.
            return
         end if
         regular = .false.
c
c     if (ABCPO) is not regular, then test for convexity
c
         if (abs(det_abpo) .lt. epsln4) then
            call valsort4 (a,b,p,o,ia,ib,ic,id,iswap)
            call minor4 (crdball,ia,ib,ic,id,val)
            det_abpo = val * iswap
         end if
         if (abs(det_bcpo) .lt. epsln4) then
            call valsort4 (b,c,p,o,ia,ib,ic,id,iswap)
            call minor4 (crdball,ia,ib,ic,id,val)
            det_bcpo = val * iswap
         end if
         if (abs(det_capo) .lt. epsln4) then
            call valsort4 (c,a,p,o,ia,ib,ic,id,iswap)
            call minor4 (crdball,ia,ib,ic,id,val)
            det_capo = val * iswap
         end if
         test_abpo = (det_abpo .gt. 0.0d0)
         test_bcpo = (det_bcpo .gt. 0.0d0)
         test_capo = (det_capo .gt. 0.0d0)
         convex = .false.
         if (itest_abcp*det_abpo .gt. 0)  return
         if (itest_abcp*det_bcpo .gt. 0)  return
         if (itest_abcp*det_capo .gt. 0)  return
         convex = .true.
c
c     second case where one of A, B or C is infinite; define X
c     as the infinite point, and (i,j) the pair of finite points
c
c     if X=A then (i,j)=(b,c), or if X=B then (i,j)=(c,a), or
c     if X=C then (i,j)=(a,b)
c
c     define inf(a)=1 if A is infinite, or 0 otherwise, then
c     idx_X = 2-inf(a)+inf(c)
c
      else if (ninf .eq. 1) then
         idx = 2 -infpoint(1) + infpoint(3)
         infp = list(idx)
         i = list(order(1,idx))
         j = list(order(2,idx))
         do m = 1, 3
            i_p(m) = crdball(3*i-3+m) - coordp(m)
            j_p(m) = crdball(3*j-3+m) - coordp(m)
            o_p(m) = crdball(3*o-3+m) - coordp(m)
         end do
c
c     handle the case where O is finite
c
         if (o .gt. 4) then
            icol1 = inf4_1(infp)
            sign1 = sign4_1(infp)
c
c     the three 4x4 determinants become -det(i,p,o) [X missing],
c     det(j,p,o) [X missing], and det(i,j,p,o)
c
c     and the 5x5 determinant becomes -det(i,j,p,o)
c
            mjo(1) = j_p(1)*o_p(3) - j_p(3)*o_p(1)
            mjo(2) = j_p(2)*o_p(3) - j_p(3)*o_p(2)
            mjo(3) = j_p(1)*o_p(2) - j_p(2)*o_p(1)
c 
c     the correspondence between A,B,C and i,j is not essential
c     here use the correspondence for A infinite; in the two other
c     cases (B or C infinite), compute the same determinants, but
c     they are not in the same order
c
            det_abpo = i_p(icol1)*o_p(3) - i_p(3)*o_p(icol1)
            if (abs(det_abpo) .lt. epsln3) then
               call valsort3 (i,p,o,ia,ib,ic,iswap)
               call minor3 (crdball,ia,ib,ic,icol1,3,val)
               det_abpo = -val * iswap
            end if
            det_abpo = det_abpo * sign1
            det_capo = -mjo(icol1)
            if (abs(det_capo) .lt. epsln3) then
               call valsort3 (j,p,o,ia,ib,ic,iswap)
               call minor3 (crdball,ia,ib,ic,icol1,3,val)
               det_capo = val * iswap
            end if
            det_capo = det_capo * sign1
            det_bcpo = -i_p(1)*mjo(2) + i_p(2)*mjo(1) - i_p(3)*mjo(3)
            if (abs(det_bcpo) .lt. epsln3) then
               call valsort4 (i,j,p,o,ia,ib,ic,id,iswap)
               call minor4 (crdball,ia,ib,ic,id,val)
               det_bcpo = val * iswap
            end if
            det_abcpo = -det_bcpo
c
c     handle the case where O is infinite
c
c     the three 4x4 determinants become -det(i,p) [O,X missing],
c     det(j,p) [O,X missing], and det(i,j,p) [O missing]
c
c     and the 5x5 determinant becomes det(i,j,p) [O,X missing]
c
         else
            info = o
            icol1 = inf4_2(info,infp)
            sign1 = sign4_2(info,infp)
            icol2 = inf4_1(info)
            sign2 = sign4_1(info)
            icol5 = inf5_2(info,infp)
            sign5 = sign5_2(info,infp)
            det_abpo = -i_p(icol1) * sign1
            if (abs(det_abpo) .lt. epsln2) then
               call valsort2 (i,p,ia,ib,iswap)
               call minor2 (crdball,ia,ib,icol1,val)
               det_abpo = -val * iswap * sign1
            end if
            det_capo = j_p(icol1) * sign1
            if (abs(det_capo) .lt. epsln2) then
               call valsort2 (j,p,ia,ib,iswap)
               call minor2 (crdball,ia,ib,icol1,val)
               det_capo = val * iswap * sign1
            end if
            det_bcpo = i_p(icol2)*j_p(3) - i_p(3)*j_p(icol2)
            if (abs(det_bcpo) .lt. epsln3) then
               call valsort3 (i,j,p,ia,ib,ic,iswap)
               call minor3 (crdball,ia,ib,ic,icol2,3,val)
               det_bcpo = val * iswap
            end if
            det_bcpo = det_bcpo * sign2
            det_abcpo = i_p(icol5)*j_p(3) - i_p(3)*j_p(icol5)
            if (abs(det_abcpo) .lt. epsln3) then
               call valsort3 (i,j,p,ia,ib,ic,iswap)
               call minor3 (crdball,ia,ib,ic,icol5,3,val)
               det_abcpo = val * iswap
            end if
            det_abcpo = det_abcpo * sign5
         end if
c
c     test if (ABCPO) is regular, in which case no flip is needed
c
         if (det_abcpo*itest_abcp .lt. 0) then
            regular = .true.
            return
         end if
         regular = .false.
c
c     if (ABCPO) is not regular, then test for convexity
c
         testc(1) = (det_abpo .gt. 0.0d0)
         testc(2) = (det_bcpo .gt. 0.0d0)
         testc(3) = (det_capo .gt. 0.0d0)
         test_abpo = testc(order1(1,idx))
         test_bcpo = testc(order1(2,idx))
         test_capo = testc(order1(3,idx))
         convex = .false.
         if (itest_abcp*det_abpo .gt. 0)  return
         if (itest_abcp*det_bcpo .gt. 0)  return
         if (itest_abcp*det_capo .gt. 0)  return
         convex = .true.
c
c     third case where two points are infinite; define (k,l) as
c     the two infinite points, and i the point that is finite
c
c     if i=A then (k,l)=(b,c), or if i=B then (k,l)=(c,a), or
c     if i=C then (k,l)=(a,b); again i = 2+inf(a)-inf(c)
c
      else if (ninf .eq. 2) then
         idx = 2 + infpoint(1) - infpoint(3)
         i = list(idx)
         k = list(order(1,idx))
         l = list(order(2,idx))
         do m = 1, 3
            i_p(m) = crdball(3*i-3+m) - coordp(m)
            o_p(m) = crdball(3*o-3+m) - coordp(m)
         end do
c
c     handle the case where O is finite
c
c     the three 4x4 determinants become det(i,p,o) [k missing],
c     -det(i,p,o) [l missing], and S*det(p,o) [k,l missing,
c     with S=1 if k<l, -1 otherwise]
c
c     and the 5x5 determinant becomes S*det(i,p,o) [k,l missing,
c     with S=1 if k<l, -1 otherwise]
c
         if (o .gt. 4) then
            icol1 = inf4_1(k)
            sign1 = sign4_1(k)
            icol2 = inf4_1(l)
            sign2 = sign4_1(l)
            icol4 = inf4_2(k,l)
            sign4 = sign4_2(k,l)
            icol5 = inf5_2(k,l)
            sign5 = sign5_2(k,l)
            mio(1) = i_p(1)*o_p(3) - i_p(3)*o_p(1)
            mio(2) = i_p(2)*o_p(3) - i_p(3)*o_p(2)
            mio(3) = i_p(1)*o_p(2) - i_p(2)*o_p(1)
c 
c     the correspondence between A,B,C and i,j,k is not essential
c     here use the correspondence for A finite; in the two other
c     cases (B or C finite), compute the same determinants, but
c     they are not in the same order
c
            det_abpo = -mio(icol1) * sign1
            if (abs(det_abpo) .lt. epsln3) then
               call valsort3 (i,p,o,ia,ib,ic,iswap)
               call minor3 (crdball,ia,ib,ic,icol1,3,val)
               det_abpo = val * iswap * sign1
            end if
            det_capo = mio(icol2) * sign2
            if (abs(det_capo) .lt. epsln3) then
               call valsort3 (i,p,o,ia,ib,ic,iswap)
               call minor3 (crdball,ia,ib,ic,icol2,3,val)
               det_capo = -val * iswap * sign2
            end if
            det_bcpo = -o_p(icol4) * sign4
            if (abs(det_bcpo) .lt. epsln3) then
               call valsort2 (p,o,ia,ib,iswap)
               call minor2 (crdball,ia,ib,icol4,val)
               det_bcpo = val * sign4 * iswap
            end if
            det_abcpo = -mio(icol5) * sign5
            if (abs(det_abcpo) .lt. epsln3) then
               call valsort3 (i,p,o,ia,ib,ic,iswap)
               call minor3 (crdball,ia,ib,ic,icol5,3,val)
               det_abcpo = val * iswap * sign5
            end if
c
c     handle the case where O is infinite
c
c     the three 4x4 determinants become -det(i,p) [O,k missing],
c     -det(i,p) [O,l missing], and Const [O,k,l missing]
c
c     and the 5x5 determinant becomes Const*det(i,p) [O,k,l missing]
c
         else
            info = o
            icol1 = inf4_2(info,k)
            sign1 = sign4_2(info,k)
            icol2 = inf4_2(info,l)
            sign2 = sign4_2(info,l)
            call missinf_sign (info,k,l,icol4,iswap)
            det_abpo = i_p(icol1) * sign1
            if (abs(det_abpo) .lt. epsln2) then
               call valsort2 (i,p,ia,ib,iswap2)
               call minor2 (crdball,ia,ib,icol1,val)
               det_abpo = val * iswap2 * sign1
            end if
            det_capo = -i_p(icol2) * sign2
            if (abs(det_capo) .lt. epsln2) then
               call valsort2 (i,p,ia,ib,iswap2)
               call minor2 (crdball,ia,ib,icol2,val)
               det_capo = -val * iswap2 * sign2
            end if
            det_bcpo = sign4_3(icol4) * iswap
            det_abcpo = sign5_3(icol4) * iswap * i_p(inf5_3(icol4))
            if (abs(det_abcpo) .lt. epsln2) then
               call valsort2 (i,p,ia,ib,iswap2)
               call minor2 (crdball,ia,ib,inf5_3(icol4),val)
               det_abcpo = val * iswap2 * iswap * sign5_3(icol4)
            end if
         end if
c
c     test if (ABCPO) is regular, in which case no flip is needed
c
         if (det_abcpo*itest_abcp .lt. 0) then
            regular = .true.
            return
         end if
         regular = .false.
c
c     if (ABCPO) is not regular, then test for convexity
c
         testc(1) = (det_abpo .gt. 0.0d0)
         testc(2) = (det_bcpo .gt. 0.0d0)
         testc(3) = (det_capo .gt. 0.0d0)
         test_abpo = testc(order1(1,idx))
         test_bcpo = testc(order1(2,idx))
         test_capo = testc(order1(3,idx))
         convex = .false.
         if (itest_abcp*det_abpo .gt. 0)  return
         if (itest_abcp*det_bcpo .gt. 0)  return
         if (itest_abcp*det_capo .gt. 0)  return
         convex = .true.
c
c     cannot have all three points A, B and C infinite, as in
c     this case the facet ABC would be on the convex hull
c
      else if (ninf .eq. 3) then
         write (iout,10)
   10    format (/,' REGULAR_CONVEX  --  An Error has Occurred')
         call fatal
      end if
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine missinf_sign  --  missing infinite point index  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "missinf_sign" takes as input the indices of three infinite
c     points, then finds the index of the missing fourth infinite
c     point, and gives the signature of the permutation required
c     to put the three infinite points in order
c
c     variables and parameters:
c
c     i,j,k    three known infinite points
c     m        the "missing" infinite point
c     sign     signature of the permutation that orders i,j,k
c
c
      subroutine missinf_sign (i,j,k,m,sign)
      implicit none
      integer i,j,k,m
      integer sign
      integer a,b,c,d
      save
c
c
      m = 10 - i - j - k
      a = i
      b = j
      c = k
      sign = 1
      if (a .gt. b) then
         d = a
         a = b
         b = d
         sign = -sign
      end if
      if (a .gt. c) then
         d = a
         a = c
         c = d
         sign = -sign
      end if
      if (b .gt. c) then
         sign = -sign
      end if
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine valsort2  --  sort two integers & track flips  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "valsort2" sorts numbers A and B, where input values are
c     kept unaffected, and new output values are generated
c
c
      subroutine valsort2 (a,b,ia,ib,iswap)
      implicit none
      integer a,b
      integer ia,ib
      integer iswap
      save
c
c
      iswap = 1
      if (a .gt. b) then
         ia = b
         ib = a
         iswap = -iswap
      else
         ia = a
         ib = b
      end if
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine valsort3  --  sort three integers & track flips  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "valsort3" sorts numbers A, B and C, where input values
c     are kept unaffected, and new output values are generated
c
c
      subroutine valsort3 (a,b,c,ia,ib,ic,iswap)
      implicit none
      integer a,b,c
      integer ia,ib,ic
      integer iswap,temp
      save
c
c
      call valsort2 (a,b,ia,ib,iswap)
      ic = c
      if (ib .gt. ic) then
         temp = ib
         ib = ic
         ic = temp
         iswap = -iswap
         if (ia .gt. ib) then
            temp = ia
            ia = ib
            ib = temp
            iswap = -iswap
         end if
      end if
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine valsort4  --  sort four integers & track flips  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "valsort4" sorts numbers A, B, C and D, where input values
c     are kept unaffected, and new output values are generated
c
c
      subroutine valsort4 (a,b,c,d,ia,ib,ic,id,iswap)
      implicit none
      integer a,b,c,d
      integer ia,ib,ic,id
      integer iswap,temp
      save
c
c
      call valsort3 (a,b,c,ia,ib,ic,iswap)
      id = d
      if (ic .gt. id) then
         temp = ic
         ic = id
         id = temp
         iswap = -iswap
         if (ib .gt. ic) then
            temp = ib
            ib = ic
            ic = temp
            iswap = -iswap
            if (ia .gt. ib) then
               temp = ia
               ia = ib
               ib = temp
               iswap = -iswap
            end if
         end if
      end if
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine valsort5  --  sort five integers & track flips  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "valsort5" sorts numbers A, B, C, D and E, where input values
c     are kept unaffected, and new output values are generated
c
c
      subroutine valsort5 (a,b,c,d,e,ia,ib,ic,id,ie,iswap)
      implicit none
      integer a,b,c,d,e
      integer ia,ib,ic,id,ie
      integer iswap,temp
      save
c
c
      call valsort4 (a,b,c,d,ia,ib,ic,id,iswap)
      ie = e
      if (id .gt. ie) then
         temp = id
         id = ie
         ie = temp
         iswap = -iswap
         if (ic .gt. id) then
            temp = ic
            ic = id
            id = temp
            iswap = -iswap
            if (ib .gt. ic) then
               temp = ib
               ib = ic
               ic = temp
               iswap = -iswap
               if (ia .gt. ib) then
                  temp = ia
                  ia = ib
                  ib = temp
                  iswap = -iswap
               end if
            end if
         end if
      end if
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine flipjw  --  restore regularity to facet list  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "flipjw" goes over the linkfacet list to restore regularity
c     after a point has been inserted; when a linkfacet is found
c     nonregular and flippable, attempt to flip it; if the flip is
c     successful, new linkfacets are added to the queue; terminate
c     when the linkfacet list is empty
c
c
      subroutine flipjw (tetra_last)
      use iounit
      use shapes
      implicit none
      integer j
      integer a,b,c,o,p
      integer ierr,ifind
      integer itetra,jtetra
      integer tetra_ab,tetra_ac
      integer tetra_bc
      integer iorder,ival
      integer ireflex,iflip
      integer idx_p,idx_o,itest_abcp
      integer idx_a,idx_b,idx_c
      integer nkill_top
      integer nfreemax,ns
      integer tetra_last
      integer idxi,idxj,idxk,idxl
      integer ia,ib,ic,ii,ij
      integer facei(3),facej(3)
      integer edgei(2),edgej(2)
      integer edgek(2)
      integer edge_val(2,3)
      integer tetra_flip(3)
      integer list_flip(3)
      integer table32(3,3)
      integer table32_2(2,3)
      integer table41(3,3)
      integer table41_2(2,3)
      integer vert_flip(5)
      logical test,test_or(2,3),regular,convex
      logical test_abpo,test_abpc,test_capo,test_acpb
      logical test_bcpo,test_bcpa,test_acpo
      data table32  / 1, 2, 3, 1, 3, 2, 3, 1, 2 /
      data table32_2  / 1, 2, 1, 3, 2, 3 /
      data table41  / 2, 1, 3, 1, 2, 3, 1, 3, 2 /
      data table41_2  / 1, 1, 2, 1, 2, 2 /
      save
c
c
c     initialize some sizes related to free and kill space
c
      nfreemax = 10000
      nkill_top = nint(0.9d0*dble(nfreemax))
c
c     first perform a loop over all of the link facets
c
      j = 0
   10 continue
      if (j .eq. nlinkfacet)  goto 30
      if (nkill .ge. nkill_top) then
         nkill = nkill_top
c        ns = nfree
c        nfree = min(nfree+nkill,nkill_top)
c        do j = ns+1, nfree
c           freespace(j) = killspace(j-ns)
c        end do
c        nkill = 0
      end if
      j = j + 1
c
c     first define the two tetrahedra containing the link facet
c     as itetra and jtetra
c
      itetra = linkfacet(1,j)
      jtetra = linkfacet(2,j)
      idx_p = linkindex(1,j)
      idx_o = linkindex(2,j)
c
c     if the link facet is on the convex hull, then discard
c
      if (itetra.eq.0 .or. jtetra.eq.0)  goto 10
c
c     if tetrahedra are already discarded, discard this link facet
c
      if (.not.btest(tinfo(itetra),1)) then
         if (.not.btest(tinfo(jtetra),1)) then
            goto 10
         else
            itetra = tneighbor(idx_o,jtetra)
            ival = ibits(tnindex(itetra),2*(idx_o-1),2)
            idx_p = ival + 1
         end if
      end if
      if (.not.btest(tinfo(jtetra),1)) then
         jtetra = tneighbor(idx_p,itetra)
         ival = ibits(tnindex(itetra),2*(idx_o-1),2)
         idx_o = ival + 1
      end if
c
c     define the vertices of the two tetrahedra with itetra as ABCP
c     and jtetra as ABCO
c
      a = tetra(1,itetra)
      b = tetra(2,itetra)
      c = tetra(3,itetra)
      p = tetra(4,itetra)
      o = tetra(idx_o,jtetra)
      itest_abcp = -1
      if (btest(tinfo(itetra),0))  itest_abcp = 1
c
c     check for local regularity (and for convexity, at very
c     little extra cost)
c
      call regular_convex (a,b,c,p,o,itest_abcp,regular,convex,
     &                     test_abpo,test_bcpo,test_capo)
c
c     if the link facet is locally regular, then discard
c
      if (regular)  goto 10
c
c     define neighbors of the facet on itetra and jtetra
c
      call define_facet (itetra,jtetra,idx_o,facei,facej)
      test_abpc = (itest_abcp .ne. 1)
c
c     after discarding the trivial case, test if the tetrahedra
c     can be flipped
c
c     at this stage, the link facet is not locally regular, but
c     it is unknown if it is "flippable"
c
c     check if {itetra} U {jtetra} is convex; if it is, perform
c     a 2-3 flip (this is the convexity test performed at the
c     same time as the regularity test)
c
      if (convex) then
         vert_flip(1) = a
         vert_flip(2) = b
         vert_flip(3) = c
         vert_flip(4) = p
         vert_flip(5) = o
         call flipjw_2_3 (itetra,jtetra,vert_flip,facei,facej,
     &                    test_abpo,test_bcpo,test_capo,ierr,
     &                    tetra_last)
         goto 10
      end if
c
c     the union of the two tetrahedra is not convex; check edges of
c     the triangle in the link facet to see if they are "reflexes"
c     (see Edelsbrunner and Shah, Algorithmica 15, 223-241, 1996)
c
      ireflex = 0
      iflip = 0
c
c     check edge AB; it is reflex if and only if O and C lie on
c     opposite sides of the hyperplane defined by ABP; test the
c     orientation of ABPO and ABPC, and if they differ AB is reflex
c
c     if AB is reflex, we test if it is of degree three, i.e., if it
c     is shared by three tetrahedra, namely ABCP, ABCO and ABPO; the
c     first two are itetra and jtetra, so we only need to check if
c     ABPO exists
c
c     since ABPO contains P, ABP should then be a link facet of P,
c     so test all tetrahedra that define link facets
c
      if (test_abpo .neqv. test_abpc) then
         ireflex = ireflex + 1
         call find_tetra (itetra,3,a,b,o,ifind,tetra_ab,idx_a,idx_b)
         if (ifind .eq. 1) then
            iflip = iflip + 1
            tetra_flip(iflip) = tetra_ab
            list_flip(iflip) = 1
            edge_val(1,iflip) = idx_a
            edge_val(2,iflip) = idx_b
            test_or(1,iflip) = test_bcpo
            test_or(2,iflip) = (.not. test_capo)
         end if
      end if
c
c     check edge AC; it is reflex if and only if O and B lie on
c     opposite sides of the hyperplane defined by ACP; test the
c     orientation of ACPO and ACPB, and if they differ AC is reflex
c
c     if AC is reflex, we test if it is of degree three, i.e., if it
c     is shared by three tetrahedra, namely ABCP, ABCO and ACPO; the
c     first two are itetra and jtetra, so we only need to check if
c     ACPO exists
c
c     since ACPO contains P, ACP should then be a link facet of P,
c     so test all tetrahedra that define link facets
c
      test_acpo = (.not. test_capo)
      test_acpb = (.not. test_abpc)
      if (test_acpo .neqv. test_acpb) then
         ireflex = ireflex + 1
         call find_tetra (itetra,2,a,c,o,ifind,tetra_ac,idx_a,idx_c)
         if (ifind .eq. 1) then
            iflip = iflip + 1
            tetra_flip(iflip) = tetra_ac
            list_flip(iflip) = 2
            edge_val(1,iflip) = idx_a
            edge_val(2,iflip) = idx_c
            test_or(1,iflip) = (.not. test_bcpo)
            test_or(2,iflip) = test_abpo
         end if
      end if
c
c     check edge BC; it is reflex if and only if O and A lie on
c     opposite sides of the hyperplane defined by BCP; test the
c     orientation of BCPO and BCPA, and if they differ BC is reflex
c
c     if BC is reflex, we test if it is of degree three, i.e., if it
c     is shared by three tetrahedra, namely ABCP, ABCO and BCPO; the
c     first two are itetra and jtetra, so we only need to check if
c     BCPO exists
c
c     since BCPO contains P, BCP should then be a link facet of P,
c     so test all tetrahedra that define link facets
c
      test_bcpa = test_abpc
      if (test_bcpo .neqv. test_bcpa) then
         ireflex = ireflex + 1
         call find_tetra (itetra,1,b,c,o,ifind,tetra_bc,idx_b,idx_c)
         if (ifind .eq. 1) then
            iflip = iflip + 1
            tetra_flip(iflip) = tetra_bc
            list_flip(iflip) = 3
            edge_val(1,iflip) = idx_b
            edge_val(2,iflip) = idx_c
            test_or(1,iflip) = test_capo
            test_or(2,iflip) = (.not. test_abpo)
         end if
      end if
      if (ireflex .ne. iflip)  goto 10
c
c     if only one edge is flippable, so perform a 3-2 flip
c
      if (iflip .eq. 1) then
         iorder = list_flip(iflip)
         ia = table32(1,iorder)
         ib = table32(2,iorder)
         ic = table32(3,iorder)
         vert_flip(ia) = a
         vert_flip(ib) = b
         vert_flip(ic) = c
         vert_flip(4) = p
         vert_flip(5) = o
         ia = table32_2(1,iorder)
         ib = table32_2(2,iorder)
         edgei(1) = ia
         edgei(2) = ib
         edgej(1) = facej(ia)
         edgej(2) = facej(ib)
         edgek(1) = edge_val(1,iflip)
         edgek(2) = edge_val(2,iflip)
         call flipjw_3_2 (itetra,jtetra,tetra_flip(1),vert_flip,
     &                    edgei,edgej,edgek,test_or(1,iflip),
     &                    test_or(2,iflip),ierr,tetra_last)
c
c     in this case, one point is redundant, the point common to
c     the two edges that can be flipped, so perform a 4-1 flip
c
      else if (iflip .eq. 2) then
         iorder = list_flip(1) + list_flip(2) - 2
         vert_flip(table41(1,iorder)) = a
         vert_flip(table41(2,iorder)) = b
         vert_flip(table41(3,iorder)) = c
         vert_flip(4) = p
         vert_flip(5) = o
         ii = table41_2(1,iorder)
         ij = table41_2(2,iorder)
         idxi = iorder
         idxj = facej(iorder)
         idxk = edge_val(ii,1)
         idxl = edge_val(ij,2)
         if (iorder .eq. 1) then
            test = test_bcpo
         else if (iorder .eq. 2) then
            test = (.not. test_capo)
         else
            test = test_abpo
         end if
         call flipjw_4_1 (itetra,jtetra,tetra_flip(1),tetra_flip(2),
     &                    vert_flip,idxi,idxj,idxk,idxl,test,ierr,
     &                    tetra_last)
c
c     note that the following case should never occur
c
      else
         write (iout,20)
   20    format (/,' FLIPJW  --  Three Flippable Edges',
     &              ' Should Not Occur')
         call fatal
      end if
      goto 10
c
c     add all of the "killed" tetrahedra into the free zone
c
   30 continue
      ns = nfree
      nfree = min(ns+nkill,nfreemax)
      do j = ns+1, nfree
         freespace(j) = killspace(j-ns)
      end do
      nkill = 0
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine flipjw_1_4  --  1->4 flip for triangulation  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "flipjw_1_4" performs a 1->4 flip for regular triangulation
c     where a 1->4 flip is a transformation in which a tetrahedron
c     and a single vertex included in the tetrahedron are transformed
c     to four tetrahedra defined from the four faces of the initial
c     tetrahedron, connected to the new point, each of the faces is
c     then called a "linkfacet" and is stored on a queue
c
c     variables and parameters:
c
c     ipoint      index of the point P to be included
c     itetra      index of the tetrahedra considered (ABCD)
c
c
      subroutine flipjw_1_4 (ipoint,itetra,tetra_last)
      use shapes
      implicit none
      integer i,j,k
      integer ipoint
      integer newtetra
      integer ival,ikeep
      integer itetra,jtetra
      integer fact,idx
      integer tetra_last
      integer vertex(4)
      integer nindex(4)
      integer neighbor(4)
      integer position(4)
      integer idx_list(3,4)
      data idx_list  / 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3 /
      save
c
c
c     store information about the old tetrahedron
c
      ikeep = tinfo(itetra)
      do i = 1, 4
         vertex(i) = tetra(i,itetra)
         neighbor(i) = tneighbor(i,itetra)
         ival = ibits(tnindex(itetra),2*(i-1),2)
         nindex(i) = ival + 1
      end do
      fact = -1
      if (btest(tinfo(itetra),0))  fact = 1
c
c     the four new tetrahedra are stored in free space in the
c     tetrahedron list and at the end of the known tetrahedra list
c
      k = 0
      do i = nfree, max(nfree-3,1), -1
         k = k + 1
         position(k) = freespace(i)
      end do
      nfree = max(nfree-4,0)
      do i = k+1, 4
         ntetra = ntetra + 1
         position(i) = ntetra
      end do
      tetra_last = position(4)
c
c     "itetra" is set to 0, and added to the kill list
c
      tinfo(itetra) = ibclr(tinfo(itetra),1)
      nkill = 1
      killspace(nkill) = itetra
c
c     the tetrahedron is defined as (IJKL), then four new tetrahedra
c     are created: JKLP, IKLP, IJLP, and IJKP, where P is the new
c     point to be included
c
c     for each new tetrahedron define all four neighbors, for
c     each neighbor store the index of the vertex opposite to 
c     the common face in "tnindex"
c
c     for JKLP, the neighbors are IKLP, IJLP, IJKP and neighbor
c        of IJKL on face JKL
c     for IKLP, the neighbors are JKLP, IJLP, IJKP and neighbor
c        of IJKL on face IKL
c     for IJLP, the neighbors are JKLP, IKLP, IJKP and neighbor
c        of IJKL on face IJL
c     for IJKP, the neighbors are JKLP, IKLP, IJLP and neighbor
c        of IJKL on face IJK
c
      do i = 1, 4
         newtetra = position(i)
         nnew = nnew + 1
         newlist(nnew) = newtetra
         tinfo(newtetra) = 0
         tnindex(newtetra) = 0
         k = 0
         do j = 1, 4
            if (j .ne. i) then
               k = k + 1
               tetra(k,newtetra) = vertex(j)
               tneighbor(k,newtetra) = position(j)
               ival = idx_list(k,i) - 1
               call mvbits (ival,0,2,tnindex(newtetra),2*(k-1))
            end if
         end do
         jtetra = neighbor(i)
         idx = nindex(i)
         tetra(4,newtetra) = ipoint
         tneighbor(4,newtetra) = jtetra
         ival = idx - 1
         call mvbits (ival,0,2,tnindex(newtetra),6)
         call mvbits (ikeep,2+i,1,tinfo(newtetra),2+i)
         if (jtetra.ne.0 .and. idx.ne.0) then
            tneighbor(idx,jtetra) = newtetra
            ival = 3
            call mvbits (ival,0,2,tnindex(jtetra),2*(idx-1))
         end if
         tinfo(newtetra) = ibset(tinfo(newtetra),1)
c
c     store the tetrahedron orientation, (jklp) and (ijlp) are
c     clockwise, while (iklp) and (ijkp) are counter-clockwise 
c
         fact = -fact
         if (fact .eq. 1)  tinfo(newtetra) =
     &                        ibset(tinfo(newtetra),0)
      end do
c
c     add all four faces of new tetraheda in the linkfacet queue,
c     each linkfacet is a triangle implicitly defined as intersection
c     of two tetrahedra
c
c     for facet JKL, tetrahedra are JKLP and neighbor of IJKL on JKL
c     for facet IKL, tetrahedra are IKLP and neighbor of IJKL on IKL
c     for facet IJL, tetrahedra are IJLP and neighbor of IJKL on IJL
c     for facet IJK, tetrahedra are IJKP and neighbor of IJKL on IJK
c
      nlinkfacet = 0
      do i = 1, 4
         newtetra = position(i)
         nlinkfacet = nlinkfacet + 1
         linkfacet(1,nlinkfacet) = newtetra
         linkfacet(2,nlinkfacet) = tneighbor(4,newtetra)
         linkindex(1,nlinkfacet) = 4
         ival = ibits(tnindex(newtetra),6,2)
         linkindex(2,nlinkfacet) = ival + 1
      end do
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine define_facet  --  facet between two tetrahedra  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "define_facet" a triangle or facet is defined by intersection
c     of two tetrahedra; knowing the position of its three vertices
c     in the first tetrahedron, find the indices of these vertices
c     in the second tetrahedron; also stores information about the
c     neighbors of the two tetrahedra considered
c
c     note the vertices are called A, B, C, P and O, where (ABC) is
c     the common facet
c
c     variables and parameters:
c
c     itetra    index of the tetrahedra (a,b,c,p) considered
c     jtetra    index of the tetrahedra (a,b,c,o) considered
c     idx_o     position of o in the vertices of jtetra
c     itouch    itouch(i) is the tetrahedron sharing
c                 the face opposite to i in tetrahedron itetra
c     idx       idx(i) is the vertex of itouch(i) opposite
c                 to the face shared with itetra
c     jtouch    jtouch(i) is the tetrahedron sharing
c                 the face opposite to i in tetrahedron jtetra
c     jdx       jdx(i) is the vertex of jtouch(i) opposite
c                 to the face shared with jtetra
c
c
      subroutine define_facet (itetra,jtetra,idx_o,facei,facej)
      use shapes
      implicit none
      integer i,k,idx_o
      integer ia,ib,ie,if
      integer itetra,jtetra
      integer other(3,4)
      integer other2(2,4,4)
      integer facei(3)
      integer facej(3)
      data other   / 2, 3, 4, 1, 3, 4, 1, 2, 4, 1, 2, 3 /
      data other2  / 0, 0, 3, 4, 2, 4, 2, 3, 3, 4, 0, 0,
     &               1, 4, 1, 3, 2, 4, 1, 4, 0, 0, 1, 2,
     &               2, 3, 1, 3, 1, 2, 0, 0 /
      save
c
c
c     find the three vertices that define the common face and
c     store in the array triangle, then find vertices P and O
c
      do i = 1, 3
         facei(i) = i
      end do
      ia = tetra(1,itetra)
      do i = 1, 3
         k = other(i,idx_o)
         ie = tetra(k,jtetra)
         if (ia .eq. ie) then
            facej(1) = k
            goto 10
         end if
      end do
   10 continue
      ib = tetra(2,itetra)
      ie = other2(1,facej(1),idx_o)
      if = other2(2,facej(1),idx_o)
      if (ib .eq. tetra(ie,jtetra)) then
         facej(2) = ie
         facej(3) = if
      else
         facej(2) = if
         facej(3) = ie
      end if
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine find_tetra  --  tests for existing tetrahedron  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "find_tetra" tests if four given points form an existing
c     tetrahedron in the current Delaunay
c
c     variables and parameters:
c
c     itetra      index of tetrahedron ABCP
c     idx_c       index of C in tetrahedron ABCP
c     o           index of the vertex O
c     ifind       set to 1 if tetrahedron exists, 0 otherwise
c     tetra_loc   index of existing tetrahedron, if it exists
c
c     first test if tetrahedron ABPO exists, if it exists it is a
c     neighbor of ABCP, on the face opposite to vertex C, then test
c     that tetrahedron and see if it contains O
c
c
      subroutine find_tetra (itetra,idx_c,a,b,o,ifind,
     &                       tetra_loc,idx_a,idx_b)
      use shapes
      implicit none
      integer i,ifind,ival
      integer itetra,tetra_loc
      integer ot,otx,otest
      integer idx_c,idx_a,idx_b
      integer o,a,b
      save
c
c
      ot = tneighbor(idx_c,itetra)
      ival = ibits(tnindex(itetra),2*(idx_c-1),2)
      otx = ival + 1
      otest = tetra(otx,ot)
c
c     locate the tetrahedron, then find the position of A and B
c
      if (otest .eq. o) then
         ifind = 1
         tetra_loc = ot
         do i = 1, 4
            if (tetra(i,tetra_loc) .eq. a) then
               idx_a = i
            else if (tetra(i,tetra_loc) .eq. b) then
               idx_b = i
            end if
         end do
      else
         ifind = 0
      end if
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine flipjw_2_3  --  2->3 flip for triangulation  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "flipjw_2_3" implements a 2->3 flip for regular triangulation
c
c     the 2->3 flip is a transformation in which two tetrahedra are
c     flipped into three tetrahedra. The two tetrahedra ABCP and
c     ABCO share a triangle ABC which is in the linkfacet of the
c     current point P added to the triangulation
c
c     this flip is only possible if the union of the two tetrahedra
c     is convex, and if their shared triangle is not locally regular
c
c     assume that these tests have been performed and satisfied,
c     once the flip has been performed three tetrahedra are added
c     and three new link facets are added to the link facet queue
c
c     variables and parameters:
c
c     itetra       index of the tetrahedra (a,b,c,p) considered
c     jtetra       index of the tetrahedra (a,b,c,o) considered
c     vertices     the five vertices a,b,c,o,p
c     facei        indices of the vertices a,b,c in (a,b,c,p)
c     facej        indices of the vertices a,b,c in (a,b,c,o)
c     test_abpo    orientation of the four points a,b,p,o
c     test_bcpo    orientation of the four points b,c,p,o
c     test_capo    orientation of the four points c,a,p,o
c     nlinkfacet   three new link facets are added
c     linkfacet    the three faces of the initial tetrahedron
c                    (a,b,c,o) containing the vertex o are added
c                    as link facets
c     linkindex    linkfacet is a triangle defined from its
c                    two neighboring tetrahedra; store the position
c                    of the vertex opposite to the triangle in each
c                    tetrehedron in the array linkindex
c     ierr         set to 1 if flip was not possible
c
c
      subroutine flipjw_2_3 (itetra,jtetra,vertices,facei,facej,
     &                       test_abpo,test_bcpo,test_capo,ierr,
     &                       tetra_last)
      use shapes
      implicit none
      integer i,j,k,o,p
      integer ierr
      integer itetra,jtetra
      integer it,jt,idx,jdx
      integer ival,ikeep,jkeep
      integer newtetra
      integer tetra_last
      integer jtetra_touch(3)
      integer itetra_touch(3)
      integer jtetra_idx(3)
      integer itetra_idx(3)
      integer idx_list(2,3)
      integer face(3),vertices(5)
      integer facei(3),facej(3)
      integer tests(3),position(3)
      logical test_abpo,test_bcpo,test_capo
      data idx_list  / 1, 1, 1, 2, 2, 2 /
      save
c
c
c     if itetra or jtetra are inactive, then cannot flip
c
      ierr = 0
      if (.not.btest(tinfo(itetra),1) .or. 
     &    .not.btest(tinfo(jtetra),1)) then
         ierr = 1
         return
      end if
c
c     itetra_touch   the three tetrahedra that touches itetra on
c                      the faces opposite to the 3 vertices a,b,c
c     itetra_idx     for the three tetrahedra defined by itetra_touch,
c                      index of the vertex opposite to the face
c                      common with itetra
c     jtetra_touch   the three tetrahedra that touches jtetra on the
c                      faces opposite to the 3 vertices a,b,c
c     jtetra_idx     for the three tetrahedra defined by jtetra_touch,
c                      index of the vertex opposite to the face
c                      common with jtetra
c
      do i = 1, 3
         itetra_touch(i) = tneighbor(facei(i),itetra)
         ival = ibits(tnindex(itetra),2*(facei(i)-1),2)
         itetra_idx(i) = ival + 1
         jtetra_touch(i) = tneighbor(facej(i),jtetra)
         ival = ibits(tnindex(jtetra),2*(facej(i)-1),2)
         jtetra_idx(i) = ival + 1
      end do
c
c     first three vertices define triangle that is removed
c
      face(1) = vertices(1)
      face(2) = vertices(2)
      face(3) = vertices(3)
      p = vertices(4)
      o = vertices(5)
c
c     three tetrahedra are stored in free space in the tetrahedron
c     list and at the end of the list of known tetrahedra if needed
c
      k = 0
      do i = nfree, max(nfree-2,1), -1
         k = k + 1
         position(k) = freespace(i)
      end do
      nfree = max(nfree-3,0)
      do i = k+1, 3
         ntetra = ntetra + 1
         position(i) = ntetra
      end do
      tetra_last = position(3)
c
c     set itetra and jtetra to 0, and add them to kill list
c
      ikeep = tinfo(itetra)
      jkeep = tinfo(jtetra)
      tinfo(itetra) = ibclr(tinfo(itetra),1)
      tinfo(jtetra) = ibclr(tinfo(jtetra),1)
      killspace(nkill+1) = itetra
      killspace(nkill+2) = jtetra
      nkill = nkill + 2
c
c     the vertices A, B and C are the first vertices of itetra,
c        and the other two vertices P and O
c     for each vertex in the triangle, define the opposing faces
c        in the two tetrahedra itetra and jtetra, and tetrahedra
c        that share faces with itetra and jtetra, respectively,
c     this information is stored in itetra_touch and jtetra_touch
c
c     for bookkeeping reasons, always store P as the last vertex
c
c     define the three new tetrahedra BCOP, ACOP and ABOP as well
c     as their neighbors
c
c     for BCOP, the neighbors are ACOP, ABOP, neighbor of ABCP on
c        on face BCP, and neighbor of ABCO on face BCO
c     for ACOP, the neighbors are BCOP, ABOP, neighbor of ABCP on
c        on face ACP, and neighbor of ABCO on face ACO
c     for ABOP, the neighbors are BCOP, ACOP, neighbor of ABCP on
c        on face ABP, and neighbor of ABCO on face ABO
c
      tests(1) = 1
      if (test_bcpo)  tests(1) = -1
      tests(2) = -1
      if (test_capo)  tests(2) = 1
      tests(3) = 1
      if (test_abpo)  tests(3) = -1
      do i = 1, 3
         newtetra = position(i)
         nnew = nnew + 1
         newlist(nnew) = newtetra
         tinfo(newtetra) = 0
         tnindex(newtetra) = 0
         k = 0
         do j = 1, 3
            if (j .ne. i) then
               k = k + 1
               tetra(k,newtetra) = face(j)
               tneighbor(k,newtetra) = position(j)
               ival = idx_list(k,i) - 1
               call mvbits (ival,0,2,tnindex(newtetra),2*(k-1))
            end if
         end do
         tetra(3,newtetra) = o
         it = itetra_touch(i)
         idx = itetra_idx(i)
         tneighbor(3,newtetra) = it
         ival = idx - 1
         call mvbits (ival,0,2,tnindex(newtetra),4)
         call mvbits (ikeep,2+facei(i),1,tinfo(newtetra),5)
         if (idx.ne.0 .and. it.ne.0) then
            tneighbor(idx,it) = newtetra
            ival = 2
            call mvbits (ival,0,2,tnindex(it),2*(idx-1))
         end if
         tetra(4,newtetra) = p
         jt = jtetra_touch(i)
         jdx = jtetra_idx(i)
         tneighbor(4,newtetra) = jt
         ival = jdx - 1
         call mvbits (ival,0,2,tnindex(newtetra),6)
         call mvbits (jkeep,2+facej(i),1,tinfo(newtetra),6)
         if (jdx.ne.0 .and. jt.ne.0) then
            tneighbor(jdx,jt) = newtetra
            ival = 3
            call mvbits (ival,0,2,tnindex(jt),2*(jdx-1))
         end if
         tinfo(newtetra) = ibset(tinfo(newtetra),1)
         if (tests(i) .eq. 1) then
            tinfo(newtetra) = ibset(tinfo(newtetra),0)
         end if
      end do
c
c     add all three faces of jtetra containing O in the linkfacet
c     queue, each linkfacet is a triangle implicitly defined as the 
c     intersection of two tetrahedra
c
c     for facet BCO, tetrahedra are BCOP and neighbor of ABCO on BCO
c     for facet ACO, tetrahedra are ACOP and neighbor of ABCO on ACO
c     for facet ABO, tetrahedra are ABOP and neighbor of ABCO on ABO
c
      do i = 1, 3
         newtetra = position(i)
         nlinkfacet = nlinkfacet + 1
         linkfacet(1,nlinkfacet) = newtetra
         linkfacet(2,nlinkfacet) = tneighbor(4,newtetra)
         linkindex(1,nlinkfacet) = 4
         ival = ibits(tnindex(newtetra),6,2)
         linkindex(2,nlinkfacet) = ival + 1
      end do
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine flipjw_3_2  --  3->2 flip for triangulation  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "flipjw_3_2" implements a 3->2 flip for regular triangulation
c
c     the 3->2 flip is a transformation in which three tetrahedra are
c     flipped into two tetrahedra, the three tetrahedra ABPO, ABCP and
c     ABCO share an edge AB which is in the linkfacet of the current
c     point P added to the triangulation
c
c     this flip is only possible if the edge AB is reflex, with degree
c     three, assume these tests have been performed and satisfied, 
c     once the flip has been performed, two new tetrahedra are added
c     and two new "link facet" are added to the link facet queue
c
c     variables and parameters:
c
c     itetra       index of the tetrahedron ABCP considered
c     jtetra       index of the tetrahedron ABCO considered
c     ktetra       index of the tetrahedron ABOP considered
c     vertices     the five vertices A, B, C, P and O
c     edgei        indices of AB in ABCP
c     edgej        indices of AB in ABCO
c     edgek        indices of AB in ABOP
c     test_bcpo    orientation of the four points BCPO
c     test_acpo    orientation of the four points ACPO
c     nlinkfacet   two new link facets are added
c     linkfacet    the two faces of the initial tetrahedron
c                    ABOP containing the edge op are added
c                    as link facets
c     linkindex    linkfacet is a triangle defined from its two
c                    neighboring tetrahedra, store the position
c                    of the vertex opposite to the triangle in each
c                    tetrehedron in the array linkindex
c     ierr         set to 1 if flip was not possible
c
c
      subroutine flipjw_3_2 (itetra,jtetra,ktetra,vertices,edgei,
     &                       edgej,edgek,test_bcpo,test_acpo,ierr,
     &                       tetra_last)
      use shapes
      implicit none
      integer i,j,k,c,o,p
      integer ierr,ival
      integer ikeep,jkeep,kkeep
      integer itetra,jtetra,ktetra
      integer it,jt,kt,idx,jdx,kdx
      integer newtetra
      integer tetra_last
      integer edge(2),tests(2)
      integer vertices(5)
      integer itetra_touch(2)
      integer jtetra_touch(2)
      integer ktetra_touch(2)
      integer itetra_idx(2)
      integer jtetra_idx(2)
      integer ktetra_idx(2)
      integer position(2)
      integer edgei(2),edgej(2)
      integer edgek(2)
      logical test_bcpo,test_acpo
      save
c
c
      tests(1) = 1
      if (test_bcpo)  tests(1) = -1
      tests(2) = 1
      if (test_acpo)  tests(2) = -1
      ierr = 0
c
c     if itetra, jtetra or ktetra are inactive, cannot flip
c
      if (.not.btest(tinfo(itetra),1) .or.
     &    .not.btest(tinfo(jtetra),1) .or.
     &    .not.btest(tinfo(ktetra),1)) then
         ierr = 1
         return
      end if
c
c     store the old information
c
      ikeep = tinfo(itetra)
      jkeep = tinfo(jtetra)
      kkeep = tinfo(ktetra)
c
c     itetra_touch   indices of the two tetrahedra that share the
c                      faces opposite to A and B in itetra
c     itetra_idx     for the two tetrahedra defined by itetra_touch,
c                      index position of vertex opposite the face
c                      common with itetra
c     jtetra_touch   indices of the two tetrahedra that share the
c                      faces opposite to a and b in jtetra
c     jtetra_idx     for the two tetrahedra defined by jtetra_touch,
c                      index position of vertex opposite the face
c                      common with jtetra
c     ktetra_touch   indices of the two tetrahedra that share the
c                      faces opposite to a and b in ktetra
c     ktetra_idx     for the two tetrahedra defined by ktetra_touch,
c                      index position of vertex opposite the face
c                      common with ktetra
c
      do i = 1, 2
         itetra_touch(i) = tneighbor(edgei(i),itetra)
         jtetra_touch(i) = tneighbor(edgej(i),jtetra)
         ktetra_touch(i) = tneighbor(edgek(i),ktetra)
         ival = ibits(tnindex(itetra),2*(edgei(i)-1),2)
         itetra_idx(i) = ival + 1
         ival = ibits(tnindex(jtetra),2*(edgej(i)-1),2)
         jtetra_idx(i) = ival + 1
         ival = ibits(tnindex(ktetra),2*(edgek(i)-1),2)
         ktetra_idx(i) = ival + 1
      end do
      edge(1) = vertices(1)
      edge(2) = vertices(2)
      c = vertices(3)
      p = vertices(4)
      o = vertices(5)
c
c     store the new tetrahedra in "free" space or at the list end
c
      k = 0
      do i = nfree, max(nfree-1,1), -1
         k = k + 1
         position(k) = freespace(i)
      end do
      nfree = max(nfree-2,0)
      do i = k+1, 2
         ntetra = ntetra + 1
         position(i) = ntetra
      end do
      tetra_last = position(2)
c
c     itetra, jtetra and ktetra become available and are added
c     to the kill list
c
      tinfo(itetra) = ibclr(tinfo(itetra),1)
      tinfo(jtetra) = ibclr(tinfo(jtetra),1)
      tinfo(ktetra) = ibclr(tinfo(ktetra),1)
      killspace(nkill+1) = itetra
      killspace(nkill+2) = jtetra
      killspace(nkill+3) = ktetra
      nkill = nkill + 3
c
c     the two vertices that define their common edge AB are
c        stored in the array edge
c     the vertices C, P and O form the new triangle
c     for each vertex in the edge AB, define the opposing faces
c        in the tetrahedra itetra, jtetra and ktetra, and the
c        tetrahedron that share these faces with itetra, jtetra
c        and ktetra, respectively
c     this info is stored in itetra_touch, jtetra_touch and
c        ktetra_touch
c
c     always set P to be the last vertex of the new tetrahedra
c
c     define new tetrahedra BCOP and ACOP as well as their neighbors
c
c     for BCOP, the neighbors are ACOP, neighbor of ABOP on face
c        BPO, neighbor of ABCP on face BCP, and neighbor of ABCO
c        on face BCO
c     for ACOP, the neighbors are BCOP, neighbor of ABOP on face
c        APO, neighbor of ABCP on face ACP, and neighbor of ABCO
c        on face ACO
c
      do i = 1, 2
         newtetra = position(i)
         nnew = nnew + 1
         newlist(nnew) = newtetra
         tinfo(newtetra) = 0
         tnindex(newtetra) = 0
         k = 0
         do j = 1, 2
            if (j .ne. i) then
               k = k + 1
               tetra(k,newtetra) = edge(j)
               tneighbor(k,newtetra) = position(j)
            end if
         end do
         tetra(2,newtetra) = c
         kt = ktetra_touch(i)
         kdx = ktetra_idx(i)
         tneighbor(2,newtetra) = kt
         ival = kdx - 1
         call mvbits (ival,0,2,tnindex(newtetra),2)
         call mvbits (kkeep,2+edgek(i),1,tinfo(newtetra),4)
         if (kdx.ne.0 .and. kt.ne.0) then
            tneighbor(kdx,kt) = newtetra
            ival = 1
            call mvbits (ival,0,2,tnindex(kt),2*(kdx-1))
         end if
         tetra(3,newtetra) = o
         it = itetra_touch(i)
         idx = itetra_idx(i)
         tneighbor(3,newtetra) = it
         ival = idx - 1
         call mvbits (ival,0,2,tnindex(newtetra),4)
         call mvbits (ikeep,2+edgei(i),1,tinfo(newtetra),5)
         if (idx.ne.0 .and. it.ne.0) then
            tneighbor(idx,it) = newtetra
            ival = 2
            call mvbits (ival,0,2,tnindex(it),2*(idx-1))
         end if
         tetra(4,newtetra) = p
         jt = jtetra_touch(i)
         jdx = jtetra_idx(i)
         tneighbor(4,newtetra) = jt
         ival = jdx - 1
         call mvbits (ival,0,2,tnindex(newtetra),6)
         call mvbits (jkeep,2+edgej(i),1,tinfo(newtetra),6)
         if (jdx.ne.0 .and. jt.ne.0) then
            tneighbor(jdx,jt) = newtetra
            ival = 3
            call mvbits (ival,0,2,tnindex(jt),2*(jdx-1))
         end if
         tinfo(newtetra) = ibset(tinfo(newtetra),1)
         if (tests(i) .eq. 1) then
            tinfo(newtetra) = ibset(tinfo(newtetra),0)
         end if
      end do
c
c     add the two faces of ktetra containing CO in the linkfacet
c     queue, each linkfacet is a triangle implicitly defined as the 
c     intersection of two tetrahedra
c
c     for facet BCO, tetrahedra are BCOP and neighbor of ABCO on BCO
c     for facet ACO, tetrahedra are ACOP and neighbor of ABCO on ACO
c
      do i = 1, 2
         newtetra = position(i)
         nlinkfacet = nlinkfacet + 1
         linkfacet(1,nlinkfacet) = newtetra
         linkfacet(2,nlinkfacet) = tneighbor(4,newtetra)
         linkindex(1,nlinkfacet) = 4
         ival = ibits(tnindex(newtetra),6,2) + 1
         linkindex(2,nlinkfacet) = ival
      end do
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine flipjw_4_1  --  4->1 flip for triangulation  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "flipjw_4_1" implements a 4->1 flip for regular triangulation
c
c     the 4->1 flip is a transformation where four tetrahedra are
c     flipped into one tetrahedron; the four tetrahedra ABOP, BCOP,
c     ABCP and ABO share a vertex B which is in the linkfacet of
c     the current point P added to the triangulation, after the
c     flip, B is set to redundant
c
c     this flip is only possible if the two edges AB and BC are
c     reflex of order 3
c
c     assume that these tests have been performed and satisfied,
c     once the flip has been performed one tetrahedron is added
c     and one new link facet is added to the link facet queue
c
c     variables and parameters:
c
c     itetra      index of the tetrahedra ABCP considered
c     jtetra      index of the tetrahedra ABCO considered
c     ktetra      index of the tetrahedra ABOP considered
c     ltetra      index of the tetrahedra BCOP considered
c     vertices    index of A, B, C, P, O
c     idp         index of B in ABCP
c     jdp         index of B in ABCO
c     kdp         index of B in ABOP
c     ldp         index of B in BCOP
c     test_acpo   orientation of the four points A, C, P and O
c     linkfacet   face of the initial tetrahedron ABCO opposite
c                   to the vertex b is added as link facet
c     linkindex   linkfacet is a triangle defined from its two
c                   neighboring tetrahedra, store the position
c                   of the vertex opposite to the triangle in
c                   each tetrehedron in the array "linkindex"
c     ierr        set to 1 if flip was not possible
c
c
      subroutine flipjw_4_1 (itetra,jtetra,ktetra,ltetra,vertices,idp,
     &                       jdp,kdp,ldp,test_acpo,ierr,tetra_last)
      use shapes
      implicit none
      integer a,b,c,o,p
      integer ierr,ival
      integer ikeep,jkeep
      integer kkeep,lkeep
      integer itetra,jtetra
      integer ktetra,ltetra
      integer ishare,jshare
      integer kshare,lshare
      integer idx,jdx,kdx,ldx
      integer idp,jdp,kdp,ldp
      integer test1,newtetra
      integer tetra_last
      integer vertices(5)
      logical test_acpo
      save
c
c
      ierr = 0
      test1 = 1
      if (test_acpo)  test1 = -1
c
c     if itetra, jtetra, ktetra, ltetra are inactive, cannot flip
c
      if (.not.btest(tinfo(itetra),1) .or. 
     &    .not.btest(tinfo(jtetra),1) .or.
     &    .not.btest(tinfo(ktetra),1) .or.
     &    .not.btest(tinfo(ltetra),1)) then
         ierr = 1
         return
      end if
c
c     store the "old" info
c
      ikeep = tinfo(itetra)
      jkeep = tinfo(jtetra)
      kkeep = tinfo(ktetra)
      lkeep = tinfo(ltetra)
c
c     ishare   index of tetrahedron sharing the face 
c                opposite to b in itetra
c     idx      index of the vertex of ishare opposite to the
c                face of ishare shared with itetra
c     jshare   index of tetrahedron sharing the face 
c                opposite to b in jtetra
c     jdx      index of the vertex of jshare opposite to the
c                face of jshare shared with jtetra
c     kshare   index of tetrahedron sharing the face 
c                opposite to b in ktetra
c     kdx      index of the vertex of kshare opposite to the
c                face of kshare shared with ktetra
c     lshare   index of tetrahedron sharing the face 
c                opposite to b in ltetra
c     ldx      index of the vertex of lshare opposite to the
c                face of lshare shared with ltetra
c
      ishare = tneighbor(idp,itetra)
      jshare = tneighbor(jdp,jtetra)
      kshare = tneighbor(kdp,ktetra)
      lshare = tneighbor(ldp,ltetra)
      ival = ibits(tnindex(itetra),2*(idp-1),2)
      idx = ival + 1
      ival = ibits(tnindex(jtetra),2*(jdp-1),2)
      jdx = ival + 1
      ival = ibits(tnindex(ktetra),2*(kdp-1),2)
      kdx = ival + 1
      ival = ibits(tnindex(ltetra),2*(ldp-1),2)
      ldx = ival + 1
c
c     store the new tetrahedron in place of itetra
c
      if (nfree .ne. 0) then
         newtetra = freespace(nfree)
         nfree = nfree - 1
      else
         ntetra = ntetra + 1
         newtetra = ntetra
      end if
      tetra_last = newtetra
      nnew = nnew + 1
      newlist(nnew) = newtetra
      tinfo(newtetra) = 0
      tnindex(newtetra) = 0
c
c     jtetra, ktetra and ltetra become "available", so they
c     are added to the "kill" zone
c
      killspace(nkill+1) = itetra
      killspace(nkill+2) = jtetra
      killspace(nkill+3) = ktetra
      killspace(nkill+4) = ltetra
      nkill = nkill + 4
      tinfo(itetra) = ibclr(tinfo(itetra),1)
      tinfo(jtetra) = ibclr(tinfo(jtetra),1)
      tinfo(ktetra) = ibclr(tinfo(ktetra),1)
      tinfo(ltetra) = ibclr(tinfo(ltetra),1)
c
c     the vertex B that is shared by all four tetrahedra, the other
c     vertices are A, C, P and O; for each tetrahedron, find neighbor
c     attached to the face oposite to B
c
      a = vertices(1)
      b = vertices(2)
      c = vertices(3)
      p = vertices(4)
      o = vertices(5)
c
c     note P is set to be the last vertex of the new tetrahedron,
c     define the new tetrahedron, ACOP
c
      vinfo(b) = ibclr(vinfo(b),0)
      tetra(1,newtetra) = a
      tneighbor(1,newtetra) = lshare
      ival = ldx - 1
      call mvbits (ival,0,2,tnindex(newtetra),0)
      call mvbits (lkeep,2+ldp,1,tinfo(newtetra),3)
      if (lshare.ne.0 .and. ldx.ne.0) then
         tneighbor(ldx,lshare) = newtetra
         ival = 0
         call mvbits (ival,0,2,tnindex(lshare),2*(ldx-1))
      end if
      tetra(2,newtetra) = c
      tneighbor(2,newtetra) = kshare
      ival = kdx - 1
      call mvbits (ival,0,2,tnindex(newtetra),2)
      call mvbits (kkeep,2+kdp,1,tinfo(newtetra),4)
      if (kshare.ne.0 .and. kdx.ne.0) then
         tneighbor(kdx,kshare) = newtetra
         ival = 1
         call mvbits (ival,0,2,tnindex(kshare),2*(kdx-1))
      end if
      tetra(3,newtetra) = o
      tneighbor(3,newtetra) = ishare
      ival = idx - 1
      call mvbits (ival,0,2,tnindex(newtetra),4)
      call mvbits (ikeep,2+idp,1,tinfo(newtetra),5)
      if (ishare.ne.0 .and. idx.ne.0) then
         tneighbor(idx,ishare) = newtetra
         ival = 2
         call mvbits (ival,0,2,tnindex(ishare),2*(idx-1))
      end if
      tetra(4,newtetra) = p
      tneighbor(4,newtetra) = jshare
      ival = jdx - 1
      call mvbits (ival,0,2,tnindex(newtetra),6)
      call mvbits (jkeep,2+jdp,1,tinfo(newtetra),6)
      if (jshare.ne.0 .and. jdx.ne.0) then
         tneighbor(jdx,jshare) = newtetra
         ival = 3
         call mvbits (ival,0,2,tnindex(jshare),2*(jdx-1))
      end if
      tinfo(newtetra) = ibset(tinfo(newtetra),1)
      if (test1 .eq. 1) then
         tinfo(newtetra) = ibset(tinfo(newtetra),0)
      end if
c
c     for facet ACO, tetrahedra are ACOP and neighbor of ABCO on ACO
c
      nlinkfacet = nlinkfacet + 1
      linkfacet(1,nlinkfacet) = newtetra
      linkfacet(2,nlinkfacet) = jshare
      linkindex(1,nlinkfacet) = 4
      linkindex(2,nlinkfacet) = jdx
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine remove_inf  --  sets status of tetrahedron   ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "remove_inf" sets the status to zero for tetrahedra that
c     contain infinite points
c
c
      subroutine remove_inf
      use shapes
      implicit none
      integer i,a,b,c,d
      save
c
c
      do i = 1, ntetra
         if (btest(tinfo(i),1)) then
            a = tetra(1,i)
            b = tetra(2,i)
            c = tetra(3,i)
            d = tetra(4,i)
            if (a.le.4 .or. b.le.4 .or. c.le.4 .or. d.le.4) then
               tinfo(i) = ibset(tinfo(i),2)
               tinfo(i) = ibclr(tinfo(i),1)
               if (a .le. 4)  call mark_zero (i,1)
               if (b .le. 4)  call mark_zero (i,2)
               if (c .le. 4)  call mark_zero (i,3)
               if (d .le. 4)  call mark_zero (i,4)
            end if
         end if
      end do
      do i = 1, 4
         vinfo(i) = ibclr(vinfo(i),0)
      end do
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine mark_zero  --  marks a touching tetrahedron  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "mark_zero" marks the tetrahedron that touches a tetrahedron
c     with infinite point as part of the convex hull (i.e., one of
c     its neighbors is zero)
c
c
      subroutine mark_zero (itetra,ivertex)
      use shapes
      implicit none
      integer ival
      integer itetra,ivertex
      integer jtetra,jvertex
      save
c
c
      jtetra = tneighbor(ivertex,itetra)
      if (jtetra .ne. 0) then
         ival = ibits(tnindex(itetra),2*(ivertex-1),2)
         jvertex = ival + 1
         tneighbor(jvertex,jtetra) = 0
      end if
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine peel  --  removes flat tetrahedra at boundary  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "peel" removes the flat tetrahedra at the boundary of the DT
c
c
      subroutine peel (ntry)
      use shapes
      implicit none
      integer i,j,k,m
      integer ia,ib,ic,id,val
      integer ntry,ival
      real*8 vol
      save
c
c
c     loop over all tetrahedra, and test the tetrahedra at
c     the boundary
c
      ntry = 0
      do i = 1, ntetra
         if (btest(tinfo(i),1)) then
            do j = 1, 4
               if (tneighbor(j,i) .eq. 0)  goto 10
            end do
c
c     the tetrahedron idx is interior, and cannot be flat
c
            goto 20
   10       continue
c
c     the tetrahedron is at the boundary; test if it is flat,
c     i.e., if its volume is 0
c
            ia = tetra(1,i)
            ib = tetra(2,i)
            ic = tetra(3,i)
            id = tetra(4,i)
            call tetra_vol (crdball,ia,ib,ic,id,vol)
            if (abs(vol) .lt. epsln4) then
               call minor4x (crdball,ia,ib,ic,id,val)
               if (val .eq. 0) then
                  tinfo(i) = ibset(tinfo(i),2)
                  ntry = ntry + 1
               end if
            end if
   20       continue
         end if
      end do
c
c     remove flat tetrahedra and update links to their neighbors
c
      do i = 1, ntetra
         if (btest(tinfo(i),2)) then
            if (btest(tinfo(i),1)) then
               tinfo(i) = ibclr(tinfo(i),1)
               do j = 1, 4
                  k = tneighbor(j,i)
                  if (k .ne. 0) then
                     ival = ibits(tnindex(i),2*(j-1),2)
                     m = ival + 1
                     tneighbor(m,k) = 0
                  end if
               end do
            end if
         end if
      end do
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine tetra_vol  --  find the volume of tetrahedron  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "tetra_vol" computes the volume of a tetrahedron
c
c     variables and parameters:
c
c     coord         array containing coordinates of all vertices
c     ia,ib,ic,id   four vertices defining the tetrahedron
c     vol           volume of the tetrahedron via floating point
c
c
      subroutine tetra_vol (crdball,ia,ib,ic,id,vol)
      implicit none
      integer i
      integer ia,ib,ic,id
      real*8 vol
      real*8 ad(3),bd(3),cd(3)
      real*8 sbcd(3)
      real*8 crdball(*)
      save
c
c     volume of the tetrahedron is proportional to:
c
c     vol = det | a(1)  a(2)  a(3) 1 |
c               | b(1)  b(2)  b(3) 1 |
c               | c(1)  c(2)  c(3) 1 |
c               | d(1)  d(2)  d(3) 1 |
c
c     after substracting the last row from the first 3 rows, and
c     developping with respect to the last column, we obtain:
c
c     vol = det | ad(1)  ad(2)  ad(3) |
c               | bd(1)  bd(2)  bd(3) |
c               | cd(1)  cd(2)  cd(3) |
c
c     where ad(i) = a(i) - d(i), etc.
c
      do i = 1, 3
         ad(i) = crdball(3*(ia-1)+i) - crdball(3*(id-1)+i)
         bd(i) = crdball(3*(ib-1)+i) - crdball(3*(id-1)+i)
         cd(i) = crdball(3*(ic-1)+i) - crdball(3*(id-1)+i)
      end do
      sbcd(3) = bd(1)*cd(2) - cd(1)*bd(2)
      sbcd(2) = bd(1)*cd(3) - cd(1)*bd(3)
      sbcd(1) = bd(2)*cd(3) - cd(2)*bd(3)
      vol = ad(1)*sbcd(1) - ad(2)*sbcd(2) + ad(3)*sbcd(3)
      if (vol < 0.0d0) vol = 0.0d0
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine sort4_sign  --  sort integers and permutation  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "sort4_sign" sorts a list of four numbers, and computes the
c     signature of the permutation
c
c
      subroutine sort4_sign (list,index,nswap,n)
      integer i,j,k
      integer n,nswap
      integer list(*)
      integer index(*)
      save
c
c
      do i = 1, n
         index(i) = i
      end do
      nswap = 1
      do i = 1, n-1
         do j = i+1, n
            if (list(i) .gt. list(j)) then
               k = list(i)
               list(i) = list(j)
               list(j) = k
               k = index(i)
               index(i) = index(j)
               index(j) = k
               nswap = -nswap
            end if
         end do
      end do
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine reorder_tetra  --  reorder tetrahedron vertices  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "reorder_tetra" reorders the vertices of a list of tetrahedra
c     such that the indices are in increasing order
c
c     if iflag is set to 1, all tetrahedra are reordered
c     if iflag is set to 0, only new tetrahedra are reordered,
c       and stored in list_tetra
c
c
      subroutine reorder_tetra (iflag,new,list_tetra)
      use shapes
      implicit none
      integer i,j,idx,ival
      integer iflag,new
      integer ntot,nswap
      integer index(4)
      integer vertex(4)
      integer neighbor(4)
      integer nsurf(4)
      integer nindex(4)
      integer list_tetra(*)
      save
c
c
      if (iflag .eq. 1) then
         ntot = ntetra
      else
         ntot = new
      end if
      do idx = 1, ntot
         if (iflag .eq. 1) then
            i = idx
         else
            i = list_tetra(idx)
         end if
         if (btest(tinfo(i),1)) then
            do j = 1, 4
               vertex(j) = tetra(j,i)
            end do
            call sort4_sign (vertex,index,nswap,4)
            do j = 1, 4
               neighbor(j) = tneighbor(index(j),i)
               nindex(j) = ibits(tnindex(i),2*(index(j)-1),2)
               nsurf(j) = ibits(tinfo(i),2+index(j),1)
               if (neighbor(j) .ne. 0) then
                  ival = j - 1
                  call mvbits (ival,0,2,tnindex(neighbor(j)),
     &                            2*nindex(j))
               end if
            end do
            do j = 1, 4
               tetra(j,i) = vertex(j)
               tneighbor(j,i) = neighbor(j)
               call mvbits (nindex(j),0,2,tnindex(i),2*(j-1))
               call mvbits (nsurf(j),0,1,tinfo(i),2+j)
            end do
            if (nswap .eq. -1) then
               if (btest(tinfo(i),0)) then
                  tinfo(i) = ibclr(tinfo(i),0)
               else
                  tinfo(i) = ibset(tinfo(i),0)
               end if
            end if
         end if
      end do
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine find_edges  --  list edges not fully buried  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "find_edges" builds a list of edges that are not fully buried,
c     returns the total number of edges and definition of the edges
c
c
      subroutine find_edges (nedge,edges)
      use shapes
      implicit none
      integer i,j,idx
      integer ia,ib,ic,id
      integer i1,i2,i3,i4
      integer nedge,iedge
      integer ival,edge_b
      integer trig1,trig2,trig_in
      integer trig_out,triga,trigb
      integer jtetra,ktetra,npass
      integer ipair,i_out
      integer face_info(2,6)
      integer face_pos(2,6)
      integer pair(2,6)
      integer edges(2,*)
      integer, allocatable :: tmask(:)
      data face_info  / 1, 2, 1, 3, 1, 4, 2, 3, 2, 4, 3, 4 /
      data face_pos  / 2, 1, 3, 1, 4, 1, 3, 2, 4, 2, 4, 3 /
      data pair  / 3, 4, 2, 4, 2, 3, 1, 4, 1, 3, 1, 2 /
      save
c
c
c     perform dynamic allocation of some local arrays
c
      allocate (tmask(ntetra))
c
c     find list of all edges in the alpha complex
c
      do i = 1, ntetra
         tmask(i) = 0
      end do
c
c     loop over tetrahedra, if belong to the Delaunay triangulation,
c     check the edges and include in edge list if not seen before
c
c     nedge = 0
      do idx = 1, ntetra
         if (btest(tinfo(idx),1)) then
            ia = tetra(1,idx)
            ib = tetra(2,idx)
            ic = tetra(3,idx)
            id = tetra(4,idx)
c
c     check all six edges
c
            do iedge = 1, 6
c
c     if this edge has already been considered, from another
c     tetrahedron, then discard
c
               if (btest(tmask(idx),iedge-1))  goto 40
c
c     if this edge is not in the alpha complex, then discard
c
               if (.not. btest(tedge(idx),iedge-1))  goto 40
c
c     note iedge is the edge number in the tetrahedron idx, with:
c     iedge = 1 (c,d); iedge = 2 (b,d); iedge = 3 (b,c)
c     iedge = 4 (a,d); iedge = 5 (a,c); iedge = 6 (a,b)
c
c     define indices of the edge
c
               i = tetra(pair(1,iedge),idx)
               j = tetra(pair(2,iedge),idx)
c
c     set edge as buried
c
               edge_b = 1
               if (.not. btest(tinfo(idx),7))  edge_b = 0
c
c     trig1 and trig2 are the two faces of idx that share iedge
c     i1 and i2 are positions of the third vertices of trig1 and trig2
c
               trig1 = face_info(1,iedge)
               i1 = face_pos(1,iedge)
               trig2 = face_info(2,iedge)
               i2 = face_pos(2,iedge)
               i3 = tetra(i1,idx)
               i4 = tetra(i2,idx)
c
c     now we look at the star of the edge
c
               ktetra = idx
               npass = 1
               trig_out = trig1
               jtetra = tneighbor(trig_out,ktetra)
   10          continue
c
c     leave this side of the star if we hit the convex hull
c     in this case, the edge is not buried
c
               if (jtetra .eq. 0) then
                  edge_b = 0
                  goto 20
               end if
c
c     leave the loop completely if we have described the full cycle
c
               if (jtetra .eq. idx)  goto 30
c
c     identify the position of iedge in tetrahedron jtetra
c
               if (i .eq. tetra(1,jtetra)) then
                  if (j .eq. tetra(2,jtetra)) then
                     ipair = 6
                  else if (j .eq. tetra(3,jtetra)) then
                     ipair = 5
                  else
                     ipair = 4
                  end if
               else if (i .eq. tetra(2,jtetra)) then
                  if (j .eq. tetra(3,jtetra)) then
                     ipair = 3
                  else
                     ipair = 2
                  end if
               else
                  ipair = 1
               end if
               tmask(jtetra) = ibset(tmask(jtetra),ipair-1)
               if (.not. btest(tinfo(jtetra),7))  edge_b = 0
c
c     find out the face we "went in"
c
               ival = ibits(tnindex(ktetra),2*(trig_out-1),2)
               trig_in = ival + 1
c
c     we know the two faces of jtetra that share iedge
c
               triga = face_info(1,ipair)
               i1 = face_pos(1,ipair)
               trigb = face_info(2,ipair)
               i2 = face_pos(2,ipair)
               trig_out = triga
               i_out = i1
               if (trig_in .eq. triga) then
                  i_out = i2
                  trig_out = trigb
               end if
               ktetra = jtetra
               jtetra = tneighbor(trig_out,ktetra)
               if (jtetra .eq. idx)  goto 30
               goto 10
   20          continue
               if (npass .eq. 2)  goto 30
               npass = npass + 1
               ktetra = idx
               trig_out = trig2
               jtetra = tneighbor(trig_out,ktetra)
               goto 10
   30          continue
               if (edge_b .eq. 0) then
                  nedge = nedge + 1
                  edges(1,nedge) = i
                  edges(2,nedge) = j
               end if
   40          continue
            end do
         end if
      end do
c
c     sort the list of all edges into increasing order
c
      call hpsort_two_int (edges,nedge)
c
c     perform deallocation of some local arrays
c
      deallocate (tmask)
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine find_all_edges  --  construct list of all edges  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "find_all_edges" builds a list of all edges in the alpha complex,
c     returns the total number of edges and definition of the edges
c
c
      subroutine find_all_edges (nedge,edges)
      use shapes
      implicit none
      integer i,j,idx
      integer ia,ib,ic,id
      integer i1,i2,i3,i4
      integer nedge,iedge,ival
      integer trig1,trig2,trig_in
      integer trig_out,triga,trigb
      integer jtetra,ktetra,npass
      integer ipair,i_out
      integer face_info(2,6)
      integer face_pos(2,6)
      integer pair(2,6)
      integer edges(2,*)
      integer, allocatable :: tmask(:)
      data face_info  / 1, 2, 1, 3, 1, 4, 2, 3, 2, 4, 3, 4 /
      data face_pos  / 2, 1, 3, 1, 4, 1, 3, 2, 4, 2, 4, 3 /
      data pair  / 3, 4, 2, 4, 2, 3, 1, 4, 1, 3, 1, 2 /
      save
c
c
c     perform dynamic allocation of some local arrays
c
      allocate (tmask(ntetra))
c
c     find list of all edges in the alpha complex
c
      do i = 1, ntetra
         tmask(i) = 0
      end do
c
c     loop over tetrahedra, if belong to the Delaunay triangulation,
c     check the edges and include in edge list if not seen before
c
c     nedge = 0
      do idx = 1, ntetra
         if (btest(tinfo(idx),1)) then
            ia = tetra(1,idx)
            ib = tetra(2,idx)
            ic = tetra(3,idx)
            id = tetra(4,idx)
c
c     check all six edges
c
            do iedge = 1, 6
c
c     if this edge has already been considered, from another
c     tetrahedron, then discard
c
               if (btest(tmask(idx),iedge-1))  goto 30
c
c     if this edge is not in the alpha complex, then discard
c
               if (.not. btest(tedge(idx),iedge-1))  goto 30
c
c     note iedge is the edge number in the tetrahedron idx, with:
c     iedge = 1 (c,d); iedge = 2 (b,d); iedge = 3 (b,c)
c     iedge = 4 (a,d); iedge = 5 (a,c); iedge = 6 (a,b)
c
c     define indices of the edge
c
               i = tetra(pair(1,iedge),idx)
               j = tetra(pair(2,iedge),idx)
c
c     set edge as buried
c
               nedge = nedge + 1
               edges(1,nedge) = i
               edges(2,nedge) = j
c
c     trig1 and trig2 are the two faces of idx that share iedge
c     i1 and i2 are positions of the third vertices of trig1 and trig2
c
               trig1 = face_info(1,iedge)
               i1 = face_pos(1,iedge)
               trig2 = face_info(2,iedge)
               i2 = face_pos(2,iedge)
               i3 = tetra(i1,idx)
               i4 = tetra(i2,idx)
c
c     now we look at the star of the edge
c
               ktetra = idx
               npass = 1
               trig_out = trig1
               jtetra = tneighbor(trig_out,ktetra)
   10          continue
c
c     leave this side of the star if we hit the convex hull
c     in this case, the edge is not buried
c
               if (jtetra .eq. 0)  goto 20
c
c     leave the loop completely if we have described the full cycle
c
               if (jtetra .eq. idx)  goto 30
c
c     identify the position of iedge in tetrahedron jtetra
c
               if (i .eq. tetra(1,jtetra)) then
                  if (j .eq. tetra(2,jtetra)) then
                     ipair = 6
                  else if (j .eq. tetra(3,jtetra)) then
                     ipair = 5
                  else
                     ipair = 4
                  end if
               else if (i .eq. tetra(2,jtetra)) then
                  if (j .eq. tetra(3,jtetra)) then
                     ipair = 3
                  else
                     ipair = 2
                  end if
               else
                  ipair = 1
               end if
               tmask(jtetra) = ibset(tmask(jtetra),ipair-1)
c
c     find out the face we "went in"
c
               ival = ibits(tnindex(ktetra),2*(trig_out-1),2)
               trig_in = ival + 1
c
c     we know the two faces of jtetra that share iedge
c
               triga = face_info(1,ipair)
               i1 = face_pos(1,ipair)
               trigb = face_info(2,ipair)
               i2 = face_pos(2,ipair)
               trig_out = triga
               i_out = i1
               if (trig_in .eq. triga) then
                  i_out = i2
                  trig_out = trigb
               end if
               ktetra = jtetra
               jtetra = tneighbor(trig_out,ktetra)
               if (jtetra .eq. idx)  goto 30
               goto 10
   20          continue
               if (npass .eq. 2)  goto 30
               npass = npass + 1
               ktetra = idx
               trig_out = trig2
               jtetra = tneighbor(trig_out,ktetra)
               goto 10
   30          continue
            end do
         end if
      end do
c
c     sort list of all edges in increasing order
c
      call hpsort_two_int (edges,nedge)
c
c     perform deallocation of some local arrays
c
      deallocate (tmask)
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine get_coords2  --  extracts and stores two atoms  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "get_coord2" extracts two atoms from the global array containing
c     all atoms, centers them on (0,0,0), recomputes their weights
c     and stores them in local arrays
c
c     variables and parameters:
c
c     ia,ja    indices of the four points considered
c     a,b      centered coordinates of the two points
c     ra,rb    radii of the two points
c     cg       center of gravity of the points
c
c
      subroutine get_coord2 (ia,ja,a,b,ra,rb,cg)
      use shapes
      implicit none
      integer i,ia,ja
      real*8 ra,rb
      real*8 a(*),b(*),cg(3)
c
c
c     get coordinates and center of mass, then center the points
c
      do i = 1, 3
         a(i) = crdball(3*(ia-1)+i)
         b(i) = crdball(3*(ja-1)+i)
         cg(i) = a(i) + b(i)
      end do
      do i = 1, 3
         cg(i) = 0.5d0 * cg(i)
      end do
      do i = 1, 3
         a(i) = a(i) - cg(i)
         b(i) = b(i) - cg(i)
      end do
      ra = radball(ia)
      rb = radball(ja)
      a(4) = a(1)*a(1) + a(2)*a(2) + a(3)*a(3) - ra*ra
      b(4) = b(1)*b(1) + b(2)*b(2) + b(3)*b(3) - rb*rb
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine get_coords4  --  extracts and stores four atoms  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "get_coord4" extracts four atoms from the global array containing
c     all atoms, centers them on (0,0,0), recomputes their weights and
c     stores them in local arrays
c
c     variables and parameters:
c
c     ia,ja,ka,la    indices of the four points considered
c     a,b,c,d        centered coordinates of the four points
c     ra,rb,rc,rd    radii of the four points
c     cg             center of gravity of the points
c
c
      subroutine get_coord4 (ia,ja,ka,la,a,b,c,d,ra,rb,rc,rd,cg)
      use shapes
      implicit none
      integer i,ia,ja,ka,la
      real*8 ra,rb,rc,rd
      real*8 a(*),b(*),c(*)
      real*8 d(*),cg(3)
c
c
c     get coordinates and center of mass, and center the points
c
      do i = 1, 3
         a(i) = crdball(3*(ia-1)+i)
         b(i) = crdball(3*(ja-1)+i)
         c(i) = crdball(3*(ka-1)+i)
         d(i) = crdball(3*(la-1)+i)
         cg(i) = a(i) + b(i) + c(i) + d(i)
      end do
      do i = 1, 3
         cg(i) = 0.25d0 * cg(i)
      end do
      do i = 1, 3
         a(i) = a(i) - cg(i)
         b(i) = b(i) - cg(i)
         c(i) = c(i) - cg(i)
         d(i) = d(i) - cg(i)
      end do
      ra = radball(ia)
      rb = radball(ja)
      rc = radball(ka)
      rd = radball(la)
      a(4) = a(1)*a(1) + a(2)*a(2) + a(3)*a(3) - ra*ra
      b(4) = b(1)*b(1) + b(2)*b(2) + b(3)*b(3) - rb*rb
      c(4) = c(1)*c(1) + c(2)*c(2) + c(3)*c(3) - rc*rc
      d(4) = d(1)*d(1) + d(2)*d(2) + d(3)*d(3) - rd*rd
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine get_coords5  --  extracts and stores five atoms  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "get_coord5" extracts five atoms from the global array containing
c     all atoms, centers them on (0,0,0), recomputes their weights and
c     stores them in local arrays
c
c     variables and parameters:
c
c     ia,ja,ka,la,ma    indices of the four points considered
c     a,b,c,d,e         centered coordinates of the five points
c     ra,rb,rc,rd,re    radii of the four points
c     cg                center of gravity of the points
c
c
      subroutine get_coord5 (ia,ja,ka,la,ma,a,b,c,d,e,
     &                          ra,rb,rc,rd,re,cg)
      use shapes
      implicit none
      integer i,ia,ja,ka,la,ma
      real*8 ra,rb,rc,rd,re
      real*8 a(*),b(*),c(*)
      real*8 d(*),e(*),cg(3)
c
c
c     get coordinates and center of mass, and center the points
c
      do i = 1, 3
         a(i) = crdball(3*(ia-1)+i)
         b(i) = crdball(3*(ja-1)+i)
         c(i) = crdball(3*(ka-1)+i)
         d(i) = crdball(3*(la-1)+i)
         e(i) = crdball(3*(ma-1)+i)
         cg(i) = a(i) + b(i) + c(i) + d(i) + e(i)
      end do
      do i = 1, 3
         cg(i) = 0.2d0 * cg(i)
      end do
      do i = 1, 3
         a(i) = a(i) - cg(i)
         b(i) = b(i) - cg(i)
         c(i) = c(i) - cg(i)
         d(i) = d(i) - cg(i)
         e(i) = e(i) - cg(i)
      end do
      ra = radball(ia)
      rb = radball(ja)
      rc = radball(ka)
      rd = radball(la)
      re = radball(ma)
      a(4) = a(1)*a(1) + a(2)*a(2) + a(3)*a(3) - ra*ra
      b(4) = b(1)*b(1) + b(2)*b(2) + b(3)*b(3) - rb*rb
      c(4) = c(1)*c(1) + c(2)*c(2) + c(3)*c(3) - rc*rc
      d(4) = d(1)*d(1) + d(2)*d(2) + d(3)*d(3) - rd*rd
      e(4) = e(1)*e(1) + e(2)*e(2) + e(3)*e(3) - re*re
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine resize_tet  --  resize all tetrahedron arrays  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "resize_tet" resizes all arrays related to tetrahedra, when
c     the initial estimate of the number of tetrahedron was wrong
c
c
      subroutine resize_tet
      use shapes
      implicit none
      integer i,j
      integer, allocatable :: tetra2(:,:)
      integer, allocatable :: tneighbor2(:,:)
      integer, allocatable :: tinfo2(:)
      integer, allocatable :: tnindex2(:)
      save
c
c
c     set size of space for tetrahedra-related arrays
c
      maxtetra = (3*ntetra) / 2
      maxtetra = max(maxtetra,ntetra+1000)
c 
c     perform dynamic allocation of some local arrays
c
      allocate (tinfo2(maxtetra))
      allocate (tnindex2(maxtetra))
      allocate (tetra2(4,maxtetra))
      allocate (tneighbor2(4,maxtetra))
c
c     copy prior information into resized arrays
c
      do i = 1, ntetra
         tinfo2(i) = tinfo(i)
         tnindex2(i) = tnindex(i)
         do j = 1, 4
            tetra2(j,i) = tetra(j,i)
            tneighbor2(j,i) = tneighbor(j,i)
         end do
      end do
c
c     move the extended array storage into prior arrays; note
c     deallocation of new temporary arrays happens automatically
c
      call move_alloc (tinfo2,tinfo)
      call move_alloc (tnindex2,tnindex)
      call move_alloc (tetra2,tetra)
      call move_alloc (tneighbor2,tneighbor)
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine hpsort_three  --  heapsort 3D reals with index  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "hpsort_three" rearranges an array in ascending order and
c     provide an index of the ranked element
c
c
      subroutine hpsort_three (ra,index,n)
      implicit none
      integer i,j,k,m,n
      integer ir,idx,comp3
      integer index(n)
      real*8 rra(3)
      real*8 ra(3,n)
      save
c
c
      do i = 1, n
         index(i) = i
      end do
      if (n .lt. 2)  return
      m = n/2 + 1
      ir = n
   10 continue
      if (m .gt. 1) then
         m = m - 1
         do k = 1, 3
            rra(k) = ra(k,m)
         end do
         idx = m
      else
         do k = 1, 3
            rra(k) = ra(k,ir)
         end do
         idx = index(ir)
         do k = 1, 3
            ra(k,ir) = ra(k,1)
         end do
         index(ir) = index(1)
         ir = ir - 1
         if (ir .eq. 1) then
            do k = 1, 3
               ra(k,1) = rra(k)
            end do
            index(1) = idx
            return
         end if
      end if
      i = m
      j = m + m
   20 continue
      if (j .le. ir) then
         if (j .lt. ir) then
            if (comp3(ra(1,j),ra(1,j+1)) .eq. 1)  j = j + 1
         end if
         if (comp3(rra,ra(1,j)) .eq. 1) then
            do k = 1, 3
               ra(k,i) = ra(k,j)
            end do
            index(i) = index(j)
            i = j
            j = j + j
         else
            j = ir + 1
         end if
         goto 20
      end if
      do k = 1, 3
         ra(k,i) = rra(k)
      end do
      index(i) = idx
      goto 10
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  function comp3  --  compare two 3-dimensional real vectors  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "comp3" is a function comparing two arrays each containing
c     three real numbers
c
c
      function comp3 (a,b)
      implicit none
      integer i,comp3
      real*8 a(3),b(3)
      save
c
c
      comp3 = 0
      do i = 1, 3
         if (a(i) .lt. b(i)) then
            comp3 = 1
            return
         else if (a(i) .gt. b(i)) then
            return
         end if
      end do
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine hpsort_two_int  --  heapsort 2D integer array  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "hpsort_two_int" rearranges an array in ascending order and
c     provide an index of the ranked element
c
c
      subroutine hpsort_two_int (ra,n)
      implicit none
      integer i,j,k,m,n
      integer ir,idx,comp2
      integer rra(2)
      integer ra(2,n)
      save
c
c
      if (n .lt. 2)  return
      m = n/2 + 1
      ir = n
   10 continue
      if (m .gt. 1) then
         m = m - 1
         do k = 1, 2
            rra(k) = ra(k,m)
         end do
         idx = m
      else
         do k = 1, 2
            rra(k) = ra(k,ir)
         end do
         do k = 1, 2
            ra(k,ir) = ra(k,1)
         end do
         ir = ir - 1
         if (ir .eq. 1) then
            do k = 1, 2
               ra(k,1) = rra(k)
            end do
            return
         end if
      end if
      i = m
      j = m + m
   20 continue
      if (j .le. ir) then
         if (j .lt. ir) then
            if (comp2(ra(1,j),ra(1,j+1)) .eq. 1)  j = j + 1
         end if
         if (comp2(rra,ra(1,j)) .eq. 1) then
            do k = 1, 2
               ra(k,i) = ra(k,j)
            end do
            i = j
            j = j + j
         else
            j = ir + 1
         end if
         goto 20
      end if
      do k = 1, 2
         ra(k,i) = rra(k)
      end do
      goto 10
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  function comp2  --  compare two 2-dimensional real vectors  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "comp2" is a function comparing two arrays each containing
c     two real numbers
c
c
      function comp2 (a,b)
      implicit none
      integer i,comp2
      integer a(2),b(2)
      save
c
c
      comp2 = 0
      do i = 1, 2
         if (a(i) .lt. b(i)) then
            comp2 = 1
            return
         else if (a(i) .gt. b(i)) then
            return
         end if
      end do
      return
      end
c
c
c     ################################################################33
c     ##                                                              ##
c     ##  subroutine distance2  --  distance squares between spheres  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "distance2" computes the square of the distance between two
c     sphere centers
c
c
      subroutine distance2 (crdball,n1,n2,dist)
      implicit none
      integer i,n1,n2
      real*8 dist,val
      real*8 crdball(*)
      save
c
c
      dist = 0.0d0
      do i = 1, 3
         val = crdball(3*(n1-1)+i) - crdball(3*(n2-1)+i)
         dist = dist + val*val
      end do
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine plane_dist  --  find sphere to plane distance  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "plane_dist" computes the distance between the center of
c     sphere A and the Voronoi plane between this sphere and
c     another sphere B
c
c
      subroutine plane_dist (ra2,rb2,rab2,lambda)
      implicit none
      real*8 ra2,rb2,rab2
      real*8 lambda
      save
c
c
      lambda = 0.5d0 - (ra2-rb2)/(2.0d0*rab2)
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine twosphere_surf  --  sphere intersection area  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "twosphere_surf" computes the surface area of the intersection
c     of two spheres, only called when the intersection exists
c
c     variables and parameters:
c
c     rab        distance between the centers of the two spheres
c     rab2       squared distance between the centers of spheres
c     ra,rb      radii of spheres A and B, respectively
c     ra2,rb2    squared radii of the spheres A and B
c     surfa      partial contribution of A to the total surface
c                  of the intersection
c     surfb      partial contribution of B to the total surface
c                  of the intersection
c
c
      subroutine twosphere_surf (ra,ra2,rb,rb2,rab,rab2,surfa,surfb)
      use math
      implicit none
      real*8 ra,rb,surfa,surfb
      real*8 vala,valb,lambda
      real*8 ra2,rb2,rab,rab2,ha,hb
      save
c
c
c     find the distance between center of sphere A and the
c     Voronoi plane between A and B
c
      call plane_dist (ra2,rb2,rab2,lambda)
      valb = lambda * rab
      vala = rab - valb
c
c     get height of the cap of sphere A occluded by sphere B
c
      ha = ra - vala
c
c     now do the same as above for sphere B
c
      hb = rb - valb
c
c     get the surface areas of intersection
c
      surfa = twopi * ra * ha
      surfb = twopi * rb * hb
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine twosphere_vol  --  sphere intersection volume  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "twosphere_vol" calculates the volume of the intersection of
c     two balls and the surface area  of the intersection of two
c     corresponding spheres
c
c     variables and parameters:
c
c     rab       distance between the centers of the two spheres
c     rab2      squared distance between the centers of spheres
c     ra,rb     radii of spheres A and B, respectively
c     ra2,rb2   squared radii of the spheres A and B
c     surfa     partial contribution of A to the total surface
c                 of the intersection
c     surfb     partial contribution of B to the total surface
c                 of the intersection
c     vola      partial contribution of A to the total volume
c                 of the intersection
c     volb      partial contribution of B to the total volume
c                 of the intersection
c
c
      subroutine twosphere_vol (ra,ra2,rb,rb2,rab,rab2,
     &                          surfa,surfb,vola,volb)
      use math
      implicit none
      real*8 ra,rb,surfa,surfb
      real*8 vola,volb
      real*8 vala,valb,lamda
      real*8 ra2,rb2,rab,rab2
      real*8 ha,hb,sa,ca,sb,cb
      real*8 aab
      save
c
c
c     find the distance between center of sphere A and the
c     Voronoi plane between A and B
c
      call plane_dist (ra2,rb2,rab2,lamda)
      valb = lamda * rab
      vala = rab - valb
c
c     get height of the cap of sphere A occluded by sphere B
c
      ha = ra - vala
c
c     now do the same as above for sphere B
c
      hb = rb - valb
c
c     get the surface areas of intersection
c
      surfa = twopi * ra * ha
      surfb = twopi * rb * hb
c
c     now get the associated volume
c
      aab = pi * (ra2-vala*vala)
      sa = ra * surfa
      ca = vala * aab
      vola = (sa-ca) / 3.0d0
      sb = rb * surfb
      cb = valb * aab
      volb = (sb-cb) / 3.0d0
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine threesphere_surf  --  find three sphere area  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "threesphere_surf" calculates the surface area of intersection 
c     of three spheres
c
c     variables and parameters:
c
c     ra,rb,rc       radii of spheres A, B and C, respectively
c     ra2,rb2,rc2    squared distance between the centers of spheres
c     rab,rab2       distance between the centers of sphere A and B
c     rac,rac2       distance between the centers of sphere A and C
c     rbc,rbc2       distance between the centers of sphere B and C
c     surfa,surfb,   contribution of A, B and C to the total surface
c       surfc          of the intersection of A, B and C
c
c
      subroutine threesphere_surf (ra,rb,rc,ra2,rb2,rc2,rab,rac,rbc,
     &                             rab2,rac2,rbc2,surfa,surfb,surfc)
      use math
      implicit none
      real*8 surfa,surfb,surfc
      real*8 ra,rb,rc
      real*8 rab,rac,rbc
      real*8 rab2,rac2,rbc2
      real*8 ra2,rb2,rc2
      real*8 a1,a2,a3
      real*8 seg_ang_ab,seg_ang_ac
      real*8 seg_ang_bc
      real*8 ang_dih_ap,ang_dih_bp
      real*8 ang_dih_cp
      real*8 l1,l2,l3
      real*8 val1,val2,val3
      real*8 val1b,val2b,val3b
      real*8 angle(6),cosine(6),sine(6)
      save
c
c
      call plane_dist (ra2,rb2,rab2,l1)
      call plane_dist (ra2,rc2,rac2,l2)
      call plane_dist (rb2,rc2,rbc2,l3)
      val1 = l1 * rab
      val2 = l2 * rac
      val3 = l3 * rbc
      val1b = rab - val1
      val2b = rac - val2
      val3b = rbc - val3
c
c     consider the tetrahedron (A,B,C,P) where P is the point
c     of intersection of the three spheres such that (A,B,C,P)
c     is counter-clockwise; the edge lengths in this tetrahedron
c     are rab, rac, rAP=ra, rbc, rBP=rb and rCP=rc
c
      call tetra_dihed (rab2,rac2,ra2,rbc2,rb2,rc2,angle,cosine,sine)
c
c     the seg_ang values are the dihedral angles around the three
c     edges AB, AC and BC
c
      seg_ang_ab = angle(1)
      seg_ang_ac = angle(2)
      seg_ang_bc = angle(4)
c
c     the ang_dih values are the dihedral angles around the three
c     edges AP, BP and CP
c
      ang_dih_ap = angle(3)
      ang_dih_bp = angle(5)
      ang_dih_cp = angle(6)
      a1 = ra * (1.0d0-2.0d0*ang_dih_ap)
      a2 = 2.0d0 * seg_ang_ab * val1b
      a3 = 2.0d0 * seg_ang_ac * val2b
      surfa = twopi * ra * (a1-a2-a3)
      a1 = rb * (1.0d0-2.0d0*ang_dih_bp)
      a2 = 2.0d0 * seg_ang_ab * val1
      a3 = 2.0d0 * seg_ang_bc * val3b
      surfb = twopi * rb * (a1-a2-a3)
      a1 = rc * (1.0d0-2.0d0*ang_dih_cp)
      a2 = 2.0d0 * seg_ang_ac * val2
      a3 = 2.0d0 * seg_ang_bc * val3
      surfc = twopi * rc * (a1-a2-a3)
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine threesphere_vol  --  find three sphere volume  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "threesphere_vol" calculates the volume of intersection of
c     three balls as well as the surface area of intersection
c
c     variables and parameters:
c
c     ra,rb,rc       radii of spheres A, B and C, respectively
c     ra2,rb2,rc2    squared distance between the centers of spheres
c     rab,rab2       distance between the centers of sphere A and B
c     rac,rac2       distance between the centers of sphere A and C
c     rbc,rbc2       distance between the centers of sphere B and C
c     surfa,surfb,   contribution of A, B and C to the total surface
c       surfc          of the intersection of A, B and C
c     vola,volb,     contribution of A, B and C tothe total volume
c       volc           of the intersection of A, B and C
c
c
      subroutine threesphere_vol (ra,rb,rc,ra2,rb2,rc2,rab,rac,rbc,
     &                            rab2,rac2,rbc2,surfa,surfb,surfc,
     &                            vola,volb,volc)
      use math
      implicit none
      real*8 surfa,surfb,surfc
      real*8 vola,volb,volc
      real*8 ra,rb,rc
      real*8 rab,rac,rbc
      real*8 rab2,rac2,rbc2
      real*8 ra2,rb2,rc2
      real*8 a1,a2,a3,s2,c1,c2
      real*8 seg_ang_ab,seg_ang_ac
      real*8 seg_ang_bc
      real*8 ang_dih_ap,ang_dih_bp
      real*8 ang_dih_cp
      real*8 ang_abc,ang_acb,ang_bca
      real*8 cos_abc,cos_acb,cos_bca
      real*8 sin_abc,sin_acb,sin_bca
      real*8 s_abc,s_acb,s_bca
      real*8 l1,l2,l3
      real*8 val1,val2,val3
      real*8 val1b,val2b,val3b
      real*8 rho_ab2,rho_ac2,rho_bc2
      real*8 angle(6),cosine(6),sine(6)
      save
c
c
      call plane_dist (ra2,rb2,rab2,l1)
      call plane_dist (ra2,rc2,rac2,l2)
      call plane_dist (rb2,rc2,rbc2,l3)
      val1 = l1 * rab
      val2 = l2 * rac
      val3 = l3 * rbc
      val1b = rab - val1
      val2b = rac - val2
      val3b = rbc - val3
c
c     consider the tetrahedron (A,B,C,P) where P is the point
c     of intersection of the three spheres such that (A,B,C,P)
c     is counter-clockwise; the edge lengths in this tetrahedron
c     are rab, rac, rAP=ra, rbc, rBP=rb and rCP=rc
c
      call tetra_dihed (rab2,rac2,ra2,rbc2,rb2,rc2,angle,cosine,sine)
c
c     the seg_ang values are the dihedral angles around the three
c     edges AB, AC and BC
c
      seg_ang_ab = angle(1)
      seg_ang_ac = angle(2)
      seg_ang_bc = angle(4)
c
c     the ang_dih values are the dihedral angles around the three
c     edges AP, BP and CP
c
      ang_dih_ap = angle(3)
      ang_dih_bp = angle(5)
      ang_dih_cp = angle(6)
      a1 = ra * (1.0d0-2.0d0*ang_dih_ap)
      a2 = 2.0d0 * seg_ang_ab * val1b
      a3 = 2.0d0 * seg_ang_ac * val2b
      surfa = twopi * ra * (a1-a2-a3)
      a1 = rb * (1.0d0-2.0d0*ang_dih_bp)
      a2 = 2.0d0 * seg_ang_ab * val1
      a3 = 2.0d0 * seg_ang_bc * val3b
      surfb = twopi * rb * (a1-a2-a3)
      a1 = rc * (1.0d0-2.0d0*ang_dih_cp)
      a2 = 2.0d0 * seg_ang_ac * val2
      a3 = 2.0d0 * seg_ang_bc * val3
      surfc = twopi * rc * (a1-a2-a3)
      ang_abc = twopi * seg_ang_ab
      ang_acb = twopi * seg_ang_ac
      ang_bca = twopi * seg_ang_bc
      cos_abc = cosine(1)
      sin_abc = sine(1)
      cos_acb = cosine(2)
      sin_acb = sine(2)
      cos_bca = cosine(4)
      sin_bca = sine(4)
      rho_ab2 = ra2 - val1b*val1b
      rho_ac2 = ra2 - val2b*val2b
      rho_bc2 = rb2 - val3b*val3b
      s_abc = rho_ab2 * (ang_abc-sin_abc*cos_abc)
      s_acb = rho_ac2 * (ang_acb-sin_acb*cos_acb)
      s_bca = rho_bc2 * (ang_bca-sin_bca*cos_bca)
      s2 = ra * surfa
      c1 = val1b * s_abc
      c2 = val2b * s_acb
      vola = (s2-c1-c2) / 3.0d0
      s2 = rb * surfb
      c1 = val1 * s_abc
      c2 = val3b * s_bca
      volb = (s2-c1-c2) / 3.0d0
      s2 = rc * surfc
      c1 = val2 * s_acb
      c2 = val3 * s_bca
      volc = (s2-c1-c2) / 3.0d0
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine triangle_surf  --  three sphere area driver  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "triangle_surf" computes the surface area of intersection
c     of three balls, provides a wrapper to "threesphere_surf"
c
c
      subroutine triangle_surf (a,b,c,rab,rac,rbc,rab2,rac2,rbc2,ra,
     &                          rb,rc,ra2,rb2,rc2,surfa,surfb,surfc)
      implicit none
      real*8 rab,rac,rbc
      real*8 rab2,rac2,rbc2
      real*8 ra,rb,rc
      real*8 ra2,rb2,rc2
      real*8 surfa,surfb,surfc
      real*8 a(3),b(3),c(3),u(3)
c
c
      if (rab .eq. 0.0d0) then
         call diffvect (a,b,u)
         call normvect (u,rab)
         rab2 = rab * rab
      end if
      if (rac .eq. 0.0d0) then
         call diffvect (a,c,u)
         call normvect (u,rac)
         rac2 = rac * rac
      end if
      if (rbc .eq. 0.0d0) then
         call diffvect (b,c,u)
         call normvect (u,rbc)
         rbc2 = rbc * rbc
      end if
      call threesphere_surf (ra,rb,rc,ra2,rb2,rc2,rab,rac,rbc,
     &                       rab2,rac2,rbc2,surfa,surfb,surfc)
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine triangle_vol  --  three sphere volume driver  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "triangle_vol" computes the volume of intersection of three
c     balls, provides a wrapper to "threesphere_vol"
c
c
      subroutine triangle_vol (a,b,c,rab,rac,rbc,rab2,rac2,rbc2,
     &                         ra,rb,rc,ra2,rb2,rc2,surfa,surfb,
     &                         surfc,vola,volb,volc)
      implicit none
      real*8 rab,rac,rbc
      real*8 rab2,rac2,rbc2
      real*8 ra,rb,rc
      real*8 ra2,rb2,rc2
      real*8 surfa,surfb,surfc
      real*8 vola,volb,volc
      real*8 a(3),b(3),c(3),u(3)
c
c
      if (rab .eq. 0.0d0) then
         call diffvect (a,b,u)
         call normvect (u,rab)
         rab2 = rab * rab
      end if
      if (rac .eq. 0.0d0) then
         call diffvect (a,c,u)
         call normvect (u,rac)
         rac2 = rac * rac
      end if
      if (rbc .eq. 0.0d0) then
         call diffvect (b,c,u)
         call normvect (u,rbc)
         rbc2 = rbc * rbc
      end if
      call threesphere_vol (ra,rb,rc,ra2,rb2,rc2,rab,rac,rbc,
     &                      rab2,rac2,rbc2,surfa,surfb,surfc,
     &                      vola,volb,volc)
      return
      end
c
c
c     #############################################################
c     ##                                                         ##
c     ##  subroutine tetra_voronoi  --  find four sphere volume  ##
c     ##                                                         ##
c     #############################################################
c
c
c     "tetra_voronoi" computes the volume of intersection of the
c     tetrahedron formed by the center of four balls with the
c     Voronoi cells corresponding to these balls
c
c     variables and parameters:
c
c     ra2,rb2,rc2,rd2    squared radii of the spheres A, B, C, D
c     rab,rac,rad,       all distances between the ball centers
c       rbc,rbd,rcd
c     rab2,rac2,rad2,    squared distances between ball centers
c       rbc2,rbd2,rcd2   
c     cos_ang            cosine of the six dihedral angles of the
c                          tetrahedron
c     sin_ang            sine of the six dihedral angles of the
c                          tetrahedron
c     vola,volb,         fraction of the volume of tetrahedron
c       volc,vold          corresponding to the four balls
c
c
      subroutine tetra_voronoi (ra2,rb2,rc2,rd2,rab,rac,rad,rbc,rbd,
     &                          rcd,rab2,rac2,rad2,rbc2,rbd2,rcd2,
     &                          cos_ang,sin_ang,vola,volb,volc,vold)
      integer i
      real*8 ra2,rb2,rc2,rd2
      real*8 rab,rac,rad
      real*8 rbc,rbd,rcd
      real*8 rab2,rac2,rad2
      real*8 rbc2,rbd2,rcd2
      real*8 vola,volb,volc,vold
      real*8 l1,l2,l3,l4,l5,l6
      real*8 val1,val2,val3
      real*8 val4,val5,val6
      real*8 val1b,val2b,val3b
      real*8 val4b,val5b,val6b
      real*8 cos_abc,cos_acb,cos_bca
      real*8 cos_abd,cos_adb,cos_bda
      real*8 cos_acd,cos_adc,cos_cda
      real*8 cos_bcd,cos_bdc,cos_cdb
      real*8 rho_ab2,rho_ac2,rho_ad2
      real*8 rho_bc2,rho_bd2,rho_cd2
      real*8 cap_ab,cap_ac,cap_ad
      real*8 cap_bc,cap_bd,cap_cd
      real*8 eps
      real*8 cosine_abc(3),cosine_abd(3)
      real*8 cosine_acd(3),cosine_bcd(3)
      real*8 cos_ang(6),sin_ang(6)
      real*8 invsin(6),cotan(6)
      save
c
c
      call plane_dist (ra2,rb2,rab2,l1)
      call plane_dist (ra2,rc2,rac2,l2)
      call plane_dist (ra2,rd2,rad2,l3)
      call plane_dist (rb2,rc2,rbc2,l4)
      call plane_dist (rb2,rd2,rbd2,l5)
      call plane_dist (rc2,rd2,rcd2,l6)
      val1 = l1 * rab
      val2 = l2 * rac
      val3 = l3 * rad
      val4 = l4 * rbc
      val5 = l5 * rbd
      val6 = l6 * rcd
      val1b = rab - val1
      val2b = rac - val2
      val3b = rad - val3
      val4b = rbc - val4
      val5b = rbd - val5
      val6b = rcd - val6
c
c     consider the tetrahedron (A,B,C,P) where P is the point
c     of intersection of the three spheres such that (A,B,C,P)
c     is counter-clockwise; the edge lengths in this tetrahedron
c     are rab, rac, rAP=ra, rbc, rBP=rb and rCP=rc
c
      call tetra_3dihed_cos (rab2,rac2,ra2,rbc2,rb2,rc2,cosine_abc)
c
c     repeat the above for tetrahedron (A,B,D,P)
c
      call tetra_3dihed_cos (rab2,rad2,ra2,rbd2,rb2,rd2,cosine_abd)
c
c     repeat the above for tetrahedron (A,C,D,P)
c
      call tetra_3dihed_cos (rac2,rad2,ra2,rcd2,rc2,rd2,cosine_acd)
c
c     repeat the above for tetrahedron (B,C,D,P)
c
      call tetra_3dihed_cos (rbc2,rbd2,rb2,rcd2,rc2,rd2,cosine_bcd)
c
      cos_abc = cosine_abc(1)
      cos_acb = cosine_abc(2)
      cos_bca = cosine_abc(3)
      cos_abd = cosine_abd(1)
      cos_adb = cosine_abd(2)
      cos_bda = cosine_abd(3)
      cos_acd = cosine_acd(1)
      cos_adc = cosine_acd(2)
      cos_cda = cosine_acd(3)
      cos_bcd = cosine_bcd(1)
      cos_bdc = cosine_bcd(2)
      cos_cdb = cosine_bcd(3)
      rho_ab2 = ra2 - val1b*val1b
      rho_ac2 = ra2 - val2b*val2b
      rho_ad2 = ra2 - val3b*val3b
      rho_bc2 = rb2 - val4b*val4b
      rho_bd2 = rb2 - val5b*val5b
      rho_cd2 = rc2 - val6b*val6b
      eps = 1.0d-14
      do i = 1, 6
         if (abs(sin_ang(i)) < eps) then
            invsin(i) = 0.0d0;
            cotan(i) = 0.0d0;
         else
            invsin(i) = 1.0d0 / sin_ang(i)
            cotan(i) = cos_ang(i)*invsin(i)
         end if
      end do
      cap_ab = -rho_ab2*(cos_abc*cos_abc+cos_abd*cos_abd)*cotan(1)
     &            + 2*rho_ab2*cos_abc*cos_abd*invsin(1)
      cap_ac = -rho_ac2*(cos_acb*cos_acb+cos_acd*cos_acd)*cotan(2)
     &            + 2*rho_ac2*cos_acb*cos_acd*invsin(2)
      cap_ad = -rho_ad2*(cos_adb*cos_adb+cos_adc*cos_adc)*cotan(3)
     &            + 2*rho_ad2*cos_adb*cos_adc*invsin(3)
      cap_bc = -rho_bc2*(cos_bca*cos_bca+cos_bcd*cos_bcd)*cotan(4)
     &            + 2*rho_bc2*cos_bca*cos_bcd*invsin(4)
      cap_bd = -rho_bd2*(cos_bda*cos_bda+cos_bdc*cos_bdc)*cotan(5)
     &            + 2*rho_bd2*cos_bda*cos_bdc*invsin(5)
      cap_cd = -rho_cd2*(cos_cda*cos_cda+cos_cdb*cos_cdb)*cotan(6)
     &            + 2*rho_cd2*cos_cda*cos_cdb*invsin(6)
      vola = (val1b*cap_ab+val2b*cap_ac+val3b*cap_ad) / 6.0d0
      volb = (val1*cap_ab+val4b*cap_bc+val5b*cap_bd) / 6.0d0
      volc = (val2*cap_ac+val4*cap_bc+val6b*cap_cd) / 6.0d0
      vold = (val3*cap_ad+val5*cap_bd+val6*cap_cd) / 6.0d0
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine twosphere_dsurf  --  two sphere area derivs  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "twosphere_dsurf" calculates the surface area of intersection
c     of two spheres; also computes the derivatives of the surface
c     area with respect to the distance between the sphere centers
c
c     note this version uses only the radii of the spheres and the
c     distance between their centers
c
c     variables and parameters:
c
c     rab        distance between the centers of the spheres
c     rab2       distance squared between the sphere centers
c     ra,rb      radii of spheres A and B, respectively
c     ra2,rb2    radii squared of the two spheres 
c     option     set to 1 to compute derivatives, or 0 if not
c     surfa      partial contribution of A to the total
c                  surface area of the intersection
c     surfb      partial contribution of B to the total
c                  surface area of the intersection
c     dsurfa     derivative of surfa with respect to rab
c     dsurfb     derivative of surfb with respect to rab
c
c
      subroutine twosphere_dsurf (ra,ra2,rb,rb2,rab,rab2,surfa,
     &                            surfb,dsurfa,dsurfb,option)
      use math
      implicit none
      integer option
      real*8 ra,rb
      real*8 surfa,surfb
      real*8 dsurfa,dsurfb
      real*8 vala,valb
      real*8 ra2,rb2
      real*8 rab,rab2
      real*8 ha,hb,lambda
      real*8 dera,derb
      save
c
c
c     get distance between center of sphere A and the Voronoi
c     plane between A and B
c
      call plane_dist (ra2,rb2,rab2,lambda)
      valb = lambda * rab
      vala = rab - valb
c
c     find height of the cap of sphere A occluded by sphere B
c
      ha = ra - vala
c
c     find height of the cap of sphere B occluded by sphere A
c
      hb = rb - valb
c
c     compute the surface areas of intersection
c
      surfa = twopi * ra * ha
      surfb = twopi * rb * hb
      if (option .ne. 1)  return
c
c     compute the accessible surface area derivatives
c
      dera = -lambda
      derb = lambda - 1.0d0
      dsurfa = twopi * ra * dera
      dsurfb = twopi * rb * derb
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine twosphere_dvol  --  two sphere volume derivs  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "twosphere_dvol" finds the volume of intersection of two balls
c     and the corresponding surface area of intersection; also finds
c     derivatives of the surface area and volume with respect to the
c     distance between the two centers
c
c     variables and parameters:
c
c     rab        distance between the centers of the spheres
c     rab2       distance squared between the sphere centers
c     ra,rb      radii of spheres A and B, respectively
c     ra2,rb2    radii squared of spheres A and B
c     option     set to 1 to compute derivatives, or 0 if not
c     surfa      partial contribution of A to the total
c                  surface area of the intersection
c     surfb      partial contribution of B to the total
c                  surface area of the intersection
c     vola       partial contribution of A to the total
c                  volume of the intersection
c     volb       partial contribution of B to the total
c                  volume of the intersection
c     dsurfa     derivative of surfa with respect to rab
c     dsurfb     derivative of surfb with respect to rab
c     dvola      derivative of vola with respect to rab
c     dvolb      derivative of volb with respect to rab
c
c
      subroutine twosphere_dvol (ra,ra2,rb,rb2,rab,rab2,surfa,surfb,
     &                           vola,volb,dsurfa,dsurfb,dvola,dvolb,
     &                           option)
      use math
      implicit none
      integer option
      real*8 ra,rb
      real*8 surfa,surfb
      real*8 vola,volb
      real*8 dsurfa,dsurfb
      real*8 dvola,dvolb
      real*8 vala,valb,lambda
      real*8 ra2,rb2,rab,rab2
      real*8 ha,hb,sa,ca,sb,cb
      real*8 dera,derb,aab
      save
c
c
c     get distance between center of sphere A and the Voronoi
c     plane between A and B
c
      call plane_dist (ra2,rb2,rab2,lambda)
      valb = lambda * rab
      vala = rab - valb
c
c     find height of the cap of sphere A occluded by sphere B
c
      ha = ra - vala
c
c     find height of the cap of sphere B occluded by sphere A
c
      hb = rb - valb
c
c     compute the surface areas of intersection
c
      surfa = twopi * ra * ha
      surfb = twopi * rb * hb
c
c     next get the volumes of intersection
c
      aab = pi * (ra2-vala*vala)
      sa = ra * surfa
      ca = vala * aab
      vola = (sa-ca) / 3.0d0
      sb = rb * surfb
      cb = valb * Aab
      volb = (sb-cb) / 3.0d0
      if (option .ne. 1)  return
c
c     compute the surface area and volume derivatives
c
      dera = -lambda
      derb = lambda - 1.0d0
      dsurfa = twopi * ra * dera
      dsurfb = twopi * rb * derb
      dvola = -aab * lambda
      dvolb = -dvola - Aab
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine threesphere_dsurf  --  three sphere area derivs  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "threesphere_dsurf" computes the surface area of intersection 
c     of three spheres A, B and C; also computes the derivatives of
c     the surface area with respect to the distances rAB, rAC and rBC
c
c     variables and parameters:
c
c     ra,rb,rc       radii of the spheres A, B and C
c     ra2,rb2,rc2    radii squared of the spheres A, B and C
c     rab,rab2       distance and square between spheres A and B
c     rac,rac2       distance and square between spheres A and C
c     rbc,rbc2       distance and square between spheres B and C
c     option         set to 1 to compute derivatives, or 0 if not
c     surfa,surfb,   contribution of A, B and C to total surface
c       surfc          of the intersection of A, B and C
c     dsurfa         derivatives of surfa over rAB, rAC and rBC
c     dsurfb         derivatives of surfb over rAB, rAC and rBC
c     dsurfc         derivatives of surfc over rAB, rAC and rBC
c
c
      subroutine threesphere_dsurf (ra,rb,rc,ra2,rb2,rc2,rab,rac,rbc,
     &                              rab2,rac2,rbc2,surfa,surfb,surfc,
     &                              dsurfa,dsurfb,dsurfc,option)
      use math
      implicit none
      integer option
      real*8 surfa,surfb,surfc
      real*8 ra,rb,rc
      real*8 rab,rac,rbc
      real*8 rab2,rac2,rbc2
      real*8 ra2,rb2,rc2
      real*8 a1,a2,a3
      real*8 seg_ang_ab,seg_ang_ac
      real*8 seg_ang_bc
      real*8 ang_dih_ap,ang_dih_bp
      real*8 ang_dih_cp
      real*8 val1,val2,val3,l1,l2,l3
      real*8 val1b,val2b,val3b
      real*8 der_val1b,der_val1,der_val2b
      real*8 der_val2,der_val3b,der_val3
      real*8 angle(6),cosine(6),sine(6)
      real*8 dsurfa(3),dsurfb(3),dsurfc(3)
      real*8 deriv(6,3)
      save
c
c
      call plane_dist (ra2,rb2,rab2,l1)
      call plane_dist (ra2,rc2,rac2,l2)
      call plane_dist (rb2,rc2,rbc2,l3)
      val1 = l1 * rab
      val2 = l2 * rac
      val3 = l3 * rbc
      val1b = rab - val1
      val2b = rac - val2
      val3b = rbc - val3
c
c     consider tetrahedron (A,B,C,P) where P is the intersection point
c     of the three spheres such that (A,B,C,P) is counter-clockwise
c
c     the edge lengths in this tetrahedron are rab, rac, rAP=ra, rbc,
c     rBP=rb and rCP=rc
c
      call tetra_dihed_der3 (rab2,rac2,ra2,rbc2,rb2,rc2,
     &                       angle,cosine,sine,deriv,option)
c
c     the seg_ang_ values are the dihedral angles around the three
c     edges AB, AC and BC
c
      seg_ang_ab = angle(1)
      seg_ang_ac = angle(2)
      seg_ang_bc = angle(4)
c
c     the ang_dih_ values are the dihedral angles around the three
c     edges AP, BP and CP
c
      ang_dih_ap = angle(3)
      ang_dih_bp = angle(5)
      ang_dih_cp = angle(6)
      a1 = ra * (1.0d0-2.0d0*ang_dih_ap)
      a2 = 2.0d0 * seg_ang_ab * val1b
      a3 = 2.0d0 * seg_ang_ac * val2b
      surfa = twopi * ra * (a1-a2-a3)
      a1 = rb * (1.0d0-2.0d0*ang_dih_bp)
      a2 = 2.0d0 * seg_ang_ab * val1
      a3 = 2.0d0 * seg_ang_bc * val3b
      surfb = twopi * rb * (a1-a2-a3)
      a1 = rc * (1.0d0-2.0d0*ang_dih_cp)
      a2 = 2.0d0 * seg_ang_ac * val2
      a3 = 2.0d0 * seg_ang_bc * val3
      surfc = twopi * rc * (a1-a2-a3)
      if (option .ne. 1)  return
c
c     compute the accessible surface area derivatives
c
      der_val1b = l1
      der_val1 = 1.0d0 - l1
      der_val2b = l2
      der_val2 = 1.0d0 - l2
      der_val3b = l3
      der_val3 = 1.0d0 - l3
      dsurfa(1) = -2.0d0 * ra * (twopi*seg_ang_ab*der_val1b
     &               + 2.0d0*rab*(ra*deriv(3,1)+val1b*deriv(1,1)
     &                               +val2b*deriv(2,1)))
      dsurfa(2) = -2.0d0 * ra * (twopi*seg_ang_ac*der_val2b
     &               + 2.0d0*rac*(ra*deriv(3,2)+val1b*deriv(1,2)
     &                               +val2b*deriv(2,2)))
      dsurfa(3) = ra * (-4.0d0*rbc*(ra*deriv(3,3)+val1b*deriv(1,3)
     &                                 +val2b*deriv(2,3)))
      dsurfb(1) = -2.0d0 * rb * (twopi*seg_ang_ab*der_val1
     &               +2.0d0*rab*(rb*deriv(5,1)+val1*deriv(1,1)
     &                              +val3b*deriv(4,1)))
      dsurfb(2) = rb * (-4.0d0*rac*(rb*deriv(5,2)+val1*deriv(1,2)
     &                                 +val3b*deriv(4,2)))
      dsurfb(3) = -2.0d0 * rb * (twopi*seg_ang_bc*der_val3b
     &               +2.0d0*rbc*(rb*deriv(5,3)+val1*deriv(1,3)
     &                              +val3b*deriv(4,3)))
      dsurfc(1) = rc * (-4.0d0*rab*(rc*deriv(6,1)+val2*deriv(2,1)
     &                                 +val3*deriv(4,1)))
      dsurfc(2) = -2.0d0 * rc * (twopi*seg_ang_ac*der_val2
     &               +2.0d0*rac*(rc*deriv(6,2)+val2*deriv(2,2)
     &                              +val3*deriv(4,2)))
      dsurfc(3) = -2.0d0 * rc * (twopi*seg_ang_bc*der_val3
     &               +2.0d0*rbc*(rc*deriv(6,3)+val2*deriv(2,3)
     &                              +val3*deriv(4,3)))
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine threesphere_dvol  --  three sphere volume deriv  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "threesphere_dvol" calculates the volume of the intersection of
c     three balls as well as the surface area of intersection of the
c     corresponding three spheres
c
c     variables and parameters:
c
c     ra,rb,rc       radii of spheres A, B and C
c     ra2,rb2,rc2    radii squared of spheres A, B and C
c     rab,rab2       distance and square between spheres A and B
c     rac,rac2       distance and square between spheres A and C
c     rbc,rbc2       distance and square between spheres B and C
c     surfa,surfb,   contribution of A, B and C to total surface of
c       surfc          the intersection of A, B and C
c     vola,volb,     contribution of A, B and C to total volume of
c       volc           the intersection of A, B and C
c
c
      subroutine threesphere_dvol (ra,rb,rc,ra2,rb2,rc2,rab,rac,rbc,
     &                             rab2,rac2,rbc2,surfa,surfb,surfc,
     &                             vola,volb,volc,dsurfa,dsurfb,dsurfc,
     &                             dvola,dvolb,dvolc,option)
      use math
      implicit none
      integer option
      real*8 surfa,surfb,surfc
      real*8 vola,volb,volc
      real*8 ra,rb,rc
      real*8 rab,rac,rbc
      real*8 rab2,rac2,rbc2
      real*8 ra2,rb2,rc2
      real*8 a1,a2,a3,s2,c1,c2
      real*8 seg_ang_ab,seg_ang_ac
      real*8 seg_ang_bc
      real*8 ang_dih_ap,ang_dih_bp
      real*8 ang_dih_cp
      real*8 ang_abc,ang_acb,ang_bca
      real*8 cos_abc,cos_acb,cos_bca
      real*8 sin_abc,sin_acb,sin_bca
      real*8 s_abc,s_acb,s_bca
      real*8 val1,val2,val3,l1,l2,l3
      real*8 val1b,val2b,val3b
      real*8 rho_ab2,rho_ac2,rho_bc2
      real*8 drho_ab2,drho_ac2,drho_bc2
      real*8 val_abc,val_acb,val_bca
      real*8 val2_abc,val2_acb,val2_bca
      real*8 der_val1b,der_val2b,der_val3b
      real*8 der_val1,der_val2,der_val3
      real*8 angle(6),cosine(6),sine(6)
      real*8 dsurfa(3),dsurfb(3),dsurfc(3)
      real*8 dvola(3),dvolb(3),dvolc(3)
      real*8 deriv(6,3)
      save
c
c
      call plane_dist (ra2,rb2,rab2,l1)
      call plane_dist (ra2,rc2,rac2,l2)
      call plane_dist (rb2,rc2,rbc2,l3)
      val1 = l1 * rab
      val2 = l2 * rac
      val3 = l3 * rbc
      val1b = rab - val1
      val2b = rac - val2
      val3b = rbc - val3
c
c     consider tetrahedron (A,B,C,P) where P is the intersection point
c     of the three spheres such that (A,B,C,P) is counter-clockwise
c
c     the edge lengths in this tetrahedron are rab, rac, rAP=ra, rbc,
c     rBP=rb and rCP=rc
c
      call tetra_dihed_der3 (rab2,rac2,ra2,rbc2,rb2,rc2,
     &                       angle,cosine,sine,deriv,option)
c
c     the seg_ang_ values are the dihedral angles around the three
c     edges AB, AC and BC
c
      seg_ang_ab = angle(1)
      seg_ang_ac = angle(2)
      seg_ang_bc = angle(4)
c
c     the ang_dih_ values are the dihedral angles around the three
c     edges AP, BP and CP
c
      ang_dih_ap = angle(3)
      ang_dih_bp = angle(5)
      ang_dih_cp = angle(6)
      a1 = ra * (1.0d0-2.0d0*ang_dih_ap)
      a2 = 2.0d0 * seg_ang_ab * val1b
      a3 = 2.0d0 * seg_ang_ac * val2b
      surfa = twopi * ra * (a1-a2-a3)
      a1 = rb * (1.0d0-2.0d0*ang_dih_bp)
      a2 = 2.0d0 * seg_ang_ab * val1
      a3 = 2.0d0 * seg_ang_bc * val3b
      surfb = twopi * rb * (a1-a2-a3)
      a1 = rc * (1.0d0-2.0d0*ang_dih_cp)
      a2 = 2.0d0 * seg_ang_ac * val2
      a3 = 2.0d0 * seg_ang_bc * val3
      surfc = twopi * rc * (a1-a2-a3)
      ang_abc = twopi * seg_ang_ab
      ang_acb = twopi * seg_ang_ac
      ang_bca = twopi * seg_ang_bc
      cos_abc = cosine(1)
      sin_abc = sine(1)
      cos_acb = cosine(2)
      sin_acb = sine(2)
      cos_bca = cosine(4)
      sin_bca = sine(4)
      rho_ab2 = ra2 - val1b*val1b
      rho_ac2 = ra2 - val2b*val2b
      rho_bc2 = rb2 - val3b*val3b
      val_abc = ang_abc - sin_abc*cos_abc
      val_acb = ang_acb - sin_acb*cos_acb
      val_bca = ang_bca - sin_bca*cos_bca
      s_abc = rho_ab2 * val_abc
      s_acb = rho_ac2 * val_acb
      s_bca = rho_bc2 * val_bca
      s2 = ra * surfa
      c1 = val1b * s_abc
      c2 = val2b * s_acb
      vola = (s2-c1-c2) / 3.0d0
      s2 = rb * surfb
      c1 = val1 * s_abc
      c2 = val3b * s_bca
      volb = (s2-c1-c2) / 3.0d0
      s2 = rc * surfc
      c1 = val2 * s_acb
      c2 = val3 * s_bca
      volc = (s2-c1-c2) / 3.0d0
      if (option .ne. 1)  return
c
c     compute the accessible surface area derivatives
c
      der_val1b = l1
      der_val1 = 1.0d0 - l1
      der_val2b = l2
      der_val2 = 1.0d0 - l2
      der_val3b = l3
      der_val3 = 1.0d0 - l3
      drho_ab2 = -2.0d0 * der_val1b * val1b
      drho_ac2 = -2.0d0 * der_val2b * val2b
      drho_bc2 = -2.0d0 * der_val3b * val3b
      dsurfa(1) = -2.0d0 * ra * (twopi*seg_ang_ab*der_val1b
     &               + 2.0d0*rab*(ra*deriv(3,1)+val1b*deriv(1,1)
     &                               +val2b*deriv(2,1)))
      dsurfa(2) = -2.0d0 * ra * (twopi*seg_ang_ac*der_val2b
     &               + 2.0d0*rac*(ra*deriv(3,2)+val1b*deriv(1,2)
     &                               +val2b*deriv(2,2)))
      dsurfa(3) = ra * (-4.0d0*rbc*(ra*deriv(3,3)+val1b*deriv(1,3)
     &                                 +val2b*deriv(2,3)))
      dsurfb(1) = -2.0d0 * rb * (twopi*seg_ang_ab*der_val1
     &               +2.0d0*rab*(rb*deriv(5,1)+val1*deriv(1,1)
     &                              +val3b*deriv(4,1)))
      dsurfb(2) = rb * (-4.0d0*rac*(rb*deriv(5,2)+val1*deriv(1,2)
     &                                 +val3b*deriv(4,2)))
      dsurfb(3) = -2.0d0 * rb * (twopi*seg_ang_bc*der_val3b
     &               +2.0d0*rbc*(rb*deriv(5,3)+val1*deriv(1,3)
     &                              +val3b*deriv(4,3)))
      dsurfc(1) = rc * (-4.0d0*rab*(rc*deriv(6,1)+val2*deriv(2,1)
     &                                 +val3*deriv(4,1)))
      dsurfc(2) = -2.0d0 * rc * (twopi*seg_ang_ac*der_val2
     &               +2.0d0*rac*(rc*deriv(6,2)+val2*deriv(2,2)
     &                              +val3*deriv(4,2)))
      dsurfc(3) = -2.0d0 * rc * (twopi*seg_ang_bc*der_val3
     &               +2.0d0*rbc*(rc*deriv(6,3)+val2*deriv(2,3)
     &                              +val3*deriv(4,3)))
c
c     compute the excluded volume derivatives
c
      val2_abc = rho_ab2 * (1.0d0-cos_abc*cos_abc+sin_abc*sin_abc)
      val2_acb = rho_ac2 * (1.0d0-cos_acb*cos_acb+sin_acb*sin_acb)
      val2_bca = rho_bc2 * (1.0d0-cos_bca*cos_bca+sin_bca*sin_bca)
      dvola(1) = ra*dsurfa(1) - der_val1b*s_abc
     &              - 2.0d0*rab*(val1b*deriv(1,1)*val2_abc
     &                          +val2b*deriv(2,1)*val2_acb)
     &              - val1b*drho_ab2*val_abc
      dvola(1) = dvola(1) / 3.0d0
      dvola(2) = ra*dsurfa(2) - der_val2b*s_acb
     &              - 2.0d0*rac*(val1b*deriv(1,2)*val2_abc
     &                          +val2b*deriv(2,2)*val2_acb)
     &              - val2b*drho_ac2*val_acb
      dvola(2) = dvola(2) / 3.0d0
      dvola(3) = ra*dsurfa(3) - 2.0d0*rbc*(val1b*deriv(1,3)*val2_abc
     &                                    +val2b*deriv(2,3)*val2_acb)
      dvola(3) = dvola(3) / 3.0d0
      dvolb(1) = rb*dsurfb(1) - der_val1*s_abc
     &              - 2.0d0*rab*(val1*deriv(1,1)*val2_abc
     &                          +val3b*deriv(4,1)*val2_bca)
     &              - val1*drho_ab2*val_abc
      dvolb(1) = dvolb(1) / 3.0d0
      dvolb(2) = rb*dsurfb(2) - 2.0d0*rac*(val1*deriv(1,2)*val2_abc
     &                                    +val3b*deriv(4,2)*val2_bca)
      dvolb(2) = dvolb(2) / 3.0d0
      dvolb(3) = rb*dsurfb(3) - der_val3b*s_bca
     &              - 2.0d0*rbc*(val1*deriv(1,3)*val2_abc
     &                         + val3b*deriv(4,3)*val2_bca)
     &              - val3b*drho_bc2*val_bca
      dvolb(3) = dvolb(3) / 3.0d0
      dvolc(1) = rc*dsurfc(1) - 2.0d0*rab*(val2*deriv(2,1)*val2_acb
     &                                    +val3*deriv(4,1)*val2_bca)
      dvolc(1) = dvolc(1) / 3.0d0
      dvolc(2) = rc*dsurfc(2) - der_val2*s_acb
     &              - 2.0d0*rac*(val2*deriv(2,2)*val2_acb
     &                          +val3*deriv(4,2)*val2_bca)
     &              - val2*drho_ac2*val_acb
      dvolc(2) = dvolc(2) / 3.0d0
      dvolc(3) = rc*dsurfc(3) - der_val3*s_bca
     &              - 2.0d0*rbc*(val2*deriv(2,3)*val2_acb
     &                          +val3*deriv(4,3)*val2_bca)
     &              - val3*drho_bc2*val_bca
      dvolc(3) = dvolc(3) / 3.0d0
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine tetra_voronoi_der  --  four sphere volume deriv  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "tetra_voronoi_der" computes the volume of the intersection
c     of the tetrahedron formed by the center of four balls with the
c     Voronoi cells corresponding to these balls; also computes the
c     derivatives of these volumes with respect to the edge lengths;
c     only computed if the four balls have a common intersection
c
c     variables and parameters:
c
c     ra,rb,rc,rd        radii of the four balls
c     ra2,rb2,rc2,rd2    radii squared of the four balls
c     rab,rac,rad,       distance between pairs of balls
c       rbc,rbd,rcd
c     rab2,rac2,rad2,    distance squared between pairs of balls
c       rbc2,rbd2,rcd2
c     cos_ang            cosine of the six tetrahedral dihedral angles
c     sin_ang            sine of the six tetrahedral dihedral angles
c     deriv              derivatives of the six dihedral angles
c                          with respect to edge lengths
c     vola,volb,         fraction of the volume of the tetrahedron
c       volc,vold          corresponding to balls a, b, c and d
c     dvola              derivatives of vola wrt the six edge lengths
c     dvolb              derivatives of volb wrt the six edge lengths
c     dvolc              derivatives of volc wrt the six edge lengths
c     dvold              derivatives of vold wrt the six edge lengths
c
c
      subroutine tetra_voronoi_der (ra2,rb2,rc2,rd2,rab,rac,rad,rbc,
     &                              rbd,rcd,rab2,rac2,rad2,rbc2,rbd2,
     &                              rcd2,cos_ang,sin_ang,deriv,vola,
     &                              volb,volc,vold,dvola,dvolb,dvolc,
     &                              dvold,option)
      implicit none
      integer i,j,option
      real*8 ra2,rb2,rc2,rd2
      real*8 rab,rac,rad
      real*8 rbc,rbd,rcd
      real*8 rab2,rac2,rad2
      real*8 rbc2,rbd2,rcd2
      real*8 vola,volb,volc,vold
      real*8 l1,l2,l3,l4,l5,l6
      real*8 val1,val2,val3
      real*8 val4,val5,val6
      real*8 val1b,val2b,val3b
      real*8 val4b,val5b,val6b
      real*8 cos_abc,cos_acb,cos_bca
      real*8 cos_abd,cos_adb,cos_bda
      real*8 cos_acd,cos_adc,cos_cda
      real*8 cos_bcd,cos_bdc,cos_cdb
      real*8 rho_ab2,rho_ac2,rho_ad2
      real*8 rho_bc2,rho_bd2,rho_cd2
      real*8 drho_ab2,drho_ac2,drho_ad2
      real*8 drho_bc2,drho_bd2,drho_cd2
      real*8 dval1,dval2,dval3
      real*8 dval4,dval5,dval6
      real*8 dval1b,dval2b,dval3b
      real*8 dval4b,dval5b,dval6b
      real*8 val_ab,val_ac,val_ad
      real*8 val_bc,val_bd,val_cd
      real*8 val1_ab,val1_ac,val1_ad
      real*8 val1_bc,val1_bd,val1_cd
      real*8 val2_ab,val2_ac,val2_ad
      real*8 val2_bc,val2_bd,val2_cd
      real*8 cap_ab,cap_ac,cap_ad
      real*8 cap_bc,cap_bd,cap_cd
      real*8 eps,tetvol,teteps
      real*8 dist(6),invsin(6),cotan(6)
      real*8 cosine_abc(3),cosine_abd(3)
      real*8 cosine_acd(3),cosine_bcd(3)
      real*8 cos_ang(6),sin_ang(6)
      real*8 deriv(6,6)
      real*8 deriv_abc(3,3),deriv_abd(3,3)
      real*8 deriv_acd(3,3),deriv_bcd(3,3)
      real*8 dinvsin(6,6),dcotan(6,6)
      real*8 dval1_ab(6),dval1_ac(6)
      real*8 dval1_ad(6),dval1_bc(6)
      real*8 dval1_bd(6),dval1_cd(6)
      real*8 dval2_ab(6),dval2_ac(6)
      real*8 dval2_ad(6),dval2_bc(6)
      real*8 dval2_bd(6),dval2_cd(6)
      real*8 dcap_ab(6),dcap_ac(6)
      real*8 dcap_ad(6),dcap_bc(6)
      real*8 dcap_bd(6),dcap_cd(6)
      real*8 dvola(6),dvolb(6)
      real*8 dvolc(6),dvold(6)
      save
c
c
      call plane_dist (ra2,rb2,rab2,l1)
      call plane_dist (ra2,rc2,rac2,l2)
      call plane_dist (ra2,rd2,rad2,l3)
      call plane_dist (rb2,rc2,rbc2,l4)
      call plane_dist (rb2,rd2,rbd2,l5)
      call plane_dist (rc2,rd2,rcd2,l6)
      val1 = l1 * rab
      val2 = l2 * rac
      val3 = l3 * rad
      val4 = l4 * rbc
      val5 = l5 * rbd
      val6 = l6 * rcd
      val1b = rab - val1
      val2b = rac - val2
      val3b = rad - val3
      val4b = rbc - val4
      val5b = rbd - val5
      val6b = rcd - val6
c
c     consider the tetrahedron (A,B,C,P_ABC) where P_ABC is the
c     point of intersection of the three spheres so that (A,B,C,P_ABC)
c     is counter-clockwise; the edge lengths for this tetrahedron are
c     rab, rac, rAP=ra, rbc, rBP=rb and rCP=rc
c
      call tetra_3dihed_dcos (rab2,rac2,ra2,rbc2,rb2,rc2,
     &                        cosine_abc,deriv_abc,option)
c
c     repeat the above for tetrahedron (A,B,D,P_ABD)
c
      call tetra_3dihed_dcos (rab2,rad2,ra2,rbd2,rb2,rd2,
     &                        cosine_abd,deriv_abd,option)
c
c     repeat the above for tetrahedron (A,C,D,P_ACD)
c
      call tetra_3dihed_dcos (rac2,rad2,ra2,rcd2,rc2,rd2,
     &                        cosine_acd,deriv_acd,option)
c
c     repeat the above for tetrahedron (B,C,D,P_BCD)
c
      call tetra_3dihed_dcos (rbc2,rbd2,rb2,rcd2,rc2,rd2,
     &                        cosine_bcd,deriv_bcd,option)
c
      cos_abc = cosine_abc(1)
      cos_acb = cosine_abc(2)
      cos_bca = cosine_abc(3)
      cos_abd = cosine_abd(1)
      cos_adb = cosine_abd(2)
      cos_bda = cosine_abd(3)
      cos_acd = cosine_acd(1)
      cos_adc = cosine_acd(2)
      cos_cda = cosine_acd(3)
      cos_bcd = cosine_bcd(1)
      cos_bdc = cosine_bcd(2)
      cos_cdb = cosine_bcd(3)
      rho_ab2 = ra2 - val1b*val1b
      rho_ac2 = ra2 - val2b*val2b
      rho_ad2 = ra2 - val3b*val3b
      rho_bc2 = rb2 - val4b*val4b
      rho_bd2 = rb2 - val5b*val5b
      rho_cd2 = rc2 - val6b*val6b
      eps = 1.0d-14
      do i = 1, 6
         if (abs(sin_ang(i)) < eps) then
            invsin(i) = 0.0d0;
            cotan(i) = 0.0d0;
         else
            invsin(i) = 1.0d0 / sin_ang(i)
            cotan(i) = cos_ang(i) * invsin(i)
         end if
      end do
      val_ab = -(cos_abc*cos_abc+cos_abd*cos_abd)*cotan(1)
     &            + 2.0d0*cos_abc*cos_abd*invsin(1)
      val_ac = -(cos_acb*cos_acb+cos_acd*cos_acd)*cotan(2)
     &            + 2.0d0*cos_acb*cos_acd*invsin(2)
      val_ad = -(cos_adb*cos_adb+cos_adc*cos_adc)*cotan(3)
     &            + 2.0d0*cos_adb*cos_adc*invsin(3)
      val_bc = -(cos_bca*cos_bca+cos_bcd*cos_bcd)*cotan(4)
     &            + 2.0d0*cos_bca*cos_bcd*invsin(4)
      val_bd = -(cos_bda*cos_bda+cos_bdc*cos_bdc)*cotan(5)
     &            + 2.0d0*cos_bda*cos_bdc*invsin(5)
      val_cd = -(cos_cda*cos_cda+cos_cdb*cos_cdb)*cotan(6)
     &            + 2.0d0*cos_cda*cos_cdb*invsin(6)
      cap_ab = rho_ab2 * val_ab
      cap_ac = rho_ac2 * val_ac
      cap_ad = rho_ad2 * val_ad
      cap_bc = rho_bc2 * val_bc
      cap_bd = rho_bd2 * val_bd
      cap_cd = rho_cd2 * val_cd
      vola = (val1b*cap_ab+val2b*cap_ac+val3b*cap_ad) / 6.0d0
      volb = (val1*cap_ab+val4b*cap_bc+val5b*cap_bd) / 6.0d0
      volc = (val2*cap_ac+val4*cap_bc+val6b*cap_cd) / 6.0d0
      vold = (val3*cap_ad+val5*cap_bd+val6*cap_cd) / 6.0d0
      if (option .ne. 1)  return
      do i = 1, 6
         dvola(i) = 0.0d0
         dvolb(i) = 0.0d0
         dvolc(i) = 0.0d0
         dvold(i) = 0.0d0
      end do
      teteps = 1.0d-5
      call tetra_volume (rab2,rac2,rad2,rbc2,rbd2,rcd2,tetvol)
      if (tetvol .lt. teteps)  return
      dist(1) = rab
      dist(2) = rac
      dist(3) = rad
      dist(4) = rbc
      dist(5) = rbd
      dist(6) = rcd
      dval1b = l1
      dval2b = l2
      dval3b = l3
      dval4b = l4
      dval5b = l5
      dval6b = l6
      dval1 = 1.0d0 - l1
      dval2 = 1.0d0 - l2
      dval3 = 1.0d0 - l3
      dval4 = 1.0d0 - l4
      dval5 = 1.0d0 - l5
      dval6 = 1.0d0 - l6
      drho_ab2 = -2.0d0 * dval1b * val1b
      drho_ac2 = -2.0d0 * dval2b * val2b
      drho_ad2 = -2.0d0 * dval3b * val3b
      drho_bc2 = -2.0d0 * dval4b * val4b
      drho_bd2 = -2.0d0 * dval5b * val5b
      drho_cd2 = -2.0d0 * dval6b * val6b
c
      do i = 1, 6
         do j = 1, 6
            dcotan(i,j) = -deriv(i,j) * (1.0d0+cotan(i)*cotan(i))
            dinvsin(i,j) = -deriv(i,j) * cotan(i) * invsin(i)
         end do
      end do
      val1_ab = cos_abc*cos_abc + cos_abd*cos_abd
      val2_ab = 2.0d0 * cos_abc * cos_abd
      dval1_ab(1) = 2.0d0 * (deriv_abc(1,1)*cos_abc
     &                          +deriv_abd(1,1)*cos_abd)
      dval1_ab(2) = 2.0d0 * deriv_abc(1,2) * cos_abc
      dval1_ab(3) = 2.0d0 * deriv_abd(1,2) * cos_abd
      dval1_ab(4) = 2.0d0 * deriv_abc(1,3) * cos_abc
      dval1_ab(5) = 2.0d0 * deriv_abd(1,3) * cos_abd
      dval1_ab(6) = 0.0d0
      dval2_ab(1) = 2.0d0 * (deriv_abc(1,1)*cos_abd
     &                          +deriv_abd(1,1)*cos_abc)
      dval2_ab(2) = 2.0d0 * deriv_abc(1,2) * cos_abd
      dval2_ab(3) = 2.0d0 * deriv_abd(1,2) * cos_abc
      dval2_ab(4) = 2.0d0 * deriv_abc(1,3) * cos_abd
      dval2_ab(5) = 2.0d0 * deriv_abd(1,3) * cos_abc
      dval2_ab(6) = 0.0d0
c
      do i = 1, 6
         dcap_ab(i) = -dval1_ab(i)*cotan(1) - val1_ab*dcotan(1,i)
     &                   + dval2_ab(i)*invsin(1) + val2_ab*dinvsin(1,i)
         dcap_ab(i) = 2.0d0 * dist(i) * rho_ab2 * dcap_ab(i)
      end do
      dcap_ab(1) = dcap_ab(1) + drho_ab2*val_ab
      val1_ac = cos_acb*cos_acb + cos_acd*cos_acd
      val2_ac = 2.0d0 * cos_acb * cos_acd
      dval1_ac(1) = 2.0d0 * deriv_abc(2,1) * cos_acb
      dval1_ac(2) = 2.0d0 * (deriv_abc(2,2)*cos_acb
     &                          +deriv_acd(1,1)*cos_acd)
      dval1_ac(3) = 2.0d0 * deriv_acd(1,2) * cos_acd
      dval1_ac(4) = 2.0d0 * deriv_abc(2,3) * cos_acb
      dval1_ac(5) = 0.0d0
      dval1_ac(6) = 2.0d0 * deriv_acd(1,3) * cos_acd
      dval2_ac(1) = 2.0d0 * deriv_abc(2,1) * cos_acd
      dval2_ac(2) = 2.0d0 * (deriv_abc(2,2)*cos_acd
     &                          +deriv_acd(1,1)*cos_acb)
      dval2_ac(3) = 2.0d0 * deriv_acd(1,2) * cos_acb
      dval2_ac(4) = 2.0d0 * deriv_abc(2,3) * cos_acd
      dval2_ac(5) = 0.0d0
      dval2_ac(6) = 2.0d0 * deriv_acd(1,3) * cos_acb
c
      do i = 1, 6
         dcap_ac(i) = -dval1_ac(i)*cotan(2) - val1_ac*dcotan(2,i)
     &                   + dval2_ac(i)*invsin(2) + val2_ac*dinvsin(2,i)
         dcap_ac(i) = 2.0d0 * dist(i) * rho_ac2 * dcap_ac(i)
      end do
      dcap_ac(2) = dcap_ac(2) + drho_ac2*val_ac
      val1_ad = cos_adb*cos_adb + cos_adc*cos_adc
      val2_ad = 2.0d0 * cos_adb * cos_adc
      dval1_ad(1) = 2.0d0 * deriv_abd(2,1) * cos_adb
      dval1_ad(2) = 2.0d0 * deriv_acd(2,1) * cos_adc
      dval1_ad(3) = 2.0d0 * (deriv_abd(2,2)*cos_adb
     &                          +deriv_acd(2,2)*cos_adc)
      dval1_ad(4) = 0.0d0
      dval1_ad(5) = 2.0d0 * deriv_abd(2,3) * cos_adb
      dval1_ad(6) = 2.0d0 * deriv_acd(2,3) * cos_adc
      dval2_ad(1) = 2.0d0 * deriv_abd(2,1) * cos_adc
      dval2_ad(2) = 2.0d0 * deriv_acd(2,1) * cos_adb
      dval2_ad(3) = 2.0d0 * (deriv_abd(2,2)*cos_adc
     &                          +deriv_acd(2,2)*cos_adb)
      dval2_ad(4) = 0.0d0
      dval2_ad(5) = 2.0d0 * deriv_abd(2,3) * cos_adc
      dval2_ad(6) = 2.0d0 * deriv_acd(2,3) * cos_adb
c
      do i = 1, 6
         dcap_ad(i) = -dval1_ad(i)*cotan(3) - val1_ad*dcotan(3,i)
     &                   + dval2_ad(i)*invsin(3) + val2_ad*dinvsin(3,i)
         dcap_ad(i) = 2.0d0 * dist(i) * rho_ad2 * dcap_ad(i)
      end do
      dcap_ad(3) = dcap_ad(3) + drho_ad2*val_ad
      val1_bc = cos_bca*cos_bca + cos_bcd*cos_bcd
      val2_bc = 2.0d0 * cos_bca * cos_bcd
      dval1_bc(1) = 2.0d0 * deriv_abc(3,1) * cos_bca
      dval1_bc(2) = 2.0d0 * deriv_abc(3,2) * cos_bca
      dval1_bc(3) = 0.0d0
      dval1_bc(4) = 2.0d0 * (deriv_abc(3,3)*cos_bca
     &                          +deriv_bcd(1,1)*cos_bcd)
      dval1_bc(5) = 2.0d0 * deriv_bcd(1,2) * cos_bcd
      dval1_bc(6) = 2.0d0 * deriv_bcd(1,3) * cos_bcd
      dval2_bc(1) = 2.0d0 * deriv_abc(3,1) * cos_bcd
      dval2_bc(2) = 2.0d0 * deriv_abc(3,2) * cos_bcd
      dval2_bc(3) = 0.0d0
      dval2_bc(4) = 2.0d0 * (deriv_abc(3,3)*cos_bcd
     &                          +deriv_bcd(1,1)*cos_bca)
      dval2_bc(5) = 2.0d0 * deriv_bcd(1,2) * cos_bca
      dval2_bc(6) = 2.0d0 * deriv_bcd(1,3) * cos_bca
c
      do i = 1, 6
         dcap_bc(i) = -dval1_bc(i)*cotan(4) - val1_bc*dcotan(4,i)
     &                   + dval2_bc(i)*invsin(4) + val2_bc*dinvsin(4,i)
         dcap_bc(i) = 2.0d0 * dist(i) * rho_bc2 * dcap_bc(i)
      end do
      dcap_bc(4) = dcap_bc(4) + drho_bc2*val_bc
      val1_bd = cos_bda*cos_bda + cos_bdc*cos_bdc
      val2_bd = 2.0d0 * cos_bda * cos_bdc
      dval1_bd(1) = 2.0d0*deriv_abd(3,1)*cos_bda
      dval1_bd(2) = 0.0d0
      dval1_bd(3) = 2.0d0*deriv_abd(3,2)*cos_bda
      dval1_bd(4) = 2.0d0*deriv_bcd(2,1)*cos_bdc
      dval1_bd(5) = 2.0d0*(deriv_abd(3,3)*cos_bda
     &                        +deriv_bcd(2,2)*cos_bdc)
      dval1_bd(6) = 2.0d0*deriv_bcd(2,3)*cos_bdc
      dval2_bd(1) = 2.0d0*deriv_abd(3,1)*cos_bdc
      dval2_bd(2) = 0.0d0
      dval2_bd(3) = 2.0d0*deriv_abd(3,2)*cos_bdc
      dval2_bd(4) = 2.0d0*deriv_bcd(2,1)*cos_bda
      dval2_bd(5) = 2.0d0*(deriv_abd(3,3)*cos_bdc
     &                        +deriv_bcd(2,2)*cos_bda)
      dval2_bd(6) = 2.0d0*deriv_bcd(2,3)*cos_bda
c
      do i = 1, 6
         dcap_bd(i) = -dval1_bd(i)*cotan(5) - val1_bd*dcotan(5,i)
     &                   + dval2_bd(i)*invsin(5) + val2_bd*dinvsin(5,i)
         dcap_bd(i) = 2.0d0 * dist(i) * rho_bd2 * dcap_bd(i)
      end do
      dcap_bd(5) = dcap_bd(5) + drho_bd2*val_bd
      val1_cd = cos_cda*cos_cda + cos_cdb*cos_cdb
      val2_cd = 2.0d0 * cos_cda * cos_cdb
      dval1_cd(1) = 0.0d0
      dval1_cd(2) = 2.0d0 * deriv_acd(3,1) * cos_cda
      dval1_cd(3) = 2.0d0 * deriv_acd(3,2) * cos_cda
      dval1_cd(4) = 2.0d0 * deriv_bcd(3,1) * cos_cdb
      dval1_cd(5) = 2.0d0 * deriv_bcd(3,2) * cos_cdb
      dval1_cd(6) = 2.0d0 * (deriv_acd(3,3)*cos_cda
     &                          +deriv_bcd(3,3)*cos_cdb)
      dval2_cd(1) = 0.0d0
      dval2_cd(2) = 2.0d0 * deriv_acd(3,1) * cos_cdb
      dval2_cd(3) = 2.0d0 * deriv_acd(3,2) * cos_cdb
      dval2_cd(4) = 2.0d0 * deriv_bcd(3,1) * cos_cda
      dval2_cd(5) = 2.0d0 * deriv_bcd(3,2) * cos_cda
      dval2_cd(6) = 2.0d0 * (deriv_acd(3,3)*cos_cdb
     &                          +deriv_bcd(3,3)*cos_cda)
c
      do i = 1, 6
         dcap_cd(i) = -dval1_cd(i)*cotan(6) - val1_cd*dcotan(6,i)
     &                   + dval2_cd(i)*invsin(6) + val2_cd*dinvsin(6,i)
         dcap_cd(i) = 2.0d0*dist(i)*rho_cd2*dcap_cd(i)
      end do
      dcap_cd(6) = dcap_cd(6) +drho_cd2*val_cd
      do i = 1, 6
         dvola(i) = (val1b*dcap_ab(i) + val2b*dcap_ac(i)
     &                  + val3b*dcap_ad(i)) / 6.0d0
         dvolb(i) = (val1*dcap_ab(i) + val4b*dcap_bc(i)
     &                  + val5b*dcap_bd(i)) / 6.0d0
         dvolc(i) = (val2*dcap_ac(i) + val4*dcap_bc(i)
     &                  + val6b*dcap_cd(i)) / 6.0d0
         dvold(i) = (val3*dcap_ad(i) + val5*dcap_bd(i)
     &                  + val6*dcap_cd(i)) / 6.0d0
      end do
      dvola(1) = dvola(1) + dval1b*cap_ab/6.0d0
      dvola(2) = dvola(2) + dval2b*cap_ac/6.0d0
      dvola(3) = dvola(3) + dval3b*cap_ad/6.0d0
      dvolb(1) = dvolb(1) + dval1*cap_ab/6.0d0
      dvolb(4) = dvolb(4) + dval4b*cap_bc/6.0d0
      dvolb(5) = dvolb(5) + dval5b*cap_bd/6.0d0
      dvolc(2) = dvolc(2) + dval2*cap_ac/6.0d0
      dvolc(4) = dvolc(4) + dval4*cap_bc/6.0d0
      dvolc(6) = dvolc(6) + dval6b*cap_cd/6.0d0
      dvold(3) = dvold(3) + dval3*cap_ad/6.0d0
      dvold(5) = dvold(5) + dval5*cap_bd/6.0d0
      dvold(6) = dvold(6) + dval6*cap_cd/6.0d0
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine update_deriv  --  update distance derivatives  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "update_deriv" updates the derivatives of the surface or volume
c     with respect to distances, it takes into account the info from
c     three sphere/ball intersection
c
      subroutine update_deriv (dsurf,dera,derb,derc,coefa,coefb,
     &                            coefc,coef,idx1,idx2,idx3)
      implicit none
      integer i,idx1,idx2,idx3
      integer list(3)
      real*8 coefa,coefb,coefc,coef
      real*8 dera(3),derb(3),derc(3)
      real*8 dsurf(*)
c
c
      list(1) = idx1
      list(2) = idx2
      list(3) = idx3
      do i = 1, 3
         dsurf(list(i)) = dsurf(list(i))
     &                       + coef*(coefa*dera(i)+coefb*derb(i)
     &                                  +coefc*derc(i))
      end do
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine tetra_dihed  --  tetrahedron dihedral angles  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "tetra_dihed" computes the six dihedral angles of a tetrahedron
c     from its edge lengths
c
c     literature reference:
c
c     L. Yang and Z. Zeng, "Constructing a Tetrahedron with Prescribed
c     Heights and Widths", in F. Botana and T. Recio, Proceedings of
c     ADG2006, 203-211 (2007)
c
c     variables and parameters:
c
c     angle    dihedral angles as fraction of 2*pi
c     cosine   cosine of the dihedral angles
c     sine     sine of the dihedral angle
c
c     the tetrahedron is defined by its vertices A1, A2, A3 and A4,
c     the edge between vertex Ai and Aj has length Rij
c
c     if T1=(A2,A3,A4), T2=(A1,A3,A4), T3=(A1,A2,A4), T4=(A1,A2,A3),
c     the dihedral angle "angij" is between the faces Ti and Tj
c
c     input is r12sq,r13sq,r14sq,r23sq,r24sq,r34sq, where r12sq is
c     the square of the distance between A1 and A2, etc.
c
c     ang12 is the dihedral angle between (A2,A3,A4) and (A1,A3,A4),
c     and alpha12 is the dihedral angle around the edge A1A2, then
c     ang12=alpha34, ang13=alpha24, ang14=alpha23, ang23=alpha14,
c     ang24=alpha13 and ang34=alpha12
c
c     upon output the angles are in order: alpha12, alpha13, alpha14,
c     alpha23, alpha24, alpha34; the derivatives form a 6x6 matrix
c
c
      subroutine tetra_dihed (r12sq,r13sq,r14sq,r23sq,r24sq,
     &                           r34sq,angle,cosine,sine)
      use math
      implicit none
      integer i
      real*8 r12sq,r13sq,r14sq
      real*8 r23sq,r24sq,r34sq
      real*8 val1,val2,val3,val4
      real*8 val123,val124,val134
      real*8 val234,val213,val214
      real*8 val314,val324,val312
      real*8 det12,det13,det14
      real*8 det23,det24,det34
      real*8 cosine(6),sine(6),angle(6)
      real*8 minori(4)
c
c
c     the Cayley Menger matrix is defined as:
c
c     M = ( 0       r12^2   r13^2   r14^2   1 )
c         ( r12^2   0       r23^2   r24^2   1 )
c         ( r13^2   r23^2   0       r34^2   1 )
c         ( r14^2   r24^2   r34^2   0       1 )
c         ( 1       1       1       1       0 )
c
c     find all minors M(i,i) as determinants of the Cayley-Menger
c     matrix with row i and column j removed
c
c     these determinants are of the form:
c
c     det = | 0   a   b   1 |
c           | a   0   c   1 |
c           | b   c   0   1 |
c           | 1   1   1   0 |
c
c     then det = (c - a - b )^2 - 4ab
c
      val234 = r34sq - r23sq - r24sq
      val134 = r34sq - r14sq - r13sq
      val124 = r24sq - r12sq - r14sq
      val123 = r23sq - r12sq - r13sq
      minori(1) = val234*val234 - 4.0d0*r23sq*r24sq
      minori(2) = val134*val134 - 4.0d0*r13sq*r14sq
      minori(3) = val124*val124 - 4.0d0*r12sq*r14sq
      minori(4) = val123*val123 - 4.0d0*r12sq*r13sq
      val4 = 1.0d0 / sqrt(-minori(1))
      val3 = 1.0d0 / sqrt(-minori(2))
      val2 = 1.0d0 / sqrt(-minori(3))
      val1 = 1.0d0 / sqrt(-minori(4))
c
c     next compute all angles, as the cosine of the angle
c
c                (-1)^(i+j) * det(Mij) 
c     cos(i,j) = ---------------------
c                 sqrt(M(i,i)*M(j,j))
c
c     where det(Mij) = M(i,j) is the determinant of the Cayley-Menger
c     matrix with row i and column j removed
c
      det12 = -2.0d0*r12sq*val134 - val123*val124
      det13 = -2.0d0*r13sq*val124 - val123*val134
      det14 = -2.0d0*r14sq*val123 - val124*val134
      val213 = r13sq -r12sq -r23sq
      val214 = r14sq -r12sq -r24sq
      val312 = r12sq -r13sq -r23sq
      val314 = r14sq -r13sq -r34sq
      val324 = r24sq -r23sq -r34sq
      det23 = -2.0d0*r23sq*val214 - val213*val234
      det24 = -2.0d0*r24sq*val213 - val214*val234
      det34 = -2.0d0*r34sq*val312 - val314*val324
      cosine(1) = det12 * val1 * val2
      cosine(2) = det13 * val1 * val3
      cosine(3) = det14 * val2 * val3
      cosine(4) = det23 * val1 * val4
      cosine(5) = det24 * val2 * val4
      cosine(6) = det34 * val3 * val4
      do i = 1, 6
         if (cosine(i) > 1.0d0) then
            cosine(i) = 1.0d0
         else if (cosine(i) .lt. -1.0d0) then
            cosine(i) = -1.0d0
         end if
      end do
      do i = 1, 6
         angle(i) = acos(cosine(i))
         sine(i) = sin(angle(i))
         angle(i) = angle(i) / twopi
      end do
c
c     surface area of the four faces of the tetrahedron
c
c     surf_234 = sqrt(-minori(1)/16.0d0)
c     surf_134 = sqrt(-minori(2)/16.0d0)
c     surf_124 = sqrt(-minori(3)/16.0d0)
c     surf_123 = sqrt(-minori(4)/16.0d0)
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine tetra_3dihed_cos  --  tetrahedron cosine values  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "tetra_3dihed_cos" computes three of the six dihedral angles
c     of a tetrahedron from edge lengths, and outputs their cosines
c
c     literature reference:
c
c     L. Yang and Z. Zeng, "Constructing a Tetrahedron with Prescribed
c     Heights and Widths", in F. Botana and T. Recio, Proceedings of
c     ADG2006, 203-211 (2007)
c
c     the tetrahedron is defined by its vertices A1, A2, A3 and A4,
c     the edge between vertex Ai and Aj has length Rij; here we only
c     need the dihedral angles around A1A2, A1A3 and A2A3
c
c     input is r12sq,r13sq,r14sq,r23sq,r24sq,r34sq, where r12sq is
c     the square of the distance between A1 and A2, etc.; output is
c     the cosine of the three dihedral angles
c
c
      subroutine tetra_3dihed_cos (r12sq,r13sq,r14sq,r23sq,
     &                                r24sq,r34sq,cosine)
      implicit none
      real*8 r12sq,r13sq,r14sq
      real*8 r23sq,r24sq,r34sq
      real*8 val1,val2,val3,val4
      real*8 val123,val124,val134
      real*8 val234,val213,val214
      real*8 det12,det13,det23
      real*8 cosine(3)
      real*8 minori(4)
c
c
c     the Cayley Menger matrix is defined as:
c
c     M = ( 0       r12^2   r13^2   r14^2   1 )
c         ( r12^2   0       r23^2   r24^2   1 )
c         ( r13^2   r23^2   0       r34^2   1 )
c         ( r14^2   r24^2   r34^2   0       1 )
c         ( 1       1       1       1       0 )
c
c     find all minors M(i,i) as determinants of the Cayley-Menger
c     matrix with row i and column j removed
c
c     these determinants are of the form:
c
c     det = | 0   a   b   1 |
c           | a   0   c   1 |
c           | b   c   0   1 |
c           | 1   1   1   0 |
c
c     then det = (c - a - b )^2 - 4ab
c
      val234 = r34sq - r23sq - r24sq
      val134 = r34sq - r14sq - r13sq
      val124 = r24sq - r12sq - r14sq
      val123 = r23sq - r12sq - r13sq
      minori(1) = val234*val234 - 4.0d0*r23sq*r24sq
      minori(2) = val134*val134 - 4.0d0*r13sq*r14sq
      minori(3) = val124*val124 - 4.0d0*r12sq*r14sq
      minori(4) = val123*val123 - 4.0d0*r12sq*r13sq
      val4 = 1.0d0 / sqrt(-minori(1))
      val3 = 1.0d0 / sqrt(-minori(2))
      val2 = 1.0d0 / sqrt(-minori(3))
      val1 = 1.0d0 / sqrt(-minori(4))
c
c     next compute all angles, as the cosine of the angle
c
c                (-1)^(i+j) * det(Mij) 
c     cos(i,j) = ---------------------
c                 sqrt(M(i,i)*M(j,j))
c
c     where det(Mij) = M(i,j) is the determinant of the Cayley-Menger
c     matrix with row i and column j removed
c
      det12 = -2.0d0*r12sq*val134 - val123*val124
      det13 = -2.0d0*r13sq*val124 - val123*val134
      val213 = r13sq - r12sq -r23sq
      val214 = r14sq - r12sq -r24sq
      det23 = -2.0d0*r23sq*val214 - val213*val234
      cosine(1) = det12 * val1 * val2
      cosine(2) = det13 * val1 * val3
      cosine(3) = det23 * val1 * val4
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine tetra_dihed_der  --  tetrahedrn dihedral deriv  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "tetra_dihed_der" finds the six dihedral angles of a tetrahedron
c     from its edge lengths as well as their derivatives with respect
c     to these edge lengths
c
c     literature reference:
c
c     L. Yang and Z. Zeng, "Constructing a Tetrahedron with Prescribed
c     Heights and Widths", in F. Botana and T. Recio, Proceedings of
c     ADG2006, 203-211 (2007)
c
c     variables and parameters:
c
c     angle    dihedral angles as fraction of 2*pi
c     cosine   cosine of the dihedral angles
c     sine     sine of the dihedral angle
c     deriv    derivatives of the dihedral angles with
c                respect to the edge lengths AB, AC and BC
c
c     the tetrahedron is defined by its vertices A1, A2, A3 and A4,
c     the edge between vertex Ai and Aj has length Rij
c
c     if T1=(A2,A3,A4), T2=(A1,A3,A4), T3=(A1,A2,A4), T4=(A1,A2,A3),
c     the dihedral angle "angij" is between the faces Ti and Tj
c
c     if T1=(A2,A3,A4), T2=(A1,A3,A4), T3=(A1,A2,A4), T4=(A1,A2,A3),
c     the dihedral angle "angij" is between the faces Ti and Tj
c
c     input is r12sq,r13sq,r14sq,r23sq,r24sq,r34sq, where r12sq is
c     the square of the distance between A1 and A2, etc.
c
c     ang12 is the dihedral angle between (A2,A3,A4) and (A1,A3,A4),
c     and alpha12 is the dihedral angle around the edge A1A2, then
c     ang12=alpha34, ang13=alpha24, ang14=alpha23, ang23=alpha14,
c     ang24=alpha13 and ang34=alpha12
c
c     upon output the angles are in order: alpha12, alpha13, alpha14,
c     alpha23, alpha24, alpha34; the derivatives form a 6x6 matrix
c
c
      subroutine tetra_dihed_der (r12sq,r13sq,r14sq,r23sq,r24sq,r34sq,
     &                               angle,cosine,sine,deriv)
      use math
      implicit none
      integer i,j,k,m,jj
      real*8 r12sq,r13sq,r14sq
      real*8 r23sq,r24sq,r34sq
      real*8 val123,val124,val134
      real*8 val234,val213,val214
      real*8 val314,val324,val312
      real*8 vala,val1,val2,val3
      real*8 tetvol,teteps
      real*8 minori(4),val(4)
      real*8 cosine(6),sine(6),angle(6)
      real*8 det(6),deriv(6,6),dnum(6,6)
      real*8 dminori(4,6)
c
c
c     the Cayley Menger matrix is defined as:
c
c     M = ( 0       r12^2   r13^2   r14^2   1 )
c         ( r12^2   0       r23^2   r24^2   1 )
c         ( r13^2   r23^2   0       r34^2   1 )
c         ( r14^2   r24^2   r34^2   0       1 )
c         ( 1       1       1       1       0 )
c
c     find all minors M(i,i) as determinants of the Cayley-Menger
c     matrix with row i and column j removed
c
c     these determinants are of the form:
c
c     det = | 0   a   b   1 |
c           | a   0   c   1 |
c           | b   c   0   1 |
c           | 1   1   1   0 |
c
c     then det = (c - a - b )^2 - 4ab
c
      val234 = r34sq - r23sq - r24sq
      val134 = r34sq - r14sq - r13sq
      val124 = r24sq - r12sq - r14sq
      val123 = r23sq - r12sq - r13sq
      minori(1) = val234*val234 - 4.0d0*r23sq*r24sq
      minori(2) = val134*val134 - 4.0d0*r13sq*r14sq
      minori(3) = val124*val124 - 4.0d0*r12sq*r14sq
      minori(4) = val123*val123 - 4.0d0*r12sq*r13sq
      val(1) = 1.0d0 / sqrt(-minori(1))
      val(2) = 1.0d0 / sqrt(-minori(2))
      val(3) = 1.0d0 / sqrt(-minori(3))
      val(4) = 1.0d0 / sqrt(-minori(4))
c
c     next compute all angles, as the cosine of the angle
c
c                (-1)^(i+j) * det(Mij) 
c     cos(i,j) = ---------------------
c                 sqrt(M(i,i)*M(j,j))
c
c     where det(Mij) = M(i,j) is the determinant of the Cayley-Menger
c     matrix with row i and column j removed
c
      det(6) = -2.0d0*r12sq*val134 - val123*val124
      det(5) = -2.0d0*r13sq*val124 - val123*val134
      det(4) = -2.0d0*r14sq*val123 - val124*val134
      val213 = r13sq -r12sq -r23sq
      val214 = r14sq -r12sq -r24sq
      val312 = r12sq -r13sq -r23sq
      val314 = r14sq -r13sq -r34sq
      val324 = r24sq -r23sq -r34sq
      det(3) = -2.0d0*r23sq*val214 - val213*val234
      det(2) = -2.0d0*r24sq*val213 - val214*val234
      det(1) = -2.0d0*r34sq*val312 - val314*val324
      cosine(1) = det(6) * val(3) * val(4)
      cosine(2) = det(5) * val(2) * val(4)
      cosine(3) = det(4) * val(2) * val(3)
      cosine(4) = det(3) * val(1) * val(4)
      cosine(5) = det(2) * val(1) * val(3)
      cosine(6) = det(1) * val(1) * val(2)
      do i = 1, 6
         if (cosine(i) > 1.0d0) then
            cosine(i) = 1.0d0
         else if (cosine(i) .lt. -1.0d0) then
            cosine(i) = -1.0d0
         end if
      end do
      do i = 1, 6
         angle(i) = acos(cosine(i))
         sine(i) = sin(angle(i))
         angle(i) = angle(i) / twopi
      end do
      do i = 1, 6
         do j = 1, 6
            deriv(i,j) = 0.0d0
         end do
      end do
      teteps = 1.0d-5
      call tetra_volume (r12sq,r13sq,r14sq,r23sq,r24sq,r34sq,tetvol)
      if (tetvol .lt. teteps)  return
c
c     compute derivatives of angles with respect to edge lengths
c
c                          num(i,j)
c     cos(ang(i,j)) = -------------------
c                     sqrt(M(i,i)*M(j,j))
c
c     d(ang(i,j))                         dnum(i,j)
c     ----------- sin(ang(i,j)) = --------------------------
c       dr(a,b)                   sqrt(M(i,i)M(j,j)) dr(a,b)
c
c                                   M(i,i)dM(j,j) + M(j,j)*dM(i,i)
c                    - 0.5*num(i,j) -------------------------------
c                                   M(i,i)M(j,j) sqrt(M(i,i)M(j,j))
c
c     which we can rewrite as:
c
c     d(ang(i,j))                 cosine(i,j) dnum(i,j)
c     ----------- sin(ang(i,j)) = ----------- ---------
c       dr(a,b)                    num(i,j)    dr(a,b)
c
c                                       dM(j,j) +  dM(i,i))
c                    - 0.5*cosine(i,j) (-------- + --------)
c                                        M(j,j)     M(i,i)
c
      do i = 1, 6
         do j = 1, 4
            dminori(j,i) = 0.0d0
         end do
      end do
      dminori(1,4) = -val234 - 2.0d0*r24sq
      dminori(1,5) = -val234 - 2.0d0*r23sq
      dminori(1,6) = val234
      dminori(2,2) = -val134 - 2.0d0*r14sq
      dminori(2,3) = -val134 - 2.0d0*r13sq
      dminori(2,6) = val134
      dminori(3,1) = -val124 - 2.0d0*r14sq
      dminori(3,3) = -val124 - 2.0d0*r12sq
      dminori(3,5) = val124
      dminori(4,1) = -val123 - 2.0d0*r13sq
      dminori(4,2) = -val123 - 2.0d0*r12sq
      dminori(4,4) = val123
      dnum(6,1) = -2.0d0*val134 + val123+val124
      dnum(6,2) = 2.0d0*r12sq + val124
      dnum(6,3) = 2.0d0*r12sq + val123
      dnum(6,4) = -val124
      dnum(6,5) = -val123
      dnum(6,6) = -2.0d0 * r12sq
      dnum(5,1) = 2.0d0*r13sq + val134
      dnum(5,2) = -2.0d0*val124 + val123 + val134
      dnum(5,3) = 2.0d0*r13sq + val123
      dnum(5,4) = -val134
      dnum(5,5) = -2.0d0 * r13sq
      dnum(5,6) = -val123
      dnum(4,1) = 2.0d0*r14sq + val134
      dnum(4,2) = 2.0d0*r14sq + val124
      dnum(4,3) = -2.0d0*val123 + val124 + val134
      dnum(4,4) = -2.0d0 * r14sq
      dnum(4,5) = -val134
      dnum(4,6) = -val124
      dnum(3,1) = 2.0d0*r23sq + val234
      dnum(3,2) = -val234
      dnum(3,3) = -2.0d0 * r23sq
      dnum(3,4) = -2.0d0*val214 + val213 + val234
      dnum(3,5) = 2.0d0*r23sq + val213
      dnum(3,6) = -val213
      dnum(2,1) = 2.0d0*r24sq + val234
      dnum(2,2) = -2.0d0 * r24sq
      dnum(2,3) = -val234
      dnum(2,4) = 2.0d0*r24sq + val214
      dnum(2,5) = -2.0d0*val213 + val214 + val234
      dnum(2,6) = -val214
      dnum(1,1) = -2.0d0 * r34sq
      dnum(1,2) = 2.0d0*r34sq + val324
      dnum(1,3) = -val324
      dnum(1,4) = 2.0d0*r34sq + val314
      dnum(1,5) = -val314
      dnum(1,6) = -2.0d0*val312 + val314 + val324
      k = 0
      do i = 1, 3
         do j = i+1, 4
            k = k + 1
            jj = 7 - k
            if (det(k) .ne. 0) then
               vala = cosine(jj) / sine(jj)
               val1 = -vala / det(k)
               val2 = vala / minori(j)
               val3 = vala / minori(i)
               do m = 1, 6
                  deriv(jj,m) = val1*dnum(k,m) + val2*dminori(j,m)
     &                             + val3*dminori(i,m)
               end do
            else
               vala = -val(i) * val(j) / sine(jj)
               do m = 1, 6
                  deriv(jj,m) = vala * dnum(k,m)
               end do
            end if
         end do
      end do
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine tetra_dihed_der3  --  tetrahedron angle derivs  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "tetra_dihed_der3" computes the six dihedral angles of the
c     tetrahedron (A, B, C, D) from its edge lengths as well as the
c     derivatives with respect to the edge lengths AB, AC and BC
c
c     literature reference:
c
c     L. Yang and Z. Zeng, "Constructing a Tetrahedron with Prescribed
c     Heights and Widths", in F. Botana and T. Recio, Proceedings of
c     ADG2006, 203-211 (2007)
c
c     variables and parameters:
c
c     angle    dihedral angles as fraction of 2*pi
c     cosine   cosine of the dihedral angles
c     sine     sine of the dihedral angle
c     deriv    derivatives of the dihedral angles with
c                respect to the edge lengths AB, AC and BC
c
c     the tetrahedron is defined by its vertices A1, A2, A3 and A4,
c     the edge between vertex Ai and Aj has length Rij
c
c     if T1=(A2,A3,A4), T2=(A1,A3,A4), T3=(A1,A2,A4), T4=(A1,A2,A3),
c     the dihedral angle "angij" is between the faces Ti and Tj
c
c     input is r12sq,r13sq,r14sq,r23sq,r24sq,r34sq, where r12sq is
c     the square of the distance between A1 and A2, etc.
c
c     ang12 is the dihedral angle between (A2,A3,A4) and (A1,A3,A4),
c     and alpha12 is the dihedral angle around the edge A1A2, then
c     ang12=alpha34, ang13=alpha24, ang14=alpha23, ang23=alpha14,
c     ang24=alpha13 and ang34=alpha12
c
c     upon output the angles are in the order: alpha12, alpha13,
c     alpha14, alpha23, alpha24, alpha34
c
c
      subroutine tetra_dihed_der3 (r12sq,r13sq,r14sq,r23sq,r24sq,r34sq,
     &                                angle,cosine,sine,deriv,option)
      use math
      implicit none
      integer i,j,k,m,jj,option
      real*8 r12sq,r13sq,r14sq
      real*8 r23sq,r24sq,r34sq
      real*8 val123,val124,val134
      real*8 val234,val213,val214
      real*8 val314,val324,val312
      real*8 vala,val1,val2,val3
      real*8 tetvol, teteps
      real*8 minori(4),val(4)
      real*8 cosine(6),sine(6),angle(6)
      real*8 det(6),deriv(6,3),dnum(6,3)
      real*8 dminori(4,3)
c
c
c     the Cayley Menger matrix is defined as:
c
c     M = ( 0       r12^2   r13^2   r14^2   1 )
c         ( r12^2   0       r23^2   r24^2   1 )
c         ( r13^2   r23^2   0       r34^2   1 )
c         ( r14^2   r24^2   r34^2   0       1 )
c         ( 1       1       1       1       0 )
c
c     find all minors M(i,i) as determinants of the Cayley-Menger
c     matrix with row i and column j removed
c
c     these determinants are of the form:
c
c     det = | 0   a   b   1 |
c           | a   0   c   1 |
c           | b   c   0   1 |
c           | 1   1   1   0 |
c
c     then det = (c - a - b )^2 - 4ab
c
      val234 = r34sq - r23sq - r24sq
      val134 = r34sq - r14sq - r13sq
      val124 = r24sq - r12sq - r14sq
      val123 = r23sq - r12sq - r13sq
      minori(1) = val234*val234 - 4.0d0*r23sq*r24sq
      minori(2) = val134*val134 - 4.0d0*r13sq*r14sq
      minori(3) = val124*val124 - 4.0d0*r12sq*r14sq
      minori(4) = val123*val123 - 4.0d0*r12sq*r13sq
      val(1) = 1.0d0 / sqrt(-minori(1))
      val(2) = 1.0d0 / sqrt(-minori(2))
      val(3) = 1.0d0 / sqrt(-minori(3))
      val(4) = 1.0d0 / sqrt(-minori(4))
c
c     next compute all angles, as the cosine of the angle
c
c                (-1)^(i+j) * det(Mij) 
c     cos(i,j) = ---------------------
c                 sqrt(M(i,i)*M(j,j))
c
c     where det(Mij) = M(i,j) is the determinant of the Cayley-Menger
c     matrix with row i and column j removed
c
      det(6) = -2.0d0*r12sq*val134 - val123*val124
      det(5) = -2.0d0*r13sq*val124 - val123*val134
      det(4) = -2.0d0*r14sq*val123 - val124*val134
      val213 = r13sq - r12sq - r23sq
      val214 = r14sq - r12sq - r24sq
      val312 = r12sq - r13sq - r23sq
      val314 = r14sq - r13sq - r34sq
      val324 = r24sq - r23sq - r34sq
      det(3) = -2.0d0*r23sq*val214 - val213*val234
      det(2) = -2.0d0*r24sq*val213 - val214*val234
      det(1) = -2.0d0*r34sq*val312 - val314*val324
      cosine(1) = det(6) * val(3) * val(4)
      cosine(2) = det(5) * val(2) * val(4)
      cosine(3) = det(4) * val(2) * val(3)
      cosine(4) = det(3) * val(1) * val(4)
      cosine(5) = det(2) * val(1) * val(3)
      cosine(6) = det(1) * val(1) * val(2)
      do i = 1, 6
         if (cosine(i) > 1.0d0) then
            cosine(i) = 1.0d0
         else if (cosine(i) .lt. -1.0d0) then
            cosine(i) = -1.0d0
         end if
      end do
      do i = 1, 6
         angle(i) = acos(cosine(i))
         sine(i) = sin(angle(i))
         angle(i) = angle(i) / twopi
      end do
      if (option .eq. 0)  return
      do i = 1, 6
         do j = 1, 3
            deriv(i,j) = 0.0d0
         end do
      end do
      teteps = 1.0d-5
      call tetra_volume (r12sq,r13sq,r14sq,r23sq,r24sq,r34sq,tetvol)
      if (tetvol .lt. teteps)  return
c
c     compute derivatives of angles with respect to edge lengths
c
c                          num(i,j)
c     cos(ang(i,j)) = -------------------
c                     sqrt(M(i,i)*M(j,j))
c
c     d(ang(i,j))                         dnum(i,j)
c     ----------- sin(ang(i,j)) = --------------------------
c       dr(a,b)                   sqrt(M(i,i)M(j,j)) dr(a,b)
c
c                                   M(i,i)dM(j,j) + M(j,j)*dM(i,i)
c                    - 0.5*num(i,j) -------------------------------
c                                   M(i,i)M(j,j) sqrt(M(i,i)M(j,j))
c
c     which we can rewrite as:
c
c     d(ang(i,j))                 cosine(i,j) dnum(i,j)
c     ----------- sin(ang(i,j)) = ----------- ---------
c       dr(a,b)                    num(i,j)    dr(a,b)
c
c                                       dM(j,j) +  dM(i,i))
c                    - 0.5*cosine(i,j) (-------- + --------)
c                                        M(j,j)     M(i,i)
c
      do i = 1, 3
         do j = 1, 4
            dminori(j,i) = 0.0d0
         end do
      end do
      dminori(1,3) = -val234 - 2.0d0*r24sq
      dminori(2,2) = -val134 - 2.0d0*r14sq
      dminori(3,1) = -val124 - 2.0d0*r14sq
      dminori(4,1) = -val123 - 2.0d0*r13sq
      dminori(4,2) = -val123 - 2.0d0*r12sq
      dminori(4,3) = val123
      dnum(6,1) = -2.0d0*val134 + val123+val124
      dnum(6,2) = 2.0d0*r12sq + val124
      dnum(6,3) = -val124
      dnum(5,1) = 2.0d0*r13sq + val134
      dnum(5,2) = -2.0d0*val124 + val123 + val134
      dnum(5,3) = -val134
      dnum(4,1) = 2.0d0*r14sq + val134
      dnum(4,2) = 2.0d0*r14sq + val124
      dnum(4,3) = -2.0d0 * r14sq
      dnum(3,1) = 2.0d0*r23sq + val234
      dnum(3,2) = -val234
      dnum(3,3) = -2.0d0*val214 + val213 + val234
      dnum(2,1) = 2.0d0*r24sq + val234
      dnum(2,2) = -2.0d0 * r24sq
      dnum(2,3) = 2.0d0*r24sq + val214
      dnum(1,1) = -2.0d0 * r34sq
      dnum(1,2) = 2.0d0*r34sq + val324
      dnum(1,3) = 2.0d0*r34sq + val314
      k = 0
      do i = 1, 3
         do j = i+1, 4
            k = k + 1
            jj = 7 - k
            if (det(k) .ne. 0) then
               vala = cosine(jj) / sine(jj)
               val1 = -vala / det(k)
               val2 = vala / minori(j)
               val3 = vala / minori(i)
               do m = 1, 3
                  deriv(jj,m) = val1*dnum(k,m) + val2*dminori(j,m)
     &                             + val3*dminori(i,m)
               end do
            else
               vala = -val(i) * val(j) / sine(jj)
               do m = 1, 3
                  deriv(jj,m) = vala * dnum(k,m)
               end do
            end if
         end do
      end do
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine tetra_3dihed_dcos  --  tetrahedrn cosine deriv  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "tetra_3dihed_dcos" computes three of the six dihedral angles
c     of a tetrahedron from its edge lengths, and outputs the cosines
c
c     literature reference:
c
c     L. Yang and Z. Zeng, "Constructing a Tetrahedron with Prescribed
c     Heights and Widths", in F. Botana and T. Recio, Proceedings of
c     ADG2006, 203-211 (2007)
c
c     the tetrahedron is defined by its vertices A1, A2, A3 and A4,
c     the edge between vertex Ai and Aj has length Rij
c
c     only need dihedral angles around A1A2, A1A3 and A2A3
c
c     variables and parameters:
c
c     r12sq,r13sq,r14sq,    distance squared between pairs of balls
c       r23sq,r24sq,r34sq
c     cosine                cosine of the three dihedral angles
c     deriv                 derivatives of the cosines over the
c                             AB, AC and BC distances
c
c
      subroutine tetra_3dihed_dcos (r12sq,r13sq,r14sq,r23sq,r24sq,
     &                                r34sq,cosine,deriv,option)
      implicit none
      integer i,j,option
      real*8 r12sq,r13sq,r14sq
      real*8 r23sq,r24sq,r34sq
      real*8 val1,val2,val3,val4
      real*8 val123,val124,val134
      real*8 val234,val213,val214
      real*8 det12,det13,det23
      real*8 cosine(3)
      real*8 minori(4)
      real*8 deriv(3,3)
      real*8 dminori(4,3)
      real*8 dnum(3,3)
c
c
c     the Cayley Menger matrix is defined as:
c
c     M = ( 0       r12^2   r13^2   r14^2   1 )
c         ( r12^2   0       r23^2   r24^2   1 )
c         ( r13^2   r23^2   0       r34^2   1 )
c         ( r14^2   r24^2   r34^2   0       1 )
c         ( 1       1       1       1       0 )
c
c     find all minors M(i,i) as determinants of the Cayley-Menger
c     matrix with row i and column j removed
c
c     these determinants are of the form:
c
c     det = | 0   a   b   1 |
c           | a   0   c   1 |
c           | b   c   0   1 |
c           | 1   1   1   0 |
c
c     then det = (c - a - b )^2 - 4ab
c
      val234 = r34sq - r23sq - r24sq
      val134 = r34sq - r14sq - r13sq
      val124 = r24sq - r12sq - r14sq
      val123 = r23sq - r12sq - r13sq
      minori(1) = val234*val234 - 4.0d0*r23sq*r24sq
      minori(2) = val134*val134 - 4.0d0*r13sq*r14sq
      minori(3) = val124*val124 - 4.0d0*r12sq*r14sq
      minori(4) = val123*val123 - 4.0d0*r12sq*r13sq
      val4 = 1.0d0 / sqrt(-minori(1))
      val3 = 1.0d0 / sqrt(-minori(2))
      val2 = 1.0d0 / sqrt(-minori(3))
      val1 = 1.0d0 / sqrt(-minori(4))
c
c     next compute all angles, as the cosine of the angle
c
c                (-1)^(i+j) * det(Mij) 
c     cos(i,j) = ---------------------
c                 sqrt(M(i,i)*M(j,j))
c
c     where det(Mij) = M(i,j) is the determinant of the Cayley-Menger
c     matrix with row i and column j removed
c
      det12 = -2.0d0*r12sq*val134 - val123*val124
      det13 = -2.0d0*r13sq*val124 - val123*val134
      val213 = r13sq -r12sq -r23sq
      val214 = r14sq -r12sq -r24sq
      det23 = -2.0d0*r23sq*val214 - val213*val234
      cosine(1) = det12 * val1 * val2
      cosine(2) = det13 * val1 * val3
      cosine(3) = det23 * val1 * val4
      if (option .eq. 0)  return
      do i = 1, 3
         do j = 1, 4
            dminori(j,i) = 0.0d0
         end do
      end do
      dminori(1,3) = -val234 - 2.0d0*r24sq
      dminori(2,2) = -val134 - 2.0d0*r14sq
      dminori(3,1) = -val124 - 2.0d0*r14sq
      dminori(4,1) = -val123 - 2.0d0*r13sq
      dminori(4,2) = -val123 - 2.0d0*r12sq
      dminori(4,3) = val123
      dnum(1,1) = -2.0d0*val134 + val123+val124
      dnum(1,2) = 2.0d0*r12sq + val124
      dnum(1,3) = -val124
      dnum(2,1) = 2.0d0*r13sq + val134
      dnum(2,2) = -2.0d0*val124 + val123 + val134
      dnum(2,3) = -val134
      dnum(3,1) = 2.0d0*r23sq + val234
      dnum(3,2) = -val234
      dnum(3,3) = -2.0d0*val214 + val213 + val234
      do i = 1, 3
         deriv(1,i) = dnum(1,i)*val1*val2 - cosine(1)*
     &                (dminori(3,i)/minori(3)+dminori(4,i)/minori(4))
         deriv(2,i) = dnum(2,i)*val1*val3 - cosine(2)*
     &                (dminori(2,i)/minori(2)+dminori(4,i)/minori(4))
         deriv(3,i) = dnum(3,i)*val1*val4 - cosine(3)*
     &                (dminori(1,i)/minori(1)+dminori(4,i)/minori(4))
      end do
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine truncate_real  --  truncate precision of real  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "truncate_real" converts a real number to a given accuracy
c     with a specified number of digits after the decimal point)
c
c
      subroutine truncate_real(x_in,x_out,ndigit)
      implicit none
      integer i,mantissa
      integer ndigit
      integer digit(16)
      real*8 x_in,x_out,y
      real*8 fact
c
c
      mantissa = int(x_in)
      y = x_in - mantissa
      x_out = mantissa
      fact = 1
      do i = 1, ndigit
         fact = fact * 10.0d0
         digit(i) = nint(y*10.0d0)
         y = 10.0d0 * (y-digit(i)/10.0d0)
         x_out = x_out + digit(i)/fact
      end do
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine crossvect  --  cross product of two vectors  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "crossvect" computes the cross product of two vectors
c
c
      subroutine crossvect (u1,u2,u3)
      implicit none
      real*8 u1(3),u2(3),u3(3)
c
c
      u3(1) = u1(2)*u2(3) - u1(3)*u2(2)
      u3(2) = -u1(1)*u2(3) + u1(3)*u2(1)
      u3(3) = u1(1)*u2(2) - u1(2)*u2(1)
      return
      end
c
c
c     ##########################################################
c     ##                                                      ##
c     ##  subroutine dotvect  --  dot product of two vectors  ##
c     ##                                                      ##
c     ##########################################################
c
c
c     dotvect" computes the dot product of two vectors
c
c
      subroutine dotvect (u1,u2,dot)
      implicit none
      integer i
      real*8 u1(3),u2(3),dot
c
c
      dot = 0.0d0
      do i = 1, 3
         dot = dot + u1(i)*u2(i)
      end do
      return
      end
c
c
c     #########################################################
c     ##                                                     ##
c     ##  subroutine normvect  --  compute norm of a vector  ##
c     ##                                                     ##
c     #########################################################
c
c
c     "normvect" compute the norm length of a vector
c
c
      subroutine normvect (u1,norm)
      implicit none
      real*8 u1(3),norm
c
c
      call dotvect (u1,u1,norm)
      norm = sqrt(norm)
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine diffvect  --  difference between two vectors  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "diffvect" computes the difference between two vectors
c
c
      subroutine diffvect (u1,u2,u3)
      implicit none
      integer i
      real*8 u1(3),u2(3),u3(3)
c
c
      do i = 1, 3
         u3(i) = u2(i) - u1(i)
      end do
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine minor5  --  find the sign of 5x5 determinant  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "minor5" computes the value of a 5x5 determinant built from
c     coordinates of specified balls; if the determinant is zero,
c     then checks minors until a nonzero value is found
c
c
      subroutine minor5 (crdball,radball,a,b,c,d,e,result)
      implicit none
      integer a,b,c,d,e
      integer result
      integer isign
      integer ida1,ida2,ida3
      integer idb1,idb2,idb3
      integer idc1,idc2,idc3
      integer idd1,idd2,idd3
      integer ide1,ide2,ide3
      real*8 det,psub,padd,t1,t2
      real*8 r11,r21,r31,r41,r51
      real*8 r12,r22,r32,r42,r52
      real*8 r13,r23,r33,r43,r53
      real*8 r14,r24,r34,r44,r54
      real*8 rr1,rr2,rr3,rr4,rr5
      real*8 crdball(*)
      real*8 radball(*)
c
c
c     get the value of the determinant and find its sign
c
      ida1 = 3*a - 2
      ida2 = ida1 + 1
      ida3 = ida2 + 1
      idb1 = 3*b - 2
      idb2 = idb1 + 1
      idb3 = idb2 + 1
      idc1 = 3*c - 2
      idc2 = idc1 + 1
      idc3 = idc2 + 1
      idd1 = 3*d - 2
      idd2 = idd1 + 1
      idd3 = idd2 + 1
      ide1 = 3*e - 2
      ide2 = ide1 + 1
      ide3 = ide2 + 1
      r11 = crdball(ida1)
      r12 = crdball(ida2)
      r13 = crdball(ida3)
      r21 = crdball(idb1)
      r22 = crdball(idb2)
      r23 = crdball(idb3)
      r31 = crdball(idc1)
      r32 = crdball(idc2)
      r33 = crdball(idc3)
      r41 = crdball(idd1)
      r42 = crdball(idd2)
      r43 = crdball(idd3)
      r51 = crdball(ide1)
      r52 = crdball(ide2)
      r53 = crdball(ide3)
      rr1 = radball(a)
      rr2 = radball(b)
      rr3 = radball(c)
      rr4 = radball(d)
      rr5 = radball(e)
      t1 = rr1 * rr1
      t2 = r11 * r11
      t1 = psub (t2,t1)
      t2 = r12 * r12
      t1 = padd (t2,t1)
      t2 = r13 * r13
      r14 = padd (t2,t1)
      t1 = rr2 * rr2
      t2 = r21 * r21
      t1 = psub (t2,t1)
      t2 = r22 * r22
      t1 = padd (t2,t1)
      t2 = r23 * r23
      r24 = padd (t2,t1)
      t1 = rr3 * rr3
      t2 = r31 * r31
      t1 = psub (t2,t1)
      t2 = r32 * r32
      t1 = padd (t2,t1)
      t2 = r33 * r33
      r34 = padd (t2,t1)
      t1 = rr4 * rr4
      t2 = r41 * r41
      t1 = psub (t2,t1)
      t2 = r42 * r42
      t1 = padd (t2,t1)
      t2 = r43 * r43
      r44 = padd (t2,t1)
      t1 = rr5 * rr5
      t2 = r51 * r51
      t1 = psub (t2,t1)
      t2 = r52 * r52
      t1 = padd (t2,t1)
      t2 = r53 * r53
      r54 = padd (t2,t1)
      result = 1
      call deter5 (det,r11,r12,r13,r14,r21,r22,r23,r24,r31,r32,
     &             r33,r34,r41,r42,r43,r44,r51,r52,r53,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
c
c     check signs of minors if full determinant is zero
c
      call deter4 (det,r21,r22,r23,r31,r32,r33,
     &             r41,r42,r43,r51,r52,r53,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter4 (det,r21,r22,r24,r31,r32,r34,
     &             r41,r42,r44,r51,r52,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter4 (det,r21,r23,r24,r31,r33,r34,
     &             r41,r43,r44,r51,r53,r54,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter4 (det,r22,r23,r24,r32,r33,r34,
     &             r42,r43,r44,r52,r53,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter4 (det,r11,r12,r13,r31,r32,r33,
     &             r41,r42,r43,r51,r52,r53,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r31,r32,r41,r42,r51,r52,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r31,r33,r41,r43,r51,r53,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r32,r33,r42,r43,r52,r53,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter4 (det,r11,r12,r14,r31,r32,r34,
     &             r41,r42,r44,r51,r52,r54,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r31,r34,r41,r44,r51,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r32,r34,r42,r44,r52,r54,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter4 (det,r11,r13,r14,r31,r33,r34,
     &             r41,r43,r44,r51,r53,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r33,r34,r43,r44,r53,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter4 (det,r12,r13,r14,r32,r33,r34,
     &             r42,r43,r44,r52,r53,r54,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter4 (det,r11,r12,r13,r21,r22,r23,
     &             r41,r42,r43,r51,r52,r53,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r21,r22,r41,r42,r51,r52,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r21,r23,r41,r43,r51,r53,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r22,r23,r42,r43,r52,r53,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r11,r12,r41,r42,r51,r52,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r41,r51,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter2 (det,r42,r52,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r11,r13,r41,r43,r51,r53,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter2 (det,r43,r53,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r12,r13,r42,r43,r52,r53,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter4 (det,r11,r12,r14,r21,r22,r24,
     &             r41,r42,r44,r51,r52,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r21,r24,r41,r44,r51,r54,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r22,r24,r42,r44,r52,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r11,r14,r41,r44,r51,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r44,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r12,r14,r42,r44,r52,r54,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter4 (det,r11,r13,r14,r21,r23,r24,
     &             r41,r43,r44,r51,r53,r54,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r23,r24,r43,r44,r53,r54,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r13,r14,r43,r44,r53,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter4 (det,r12,r13,r14,r22,r23,r24,
     &             r42,r43,r44,r52,r53,r54,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter4 (det,r11,r12,r13,r21,r22,r23,
     &             r31,r32,r33,r51,r52,r53,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r21,r22,r31,r32,r51,r52,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r21,r23,r31,r33,r51,r53,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r22,r23,r32,r33,r52,r53,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r11,r12,r31,r32,r51,r52,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter2 (det,r31,r51,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r32,r52,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r11,r13,r31,r33,r51,r53,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r33,r53,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r12,r13,r32,r33,r52,r53,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r11,r12,r21,r22,r51,r52,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r21,r51,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter2 (det,r22,r52,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r11,r51,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine deter5  --  get the value of 5x5 determinant  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "deter5" finds a 5x5 determinant value where the rightmost
c     column is all ones and other elements are given as arguments
c
c
      subroutine deter5 (det,r11,r12,r13,r14,r21,r22,r23,r24,r31,r32,
     &                   r33,r34,r41,r42,r43,r44,r51,r52,r53,r54,isign)
      implicit none
      integer isign
      real*8 det,psub,padd
      real*8 r11,r21,r31,r41,r51
      real*8 r12,r22,r32,r42,r52
      real*8 r13,r23,r33,r43,r53
      real*8 r14,r24,r34,r44,r54
      real*8 s11,s21,s31,s41
      real*8 s12,s22,s32,s42
      real*8 s13,s23,s33,s43
      real*8 s14,s24,s34,s44
      real*8 t1,t2,t3
      real*8 u1,u2,u3
      real*8 v1,v2,v3
      real*8 w1,w2,w3
      real*8 x1,x2,x3
      real*8 eps
c
c
c     compute the numerical value of the determinant
c
      s11 = psub (r21,r11)
      s12 = psub (r22,r12)
      s13 = psub (r23,r13)
      s14 = psub (r24,r14)
      s21 = psub (r31,r11)
      s22 = psub (r32,r12)
      s23 = psub (r33,r13)
      s24 = psub (r34,r14)
      s31 = psub (r41,r11)
      s32 = psub (r42,r12)
      s33 = psub (r43,r13)
      s34 = psub (r44,r14)
      s41 = psub (r51,r11)
      s42 = psub (r52,r12)
      s43 = psub (r53,r13)
      s44 = psub (r54,r14)
      t1 = s32 * s43
      t2 = s42 * s33
      u1 = psub (t1,t2)
      t1 = s32 * s44
      t2 = s42 * s34
      u2 = psub (t1,t2)
      t1 = s33 * s44
      t2 = s43 * s34
      u3 = psub (t1,t2)
      t1 = s12 * s23
      t2 = s22 * s13
      v1 = psub (t1,t2)
      t1 = s12 * s24
      t2 = s22 * s14
      v2 = psub (t1,t2)
      t1 = s13 * s24
      t2 = s23 * s14
      v3 = psub (t1,t2)
      t1 = s11 * s24
      t2 = s21 * s14
      w1 = psub (t1,t2)
      t1 = s11 * s23
      t2 = s21 * s13
      w2 = psub (t1,t2)
      t1 = s11 * s22
      t2 = s21 * s12
      w3 = psub (t1,t2)
      t1 = s31 * s44
      t2 = s41 * s34
      x1 = psub (t1,t2)
      t1 = s31 * s43
      t2 = s41 * s33
      x2 = psub (t1,t2)
      t1 = s31 * s42
      t2 = s41 * s32
      x3 = psub (t1,t2)
      t1 = v3 * x3
      t2 = v2 * x2
      t3 = psub (t1,t2)
      t1 = v1 * x1
      t3 = padd (t3,t1)
      t1 = u3 * w3
      t3 = padd (t3,t1)
      t1 = u2 * w2
      t3 = psub (t3,t1)
      t1 = u1 * w1
      det = padd (t3,t1)
      eps = 1.0d-10
      if (abs(det) .lt. eps)  det = 0.0d0
c
c     return value based on sign of the determinant
c
      isign = 0
      if (det .gt. 0.0d0) then
         isign = 1
      else if (det .lt. 0.0d0) then
         isign = -1
      end if
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine minor4  --  find the sign of 4x4 determinant  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "minor4" computes the value of a 4x4 determinant built from
c     coordinates of specified balls; if the determinant is zero,
c     then checks minors until a nonzero value is found
c
c
      subroutine minor4 (crdball,a,b,c,d,result)
      implicit none
      integer a,b,c,d
      integer result
      integer isign
      integer ida1,ida2,ida3
      integer idb1,idb2,idb3
      integer idc1,idc2,idc3
      integer idd1,idd2,idd3
      real*8 det
      real*8 r11,r21,r31,r41
      real*8 r12,r22,r32,r42
      real*8 r13,r23,r33,r43
      real*8 crdball(*)
c
c
c     get the value of the determinant and find its sign
c
      ida1 = 3*a - 2
      ida2 = ida1 + 1
      ida3 = ida2 + 1
      idb1 = 3*b - 2
      idb2 = idb1 + 1
      idb3 = idb2 + 1
      idc1 = 3*c - 2
      idc2 = idc1 + 1
      idc3 = idc2 + 1
      idd1 = 3*d - 2
      idd2 = idd1 + 1
      idd3 = idd2 + 1
      r11 = crdball(ida1)
      r12 = crdball(ida2)
      r13 = crdball(ida3)
      r21 = crdball(idb1)
      r22 = crdball(idb2)
      r23 = crdball(idb3)
      r31 = crdball(idc1)
      r32 = crdball(idc2)
      r33 = crdball(idc3)
      r41 = crdball(idd1)
      r42 = crdball(idd2)
      r43 = crdball(idd3)
      result = 1
      call deter4 (det,r11,r12,r13,r21,r22,r23,
     &             r31,r32,r33,r41,r42,r43,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
c
c     check signs of minors if full determinant is zero
c
      call deter3 (det,r21,r22,r31,r32,r41,r42,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r21,r23,r31,r33,r41,r43,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r22,r23,r32,r33,r42,r43,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r11,r12,r31,r32,r41,r42,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter2 (det,r31,r41,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r32,r42,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r11,r13,r31,r33,r41,r43,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r33,r43,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter3 (det,r12,r13,r32,r33,r42,r43,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter3 (det,r11,r12,r21,r22,r41,r42,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r21,r41,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter2 (det,r22,r42,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r11,r41,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      return
      end
c
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine minor4x  --  find 4x4 determinant sign; no SOS  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "minor4x" computes the value of a 4x4 determinant built from
c     coordinates of specified balls and also finds the sign
c
c
      subroutine minor4x (crdball,a,b,c,d,result)
      implicit none
      integer a,b,c,d
      integer result
      integer isign
      integer ida1,ida2,ida3
      integer idb1,idb2,idb3
      integer idc1,idc2,idc3
      integer idd1,idd2,idd3
      real*8 det
      real*8 r11,r21,r31,r41
      real*8 r12,r22,r32,r42
      real*8 r13,r23,r33,r43
      real*8 crdball(*)
c
c
c     get the value of the determinant and find its sign
c
      ida1 = 3*a - 2
      ida2 = ida1 + 1
      ida3 = ida2 + 1
      idb1 = 3*b - 2
      idb2 = idb1 + 1
      idb3 = idb2 + 1
      idc1 = 3*c - 2
      idc2 = idc1 + 1
      idc3 = idc2 + 1
      idd1 = 3*d - 2
      idd2 = idd1 + 1
      idd3 = idd2 + 1
      r11 = crdball(ida1)
      r12 = crdball(ida2)
      r13 = crdball(ida3)
      r21 = crdball(idb1)
      r22 = crdball(idb2)
      r23 = crdball(idb3)
      r31 = crdball(idc1)
      r32 = crdball(idc2)
      r33 = crdball(idc3)
      r41 = crdball(idd1)
      r42 = crdball(idd2)
      r43 = crdball(idd3)
      call deter4 (det,r11,r12,r13,r21,r22,r23,
     &             r31,r32,r33,r41,r42,r43,isign)
      result = isign
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine deter4  --  get the value of 4x4 determinant  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "deter4" finds a 4x4 determinant value where the rightmost
c     column is all ones and other elements are given as arguments
c
c
      subroutine deter4 (det,r11,r12,r13,r21,r22,r23,
     &                   r31,r32,r33,r41,r42,r43,isign)
      implicit none
      integer isign
      real*8 det,psub,padd
      real*8 r11,r21,r31,r41
      real*8 r12,r22,r32,r42
      real*8 r13,r23,r33,r43
      real*8 s11,s21,s31
      real*8 s12,s22,s32
      real*8 s13,s23,s33
      real*8 t1,t2,t3
      real*8 u1,u2,u3
      real*8 eps
c
c
c     compute the numerical value of the determinant
c
      s11 = psub (r21,r11)
      s12 = psub (r22,r12)
      s13 = psub (r23,r13)
      s21 = psub (r31,r11)
      s22 = psub (r32,r12)
      s23 = psub (r33,r13)
      s31 = psub (r41,r11)
      s32 = psub (r42,r12)
      s33 = psub (r43,r13)
      t1 = s22 * s33
      t2 = s32 * s23
      u1 = psub (t1,t2)
      t1 = s12 * s33
      t2 = s32 * s13
      u2 = psub (t1,t2)
      t1 = s12 * s23
      t2 = s22 * s13
      u3 = psub (t1,t2)
      t1 = s21 * u2
      t2 = s11 * u1
      t3 = s31 * u3
      u1 = padd (t2,t3)
      det = psub (t1,u1)
      eps = 1.0d-10
      if (abs(det) .lt. eps)  det = 0.0d0
c
c     return value based on sign of the determinant
c
      isign = 0
      if (det .gt. 0.0d0) then
         isign = 1
      else if (det .lt. 0.0d0) then
         isign = -1
      end if
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine minor3  --  find the sign of 3x3 determinant  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "minor3" computes the value of a 3x3 determinant built from
c     coordinates of specified balls; if the determinant is zero,
c     then checks minors until a nonzero value is found
c
c
      subroutine minor3 (crdball,a,b,c,i1,i2,result)
      implicit none
      integer a,b,c
      integer i1,i2
      integer result
      integer isign
      integer ida1,ida2
      integer idb1,idb2
      integer idc1,idc2
      real*8 det
      real*8 r11,r21,r31
      real*8 r12,r22,r32
      real*8 crdball(*)
c
c
c     get the value of the determinant and find its sign
c
      ida1 = 3*a + i1 - 3
      ida2 = 3*a + i2 - 3
      idb1 = 3*b + i1 - 3
      idb2 = 3*b + i2 - 3
      idc1 = 3*c + i1 - 3
      idc2 = 3*c + i2 - 3
      r11 = crdball(ida1)
      r12 = crdball(ida2)
      r21 = crdball(idb1)
      r22 = crdball(idb2)
      r31 = crdball(idc1)
      r32 = crdball(idc2)
      result = 1
      call deter3 (det,r11,r12,r21,r22,r31,r32,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
c
c     check signs of minors if full determinant is zero
c
      call deter2 (det,r21,r31,isign)
      if (isign .ne. 0) then
         result = -isign
         return
      end if
      call deter2 (det,r22,r32,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      call deter2 (det,r11,r31,isign)
      if (isign .ne. 0) then
         result = isign
         return
      end if
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine deter3  --  get the value of 3x3 determinant  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "deter3" finds a 3x3 determinant value where the rightmost
c     column is all ones and other elements are given as arguments
c
c
      subroutine deter3 (det,r11,r12,r21,r22,r31,r32,isign)
      implicit none
      integer isign
      real*8 det,psub
      real*8 r11,r21,r31
      real*8 r12,r22,r32
      real*8 t1,t2,t3,t4
      real*8 t14,t23
      real*8 eps
c
c
c     compute the numerical value of the determinant
c
      t1 = psub (r21,r11)
      t2 = psub (r22,r12)
      t3 = psub (r31,r11)
      t4 = psub (r32,r12)
      t14 = t1 * t4
      t23 = t2 * t3
      det = psub (t14,t23)
      eps = 1.0d-10
      if (abs(det) .lt. eps)  det = 0.0d0
c
c     return value based on sign of the determinant
c
      isign = 0
      if (det .gt. 0.0d0) then
         isign = 1
      else if (det .lt. 0.0d0) then
         isign = -1
      end if
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine minor2  --  find the sign of 2x2 determinant  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "minor2" computes the value of a 2x2 determinant built from
c     coordinates of specified balls, and also return the sign
c
c
      subroutine minor2 (crdball,a,b,ia,result)
      implicit none
      integer a,b,ia
      integer result
      integer isign
      integer ida,idb
      real*8 det,r11,r12
      real*8 crdball(*)
c
c
c     get the value of the determinant and find its sign
c
      ida = 3*a + ia - 3
      idb = 3*b + ia - 3
      r11 = crdball(ida)
      r12 = crdball(idb)
      result = 1
      call deter2 (det,r11,r12,isign)
      if (isign .ne. 0)  result = isign
      return
      end
c
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine deter2  --  get the value of 2x2 determinant  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "deter2" finds a 2x2 determinant value where the rightmost
c     column is all ones and other elements are given as arguments
c
c
      subroutine deter2 (det,r11,r12,isign)
      implicit none
      integer isign
      real*8 det,psub
      real*8 r11,r12
      real*8 eps
c
c
c     compute the numerical value of the determinant
c
      det = psub (r11,r12)
      eps = 1.0d-10
      if (abs(det) .lt. eps)  det = 0.0d0
c
c     set return based on sign of the determinant
c
      isign = 0
      if (det .gt. 0.0d0) then
         isign = 1
      else if (det .lt. 0.0d0) then
         isign = -1
      end if
      return
      end
c
c
c     ##########################################################
c     ##                                                      ##
c     ##  function padd  --  addition with a precision check  ##
c     ##                                                      ##
c     ##########################################################
c
c
c     "padd" computes the sum of the two input arguments, and
c     sets the result to zero if the absolute sum or relative
c     values are less than the machine precision
c
c
      function padd (r1,r2)
      implicit none
      real*8 padd
      real*8 r1,r2,eps
      real*8 val,valmax
c
c
c     get the sum of input values using standard math
c
      val = r1 + r2
c
c     round small absolute sum or relative value to zero 
c
      eps = 1.0d-14
      if (abs(val) .lt. eps) then
         val = 0.0d0
      else
         valmax = max(abs(r1),abs(r2))
         if (valmax .ne. 0.0d0) then
            if (abs(val/valmax) .lt. eps)  val = 0.0d0
         end if
      end if
      padd = val
      return
      end
c
c
c     #############################################################
c     ##                                                         ##
c     ##  function psub  --  subtraction with a precision check  ##
c     ##                                                         ##
c     #############################################################
c
c
c     "psub" computes the difference of the two input arguments,
c     and sets the result to zero if the absolute difference or
c     relative values are less than the machine precision
c
c
      function psub (r1,r2)
      implicit none
      real*8 psub
      real*8 r1,r2,eps
      real*8 val,valmax
c
c
c     get difference of input values using standard math
c
      val = r1 - r2
c
c     round small absolute or relative difference to zero 
c
      eps = 1.0d-14
      if (abs(val) .lt. eps) then
         val = 0.0d0
      else
         valmax = max(abs(r1),abs(r2))
         if (valmax .ne. 0.0d0) then
            if (abs(val/valmax) .lt. eps)  val = 0.0d0
         end if
      end if
      psub = val
      return
      end
c
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine build_weight  --  build weight for Delaunay  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "build_weight" builds and returns the weight for the weighted
c     Delaunay triangulation procedure
c
c
      subroutine build_weight (x,y,z,r,w)
      implicit none
      integer*8 ival1,ival2
      real*8 x,y,z,r,w
c
c
c     compute the weight for the Delaunay triangulation
c
      ival1 = nint(10000.0d0*r)
      ival2 = -ival1 * ival1
      ival1 = nint(10000.0d0*x)
      ival2 = ival2 + ival1*ival1
      ival1 = nint(10000.0d0*y)
      ival2 = ival2 + ival1*ival1
      ival1 = nint(10000.0d0*z)
      ival2 = ival2 + ival1*ival1
      w = dble(ival2) / 100000000.0d0
      return
      end
c
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine addbogus  --  add artificial points if needed  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "addbogus" adds artificial points to the system so the total
c     number of vertices is at least equal to four
c
c
      subroutine addbogus (bcoord,brad)
      use shapes
      implicit none
      integer np
      integer i
      real*8 brad(3),bcoord(9)
      real*8 cx,cy,cz
      real*8 c1x,c1y,c1z
      real*8 c2x,c2y,c2z
      real*8 c3x,c3y,c3z
      real*8 u1x,u1y,u1z
      real*8 v1x,v1y,v1z
      real*8 w1x,w1y,w1z
      real*8 c32x,c32y,c32z
      real*8 rmax,d,d1,d2,d3
c
c
c     set number of points to be added
c
      np = 4 - npoint
c
c     initialize the artificial coordinates
c
      do i = 1, 3*np
         bcoord(i) = 0.0d0
      end do
c
c     case for one atom
c
      if (npoint .eq. 1) then
         rmax = radball(1)
         bcoord(1) = crdball(1) + 3.0d0*rmax
         bcoord(3*1+2) = crdball(2) + 3.0d0*rmax
         bcoord(3*2+3) = crdball(3) + 3.0d0*rmax
         do i = 1, np
            brad(i) = rmax / 20.0d0
         end do
c
c     case for two atoms
c
      else if (npoint .eq. 2) then
         rmax = max(radball(1),radball(2))
         c1x = crdball(1)
         c1y = crdball(2)
         c1z = crdball(3)
         c2x = crdball(4)
         c2y = crdball(5)
         c2z = crdball(6)
         cx = 0.5d0 * (c1x+c2x)
         cy = 0.5d0 * (c1y+c2y)
         cz = 0.5d0 * (c1z+c2z)
         u1x = c2x - c1x
         u1y = c2y - c1y
         u1z = c2z - c1z
         if (u1z.ne.0.0d0 .or. u1x.ne.-u1y) then
            v1x = u1z
            v1y = u1z
            v1z = -u1x - u1z
         else
            v1x = -u1y - u1z
            v1y = u1x
            v1z = u1x
         end if
         w1x = u1y*v1z - u1z*v1y
         w1y = u1z*v1x - u1x*v1z
         w1z = u1x*v1y - u1y*v1x
         d = sqrt(u1x*u1x + u1y*u1y + u1z*u1z)
         bcoord(1) = cx + (2.0d0*d+3.0d0*rmax)*v1x
         bcoord(1+3) = cx + (2.0d0*d+3.0d0*rmax)*w1x
         bcoord(2) = cy + (2.0d0*d+3.0d0*rmax)*v1y
         bcoord(2+3) = cy + (2.0d0*d+3.0d0*rmax)*w1y
         bcoord(3) = cz + (2.0d0*d+3.0d0*rmax)*v1z
         bcoord(3+3) = cz + (2.0d0*d+3.0d0*rmax)*w1z
         brad(1) = rmax / 20.0d0
         brad(2) = rmax / 20.0d0
c
c     case for three atoms
c
      else if (npoint .eq. 3) then
         rmax = max(max(radball(1),radball(2)),radball(3))
         c1x = crdball(1)
         c1y = crdball(2)
         c1z = crdball(3)
         c2x = crdball(4)
         c2y = crdball(5)
         c2z = crdball(6)
         c3x = crdball(7)
         c3y = crdball(8)
         c3z = crdball(9)
         cx = (c1x+c2x+c3x) / 3.0d0
         cy = (c1y+c2y+c3y) / 3.0d0
         cz = (c1z+c2z+c3z) / 3.0d0
         u1x = c2x - c1x
         u1y = c2y - c1y
         u1z = c2z - c1z
         v1x = c3x - c1x
         v1y = c3y - c1y
         v1z = c3z - c1z
         w1x = u1y*v1z - u1z*v1y
         w1y = u1z*v1x - u1x*v1z
         w1z = u1x*v1y - u1y*v1x
         d1 = sqrt(w1x*w1x + w1y*w1y + w1z*w1z)
         if (d1 .eq. 0.0d0) then
            if (u1x .ne. 0.0d0) then
               w1x = u1y
               w1y = -u1x
               w1z = 0.0d0
            else if (u1y .ne. 0.0d0) then
               w1x = u1y
               w1y = -u1x
               w1z = 0.0d0
            else
               w1x = u1z
               w1y = -u1z
               w1z = 0.0d0
            end if
         end if
         d1 = sqrt(u1x*u1x + u1y*u1y + u1z*u1z)
         d2 = sqrt(v1x*v1x + v1y*v1y + v1z*v1z)
         c32x = c3x - c2x
         c32y = c3y - c2y
         c32z = c3z - c2z
         d3 = sqrt(c32x*c32x + c32y*c32y + c32z*c32z)
         d = max(d1,max(d2,d3))
         bcoord(1) = cx + (2.0d0*d+3.0d0*rmax)*w1x
         bcoord(2) = cy + (2.0d0*d+3.0d0*rmax)*w1y
         bcoord(3) = cz + (2.0d0*d+3.0d0*rmax)*w1z
         brad(1) = rmax / 20.0d0
      end if
      return
      end
c
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine tetra_volume  --  compute volume of tetrahedron  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "tetra_volume" computes the volume of the tetrahedron
c
c
      subroutine tetra_volume (r12sq,r13sq,r14sq,r23sq,r24sq,r34sq,vol)
      implicit none
      real*8 val1,val2,val3
      real*8 r12sq,r13sq,r14sq
      real*8 r23sq,r24sq,r34sq
      real*8 det5,vol
      real*8 mat5(5,5)
c
c
c     set the values of the matrix elements
c
      mat5(1,1) = 0.0d0
      mat5(1,2) = r12sq
      mat5(1,3) = r13sq
      mat5(1,4) = r14sq
      mat5(1,5) = 1.0d0
      mat5(2,1) = r12sq
      mat5(2,2) = 0.0d0
      mat5(2,3) = r23sq
      mat5(2,4) = r24sq
      mat5(2,5) = 1.0d0
      mat5(3,1) = r13sq
      mat5(3,2) = r23sq
      mat5(3,3) = 0.0d0
      mat5(3,4) = r34sq
      mat5(3,5) = 1.0d0
      mat5(4,1) = r14sq
      mat5(4,2) = r24sq
      mat5(4,3) = r34sq
      mat5(4,4) = 0.0d0
      mat5(4,5) = 1.0d0
      mat5(5,1) = 1.0d0
      mat5(5,2) = 1.0d0
      mat5(5,3) = 1.0d0
      mat5(5,4) = 1.0d0
      mat5(5,5) = 0.0d0
c
c     compute the value of the determinant
c
      val1 = mat5(2,3) - mat5(1,2) - mat5(1,3)
      val2 = mat5(2,4) - mat5(1,2) - mat5(1,4)
      val3 = mat5(3,4) - mat5(1,3) - mat5(1,4)
      det5 = 8.0d0*mat5(1,2)*mat5(1,3)*mat5(1,4)
     &          - 2.0d0*val1*val2*val3 - 2.0d0*mat5(1,2)*val3*val3
     &          - 2.0d0*mat5(1,3)*val2*val2 - 2.0d0*mat5(1,4)*val1*val1
      if (det5 .lt. 0.0d0)  det5 = 0.0d0
      vol = sqrt(det5/288.0d0);
      return
      end
