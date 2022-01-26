# This file contains algorithms needed for the integratiorn of 
# coupled Risch differential systems from chapter 8 of the book
#
#    Manuel Bronstein, Symbolic Integration I: Transcendental Functions,
#    2nd ed., Springer 2005. 
#

"""
    CoupledDECancelPrim(b₁, b₂, c₁, c₂,  D[, n=∞]) -> (q₁, q₂, ρ)

Coupled Polynomial Risch differential system, cancellation - primitive case.

Given a field `k` not containing `√-1` , a derivation `D` on `k[t]` with `D(t)` in `k` , an integer `n`,
`b₁`, `b₂` in `k` with `(b₁,b₂)≠(0,0)` and `c₁`, `c₂` in `k[t]`, return either
`ρ=0`, in which case the system of equations `D(q₁)+b₁*q₁-b₂*q₂=c₁`, `D(q₂)+b₂*q₁+b₁*q₂=c₂`
has no solution `q₁`, `q₂` with both degrees at most `n` in `k[t]`,
or `ρ=1` and a solution `(q₁,q₂)` in `k[t]×k[t]` of this system with `degree(q₁)≤n`
and `degree(q₂)≤n`.

See [Bronstein's book](https://link.springer.com/book/10.1007/b138171), Section 8.2, p. 260.
"""
function CoupledDECancelPrim(b1::T, b2::T,  c1::P, c2::P, D::Derivation, n::Int=typemax(Int)) where
    {T<:RingElement, P<:PolyElem{T}} # here typemax(Int) represents +infinity
    isprimitive(D) ||
        error("monomial of derivation D must be primitive")
    D0 = BaseDerivation(D)
    (iscompatible(b1, D0) && iscompatible(b2, D0)) || 
        error("coefficients b1 and b2 must be in the domain of the base derivation of D")
    (iscompatible(c1, D) && iscompatible(c2, D)) || 
        error("polynomials c1 and c2 must be in the domain of derivation D")
    Z = zero(c1)
    no_solution = (Z, Z, 0)
    # TODO: case (b1, b2)==(0, 0) !?
    t = gen(parent(c1))
    _, I, D0I = Complexify(parent(b1), D0)
    z, ρ = InFieldLogarithmicDerivative(b + 0*I, D0I) 
    if ρ>0
        z1 = real(z)
        z2 = imag(z)
        p10, ρ = InFieldDerivative(z1*c1 - z2*c2, D)
        p1 = numerator(p10)
        if ρ<=0 || !isone(denominator(p10)) || degree(p1)>n
            return no_solution 
        end
        p20, ρ = InFieldDerivative(z2*c1 + z1*c2, D)
        p2 = numerator(p20)
        if ρ<=0 || !isone(denominator(p20)) || degree(21)>n
            return no_solution 
        end
        d = z1^2 + z1^2
        return (z1*p1 + z2*p2)//d, (z1*p2 - z2*p1)//d, 1
    end
    if iszero(c1) && iszero(c2)
        return Z, Z, 1 # zero is solution
    end
    if n<max(degree(c1), degree(c2))
        return no_solution
    end
    q1 = Z   
    q2 = Z
    while !iszero(c1) || !iszero(c2)
        m = max(degree(c1), degree(c2))
        if n<m
            return no_solution
        end
        s1, s2, ρ = CoupledDESystem(b1, b2, coefficient(c1, m), coefficient(c2, m), D0)
        if ρ<=0
            return no_solution
        end
        q1 = q1 + s1*t^m
        q2 = q2 + s2*t^m
        n = m - 1
        c1 -= D(s1*t^m) + (b1*s1 - b2*s2)*t^m
        c2 -= D(s2*t^m) + (b2*s1 + b1*s2)*t^m
    end
    q1, q2, 1
end


