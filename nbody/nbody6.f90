! The Computer Language Benchmarks Game
! https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
!
!   contributed by Simon Geard, translated from  Mark C. Williams nbody.java
!   modified by Brian Taylor
!   modified by yuankun shi
!   modified by Padraig O Conbhui
!
! Further modifications by mecej4

program nbody
  implicit none

  integer, parameter :: dp = kind(1.d0)

  real(kind=dp), parameter :: tstep = 0.01d0
  real(kind=dp), parameter ::  PI = 3.141592653589793d0
  real(kind=dp), parameter ::  SOLAR_MASS = 4 * PI * PI
  real(kind=dp), parameter ::  DAYS_PER_YEAR = 365.24d0

  type body
     real(kind=dp) :: x, y, z, u, vx, vy, vz, vu, mass
  end type body

  type(body), parameter :: jupiter = body( &
       4.84143144246472090d0,    -1.16032004402742839d0, &
       -1.03622044471123109d-01, 0.d0, 1.66007664274403694d-03 * DAYS_PER_YEAR, &
       7.69901118419740425d-03 * DAYS_PER_YEAR, &
       -6.90460016972063023d-05 * DAYS_PER_YEAR, 0.d0,&
       9.54791938424326609d-04 * SOLAR_MASS)

  type(body), parameter :: saturn = body( &
       8.34336671824457987d+00, &
       4.12479856412430479d+00, &
       -4.03523417114321381d-01, 0.d0, &
       -2.76742510726862411d-03 * DAYS_PER_YEAR, &
       4.99852801234917238d-03 * DAYS_PER_YEAR, &
       2.30417297573763929d-05 * DAYS_PER_YEAR, 0.d0,&
       2.85885980666130812d-04 * SOLAR_MASS)

  type(body), parameter :: uranus = body( &
       1.28943695621391310d+01, &
       -1.51111514016986312d+01, &
       -2.23307578892655734d-01, 0.d0,&
       2.96460137564761618d-03 * DAYS_PER_YEAR, &
       2.37847173959480950d-03 * DAYS_PER_YEAR, &
       -2.96589568540237556d-05 * DAYS_PER_YEAR, 0.d0,&
       4.36624404335156298d-05 * SOLAR_MASS )

  type(body), parameter :: neptune = body( &
       1.53796971148509165d+01, &
       -2.59193146099879641d+01, &
       1.79258772950371181d-01, 0.d0,&
       2.68067772490389322d-03 * DAYS_PER_YEAR, &
       1.62824170038242295d-03 * DAYS_PER_YEAR, &
       -9.51592254519715870d-05 * DAYS_PER_YEAR, 0.d0,&
       5.15138902046611451d-05 * SOLAR_MASS)

  type(body), parameter :: sun = body(0.0d0, 0.0d0, 0.0d0, 0.0d0, 0.0d0, &
        0.0d0, 0.d0, 0.d0, SOLAR_MASS)

  integer, parameter :: nb = 5
  integer, parameter :: N = (nb-1)*nb/2

  real(kind=dp), parameter :: mass(nb) = (/ sun%mass, jupiter%mass, saturn%mass, &
        uranus%mass, neptune%mass /)

  integer :: num, i
  character(len=8) :: argv

  real(kind=dp) :: e, x(3,nb), v(3,nb)

  x(:,1) = (/ sun%x, sun%y, sun%z /)
  x(:,2) = (/ jupiter%x, jupiter%y, jupiter%z /)
  x(:,3) = (/ saturn%x, saturn%y, saturn%z /)
  x(:,4) = (/ uranus%x, uranus%y, uranus%z /)
  x(:,5) = (/ neptune%x, neptune%y, neptune%z /)

  v(:,1) = (/ sun%vx, sun%vy, sun%vz /)
  v(:,2) = (/ jupiter%vx, jupiter%vy, jupiter%vz /)
  v(:,3) = (/ saturn%vx, saturn%vy, saturn%vz /)
  v(:,4) = (/ uranus%vx, uranus%vy, uranus%vz /)
  v(:,5) = (/ neptune%vx, neptune%vy, neptune%vz /)

  call getarg(1, argv)
  read (argv,*) num

  call offsetMomentum(1, v, mass)
  e = energy(x, v, mass)
  write (*,'(f12.9)') e
  do i = 1, num
     call advance(tstep, x, v, mass)
  end do
  e = energy(x, v, mass)
  write (*,'(f12.9)') e

contains

  pure subroutine offsetMomentum(k, v, mass)
    integer, intent(in) :: k
    real(kind=dp), dimension(3,nb), intent(inout) :: v
    real(kind=dp), dimension(nb), intent(in) :: mass
    real(kind=dp), dimension(3) :: p

    p = (/ (sum(v(i,:) * mass(:)), i=1,3) /)
    v(:,k) = -p / SOLAR_MASS
  end subroutine offsetMomentum


  pure subroutine advance(tstep, x, v, mass)
    real(kind=dp), intent(in) :: tstep
    real(kind=dp), dimension(3,nb), intent(inout) :: x, v
    real(kind=dp), dimension(nb), intent(in) :: mass
    real(kind=dp) :: mag(N)

    integer :: i, j, m
    m = 1
    do i = 1, nb
       do j = i + 1, nb
          mag(m) = tstep*sum((x(:,i) - x(:,j))**2)**(-1.5d0)
          m = m + 1
       end do
    end do

    m = 1
    do i = 1, nb
       do j = i + 1, nb
          v(:,i) = v(:,i) - (x(:,i) - x(:,j)) * mass(j) * mag(m)
          v(:,j) = v(:,j) + (x(:,i) - x(:,j)) * mass(i) * mag(m)
          m = m + 1
       end do
    end do

    x = x + tstep * v
  end subroutine advance

  pure function energy(x, v, mass)
    real(kind=dp) :: energy
    real(kind=dp), dimension(3,nb), intent(in) :: x, v
    real(kind=dp), dimension(nb), intent(in) :: mass

    integer :: i, j

    energy = 0.0d0
    do i = 1, nb
       energy = energy + 0.5d0 * mass(i) * sum(v(:,i)**2)
       do j = i + 1, nb
          energy = energy - (mass(i) * mass(j)) / &
             sqrt(sum((x(:,i) - x(:,j))*(x(:,i) - x(:,j))))
       end do
    end do
  end function energy

end program nbody
