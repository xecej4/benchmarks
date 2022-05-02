This is a modified version of the older version at the Debian benchmarks site. On my PC, using Ifort OneAPI 2021.5, my modifications gave a speed gain of 18 percent compared to the older Fortran program, and the new Fortran version is about 13 percent faster than the Julia version on the Debian benchmarks site.

Most of the compuatational time is spent in subroutine advance(). I replaced the three sets of nested DO loops in that subroutine by two sets.

In this version, the special technique of using the X64 SSE instruction RSQRTSS to generate a single precision approximation to 1/sqrt(x), followed by a single iteration of double precision Newton-Raphson polishing the root, which is used in the Julia version of Nbody, is not used since it did not yield better performance than the straightforward calculation of x^(-3/2), for a given x.