"""
    CoupledDECancelExp(b₁, b₂, c₁, c₂,  D[, n=∞]) -> (q₁, q₂, ρ)

Coupled Polynomial Risch differential system, cancellation - hyperexponential case.

Given a field `k` not containing `√-1` , a derivation `D` on `k[t]` with `D(t)/t` in `k` , an integer `n`,
`b₁`, `b₂` in `k` with `(b₁,b₂)≠(0,0)` and `c₁`, `c₂` in `k[t]`, return either
`ρ=0`, in which case the system of equations `D(q₁)+b₁*q₁-b₂*q₂=c₁`, `D(q₂)+b₂*q₁+b₁*q₂=c₂`
has no solution `q₁`, `q₂` with both degrees at most `n` in `k[t]`,
or `ρ=1` and a solution `(q₁,q₂)` in `k[t]×k[t]` of this system with `degree(q₁)≤n`
and `degree(q₂)≤n`.

See [Bronstein's book](https://link.springer.com/book/10.1007/b138171), Section 8.2, p. 262.
"""
function CoupledDECancelExp(b1::T, b2::T,  c1::P, c2::P, D::Derivation, n::Int=typemax(Int)) where
    {T<:RingElement, P<:PolyElem{T}} # here typemax(Int) represents +infinity
    ishyperexponential(D) ||
        error("monomial of derivation D must be hyperexponential")
    D0 = BaseDerivation(D)
    (iscompatible(b1, D0) && iscompatible(b2, D0)) || 
        error("coefficients b1 and b2 must be in the domain of the base derivation of D")
    (iscompatible(c1, D) && iscompatible(c2, D)) || 
        error("polynomials c1 and c2 must be in the domain of derivation D")
    Z = zero(c1)
    no_solution = (Z, Z, 0)
    # TODO: case (b1, b2)==(0, 0) !?
    t = gen(parent(c1))
    _, I, D0I = Complexify(parent(b1), D0)
    H = MonomialDerivative(D)
    w = coeff(H,1) # = Dt/t for hyperexponentialm case
    n, m, z, ρ = ParametricLogarithmicDerivative(b+0*I, w+0*I, D0I)
    if  ρ>0 && n==1
        z1 = real(z)
        z2 = imag(z)                
        p1, ρ = InFieldDerivative((z1*c1 - z2*c2)*t^m, D)        
        if ρ<=0 || !isreduced(p1, D)
            return no_solution 
        end
        h = (t//1)^(-m)//(z1^2 + z2^2)
        q10 = (z1*p1 + z2*p2)*h
        q1 = numerator(q10)
        if !isone(denominator(q10)) || degree(q1)>n
            return no_solution
        end
        p2, ρ = InFieldDerivative((z2*c1 + z1*c2)*t^m, D)
        if ρ<=0 || !isreduced(p1, D)
            return no_solution 
        end
        q20 = (z1*p2 - z2*p1)*h
        q2 = numerator(q20)
        if !isone(denominator(q20)) || degree(q2)>n
            return no_solution
        end
        return q1, q2, 1
    end
    if iszero(c1) && iszero(c2)
        return Z, Z, 1 # zero is solution
    end
    if n<max(degree(c1), degree(c2))
        return no_solution
    end
    q1 = Z   
    q2 = Z
    while !iszero(c1) || !iszero(c2)
        m = max(degree(c1), degree(c2))
        if n<m
            return no_solution
        end
        s1, s2, ρ = CoupledDESystem(b1 + m*w, b2, coefficient(c1, m), coefficient(c2, m), D0)
        if ρ<=0
            return no_solution
        end
        q1 = q1 + s1*t^m
        q2 = q2 + s2*t^m
        n = m - 1
        c1 -= D(s1*t^m) + (b1*s1 - b2*s2)*t^m
        c2 -= D(s2*t^m) + (b2*s1 + b1*s2)*t^m
    end
    q1, q2, 1    
end

"""
    CoupledDECancelTan(b₀, b₂, c₁, c₂,  D[, n=∞]) -> (q₁, q₂, ρ)

Coupled Polynomial Risch differential system, cancellation - hypertangent case.

Given a field `k` not containing `√-1` , a derivation `D` on `k[t]` with `D(t)/(t²+1)=η` in `k` , an integer `n`,
`b₀`, `b₂` in `k` with `(b₀,b₂)≠(0,0)` and `c₁`, `c₂` in `k[t]`, return either
`ρ=0`, in which case the system of equations `D(q₁)+(b₀-n*η*t)*q₁-b₂*q₂=c₁`, `D(q₂)+b₂*q₁+(b₀+n*η*t)*q₂=c₂`
has no solution `q₁`, `q₂` with both degrees at most `n` in `k[t]`,
or `ρ=1` and a solution `(q₁,q₂)` in `k[t]×k[t]` of this system with `degree(q₁)≤n`
and `degree(q₂)≤n`.

See [Bronstein's book](https://link.springer.com/book/10.1007/b138171), Section 8.2, p. 262.
"""
function CoupledDECancelTan(b0::T, b2::T,  c1::P, c2::P, D::Derivation, n::Int=typemax(Int)) where
    {T<:RingElement, P<:PolyElem{T}} # here typemax(Int) represents +infinity
    ishypertangentl(D) ||
        error("monomial of derivation D must be hypertangent")
    D0 = BaseDerivation(D)
    (iscompatible(b0, D0) && iscompatible(b2, D0)) || 
        error("coefficients b0 and b2 must be in the domain of the base derivation of D")
    (iscompatible(c1, D) && iscompatible(c2, D)) || 
        error("polynomials c1 and c2 must be in the domain of derivation D")
    Z = zero(c1)
    no_solution = (Z, Z, 0)
    # TODO: case (b0, b2)==(0, 0) !?
    if n==0
        if degree(c1)<=0 && degree(c2)<=0
            q1, q2, ρ = CoupledDESystem(b0, b2, constant_coefficient(c1), constant_coefficient(c2), BaseDerivation(D))
            if ρ<=0
                return no_solution
            end
            return q1+Z, q2+Z, 1
        end
        return no_solution
    end
    t = gen(parent(c1))
    H = MonomialDerivative(D)
    η = constant_coefficient(divexact(H, t^2+1))
    ktI, I, DI = Complexify(FractionField(parent(c1), D)) # k(t)(√-1)    
    p = t - I
    _, _, I1, _ =  switch_t_i(ktI, DI) # k(√-1)(t)
    z = backtransform(c1(I1), t, I) + backtransform(c2(I1), t, I)*I
    z1 = real(z)
    @assert isopne(denominator(z1)) && degree(z1)<=0
    z1 = constant_coefficient(z1)  # real(z) in k(t), z1 in k
    z2 = imag(z)
    @assert isone(denominator(z2)) && degree(z2)<=0
    z2 = constant_coefficient(z2)  # imag(z) in k(t), z2 in k
    s1, s2, ρ = CoupledDESystem(b0, b2 - n*η, z1, z2, BaseDerivation(D))
    if ρ<=0
        return no_solution
    end
    c = (c1 - z1 +n*η*(s1*t+s2) + (c2 - z2 + n*η*(s2*t-s1))*I)//p
    d1 = real(c)
    @assert isone(denominator(d1))
    d1 = numerator(d1)
    d2 = imag(c)
    @assert isone(denominator(d2))
    d2 = numerator(d2)
    h1, h2, ρ = CoupledDECancelTan(b0, b2 + η, d1, d2, D, n - 1)
    if ρ<=0
        return no_solution
    end
    h1*t + h2 + s1, h2*t - h1 + s2
end