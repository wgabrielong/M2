
-------------------------------------------------------
-- Documentation taken from old versions of the package
-- includes documentation of previous experimental features
-- and old versions of functions

doc /// 
    Key
        "Experimental feature: SAGBI bases of subrings of quotient rings"
    Description
        Text
	  The paper "Using SAGBI bases to compute invariants" by Stillman and Tsai (1990) describes algorithms for computing Sagbi bases of subrings contained in quotient rings.
	  The following code demonstrates Example 2 from that paper (in the case $N=4$.)
	CannedExample
	  N = 4;
	  gndR = QQ[(a,b,c,d)|(u_1..u_N)|(v_1..v_N), MonomialOrder => Lex];
	  I = ideal(a*b - b*c - 1);
	  quot = gndR/I;
	  U = (vars quot)_{4..(N+3)}
	  V = (vars quot)_{(N+4)..(2*N+3)}
	  G = flatten for i from 0 to N-1 list(
    	      {a*(U_(0,i)) + b*(V_(0,i)), c*(U_(0,i)) + d*(V_(0,i))}
    	      );
	  sag = sagbi G
	  ans = matrix {{c*u_4+d*v_4, c*u_3+d*v_3, c*u_2+d*v_2, c*u_1+d*v_1, a*u_4+b*v_4, a*u_3+b*v_3, a*u_2+b*v_2,
     		  a*u_1+b*v_1, a*d*u_3*v_4-a*d*u_4*v_3-b*c*u_3*v_4+b*c*u_4*v_3,
     		  a*d*u_2*v_4-a*d*u_4*v_2-b*c*u_2*v_4+b*c*u_4*v_2, a*d*u_2*v_3-a*d*u_3*v_2-b*c*u_2*v_3+b*c*u_3*v_2,
     		  a*d*u_1*v_4-a*d*u_4*v_1-b*c*u_1*v_4+b*c*u_4*v_1, a*d*u_1*v_3-a*d*u_3*v_1-b*c*u_1*v_3+b*c*u_3*v_1,
     		  a*d*u_1*v_2-a*d*u_2*v_1-b*c*u_1*v_2+b*c*u_2*v_1}}
	  assert (gens sag == ans);
        Text
	  In general, when a finite SAGBI basis does happen to exist, the algorithm *should* be able to calculate it correctly given enough
	  time.
	  However, there are some peculiarities in the case of quotient rings, such as \"false termination\" Example 1 from the same paper:
	Example
	  gndR = QQ[x,y, MonomialOrder => Lex];
	  I = ideal(x^2 - x*y);
	  Q = gndR/I;
	  subR = sagbi subring {x};
	  gens subR
	Text 
	  Although the initial algebra in this example is infinitely generated, new generators are not generated as expected from S-pairs.
///
doc /// 
    Key
        "Experimental feature: modules over subrings"
    Description
        Text
            We illustrate modules over subrings are implemented through an example.
	        The following is Example 11.19 from "Groebner bases and Convex Polytopes" by Bernd Sturmfels:
        CannedExample
	  i = 2;
	  gndR = QQ[t_1, t_2, t_3];
	  A := {t_1*t_2*t_3,
		t_1^2*t_2,
		t_1*t_2^2,
		t_1^2*t_3,
		t_1*t_3^2,
		t_2^2*t_3,
		t_2*t_3^2};
	  G := matrix {{t_1^4*t_2^4*t_3^4, t_1^8*t_2*t_3^6}}
	  subR = subring sagbi subring A;
	  assert((set first entries gens subR) === (set A)); 
	  tsyz := toricSyz(subR, G);
	  assert(tsyz * (transpose G) == 0);
	  ans1 = mingensSubring(subR, tsyz);  
	Text
	  The resulting value of @TT "ans1"@ and its normal form are:
	CannedExample
	  i13 : ans1

	  o13 = | t_1^4t_3^5    -t_2^3t_3^3    |
		| t_1^4t_2t_3^4 -t_2^4t_3^2    |
		| t_1^5t_3^4    -t_1t_2^3t_3^2 |
		| t_1^5t_2t_3^3 -t_1t_2^4t_3   |
		| t_1^6t_3^3    -t_1^2t_2^3t_3 |
		| t_1^6t_2t_3^2 -t_1^2t_2^4    |
		| t_1^4t_3^8    -t_2^3t_3^6    |

			7       2
	  o13 : Matrix R  <--- R
	  
	  i14 : ans1//subR

	  o14 = | p_4^2p_7  -p_3p_5 |
	       | p_4^2p_9  -p_5^2  |
	       | p_4p_7^2  -p_3p_8 |
	       | p_4p_7p_9 -p_5p_8 |
	       | p_7^3     -p_5p_9 |
	       | p_7^2p_9  -p_8^2  |
	       | p_4^4     -p_3^3  |

				  7                  2
	  o14 : Matrix (QQ[p ..p ])  <--- (QQ[p ..p ])
			   0   9              0   9
    	Text
	  --This appears to agree with Sturmfels's prediction, although it is not possible to be entirely certain that this computation
	  --is correct without knowing more than the information contained in the Sturmfels text. This is because Sturmfels does not
	  --fully specify what the set of minimal generators of this syzygy module are. Namely, it is only stated that it must include
	  --$2i+2=6$ syzygies of total degree $i+1 = 3$.
	
	  The following code illustrates the function @TO "mingensSubring"@:
	  
	CannedExample	
	  -- Performs autoreduction on M treated as a module over subR.
	  mingensSubring = method(TypicalValue => Matrix)
	  mingensSubring(Subring, Matrix) := (subR, M) -> (  
	      (A, B, gVars)  := moduleToSubringIdeal(subR, M);
	      final := autoreduce(A, transpose B);
	      -- Sort the rows of the matrix for more predictable behavior.
	      final = matrix transpose {sort first entries transpose final};
	      final = extractEntries(final, gVars);
    	      subR#"presentation"#"fullSubstitution"(sub(final,subR#"presentation".tensorRing))
	      );
	Text
	   The function @TO "mingensSubring"@ works by converting the given matrix (which should be thought of as a module) to an
	   ideal inside of a subring, and then performing autoreduction on the generators of that ideal. It relies on the function
	   @TO "moduleToSubringIdeal"@ to construct a suitable subring and provide the generators that define this ideal.
	   Consider the output of the following command:
	CannedExample
	  i5 : debugPrintMap (subR#"presentation"#"fullSubstitution")
	  maps p_0 to t_1
	  maps p_1 to t_2
	  maps p_2 to t_3
	  maps p_3 to t_2*t_3^2
	  maps p_4 to t_1*t_3^2
	  maps p_5 to t_2^2*t_3
	  maps p_6 to t_1*t_2*t_3
	  maps p_7 to t_1^2*t_3
	  maps p_8 to t_1*t_2^2
	  maps p_9 to t_1^2*t_2
        Text
	  
	        @TT "p_0"@, ..., @TT "p_9"@ are the variables of what is referred to in the code as the @TT "tensorRing"@,
            which has two types of variables: The variables corresponding to the variables in the @TO "ambient"@ ring (@TT "p_0"@,...,@TT "p_2"@ in this example) and the variables corresponding to the generators of the @TO "Subring"@ (@TT "p_3"@,...,@TT "p_9"@ in this example).
	  
	        The function @TO "moduleToSubringIdeal"@ converts the toric syzygy module from our example (which is returned by @TO "toricSyz"@ in the form of a matrix) to an ideal
	        within a subring. This is identical to the @TO "moduleToSubringIdeal"@ call that occurs in the first line of @TO "mingensSubring"@.
	CannedExample
	   i15 : (modRing, idealGens, gVars) = moduleToSubringIdeal(subR, tsyz)

	   o15 = (subring of QQ[p_0..p_11], | -p_0^6p_2^3p_10+p_0^2p_1^3p_2p_11   |, | p_10 p_11 |)
					    | -p_0^6p_1p_2^2p_10+p_0^2p_1^4p_11   |
					    | -p_0^6p_2^3p_10+p_0^2p_1^3p_2p_11   |
					    | -p_0^5p_1p_2^3p_10+p_0p_1^4p_2p_11  |
					    | -p_0^5p_2^4p_10+p_0p_1^3p_2^2p_11   |
					    | -p_0^5p_2^4p_10+p_0p_1^3p_2^2p_11   |
					    | -p_0^4p_1p_2^4p_10+p_1^4p_2^2p_11   |
					    | -p_0^4p_2^5p_10+p_1^3p_2^3p_11      |
					    | p_0^8p_2^4p_10-p_0^4p_1^3p_2^2p_11  |
					    | -p_0^7p_2^5p_10+p_0^3p_1^3p_2^3p_11 |
					    | -p_0^5p_2^7p_10+p_0p_1^3p_2^5p_11   |
					    | -p_0^4p_2^8p_10+p_1^3p_2^6p_11      |
					    | -p_0^6p_2^6p_10+p_0^2p_1^3p_2^4p_11 |
					    
	   i16 : debugPrintMap(modRing#"presentation"#"fullSubstition")
	   maps p_0 to p_0
	   maps p_1 to p_1
	   maps p_2 to p_2
	   maps p_3 to p_3
	   maps p_4 to p_4
	   maps p_5 to p_5
	   maps p_6 to p_6
	   maps p_7 to p_7
	   maps p_8 to p_8
	   maps p_9 to p_9
	   maps p_10 to p_10
	   maps p_11 to p_11
	   maps p_12 to p_10
	   maps p_13 to p_11
	   maps p_14 to p_1*p_2^2
	   maps p_15 to p_0*p_2^2
	   maps p_16 to p_1^2*p_2
	   maps p_17 to p_0*p_1*p_2
	   maps p_18 to p_0^2*p_2
	   maps p_19 to p_0*p_1^2
	   maps p_20 to p_0^2*p_1
    	Text
	        The ambient ring of @TT "modRing"@ is the tensor ring of @TT "subR"@, except two new variables @TT "p_10"@ and @TT "p_11"@ have been added.
	        The variables @TT "p_10"@ and @TT "p_11"@ correspond to the generators of the module. The generators @TT "p_12"@ and @TT "p_13"@ also correspond
	        to the generators of the module.
	  
            The primary reason why this implementation should be considered experimental is that the monomial order of a module is not fully specified:
            When a @TO "Subring"@ instance is created using the function @TO "subring"@, the monomial order of the ambient variables is the same as the monomial
	        order of their corresponding variables in the ambient ring while the monomial order of the variables corresponding to generators is assigned arbitrarily. The problem with this system is
	        that it is likely to cause bugs in the case where a subring's ambient ring is the tensor ring of another subring.
	  	 
    SeeAlso
      (moduleToSubringIdeal, Subring, Matrix)
      (mingensSubring, Subring, Matrix)
      (symbol ^, Subring, ZZ)
///


doc ///
   Key
     (symbol %, RingElement, Subring)
   Headline
     Remainder modulo a subring
   Usage
     r = f % A
   Inputs
     f:RingElement
       of the ambient ring of $A$ (endowed with some monomial order.)
     A:Subring
   Outputs
     r:RingElement
       the normal form of f modulo $A$
   Description
     Text
       The result $r$ is zero if and only if $f$ belongs to $A$.  This function should be considered experimental.
     Example
       R = QQ[x1, x2, x3];
       A = subring {x1+x2+x3, x1*x2+x1*x3+x2*x3, x1*x2*x3, (x1-x2)*(x1-x3)*(x2-x3)} --usual invariants of A_3
       f = x1 + x2 + 2*x3
       f % A
       g = x1^2*x2 + x2^2*x3 + x3^2*x1
       g % A
   SeeAlso
    Subring
    subring
///


doc ///
   Key
     Subring
   Headline
     The type of all subrings
   Description
     Text
       
        @TT "Subring"@ is a type that stores information associated to a subring of a polynomial ring, such as a set of subring generators and a reference to the polynomial ring it is contained in.  An instance of a @TT "Subring"@ is constructed with the function @TO "subring"@.
       
       Every instance of @TT "Subring"@ is guaranteed to have the following keys:
       
       @UL {
	    {BOLD {"ambientRing"}, ": The polynomial ring that contains the subring instance's generators."},
	    {BOLD {"generators"}, ": A one-row matrix, the generators of the subring."},
	    {BOLD {"isSAGBI"}, ": A boolean that is false by default. This flag is only set to true in subring instances resulting from a Sagbi computation that terminated successfully. If this is true, the generators are a Sagbi basis."},
	    {BOLD {"presentation"}, ": An instance of the ", TO "PresRing", " type associated with the subring's generators."},
	    {BOLD {"cache"}, ": Contains unspecified information. The contents of the cache may effect performance, but should never effect the result of a computation."}
	   }@

   SeeAlso
       subring
       PresRing
       (gens, Subring)
       (ambient, Subring)
       sagbi
///

doc ///
   Key
     SAGBIBasis
   Headline
     The type of all sagbi bases
   Description
     Text
        This is a computation object for sagbi bases.  It stores a partial sagbi computation for picking up a computation where it left off.  An instance of a @TT "SAGBIBasis"@ is constructed with the function @TO "sagbiBasis"@ and as the output of @TO "sagbi"@.

        Every instance of @TT "SAGBIBasis"@ is guaranteed to have the following keys:

        @UL {
        {BOLD {"ambientRing"}, ": The polynomial ring that contains the subring instance's generators."},
        {BOLD {"subringGenerators"}, ": A one-row matrix, the generators of the subring."},
        {BOLD {"sagbiGenerators"}, ": A one-row matrix, the currently computed sagbi generators."},
        {BOLD {"sagbiDegrees"}, ": A one-row matrix, the degrees of the sagbi generators."},
        {BOLD {"sagbiDone"}, ": A flag that indicates whether the sagbi computation has completed."},
        {BOLD {"stoppingData=>limit"}, ": An integer containing the degree ", TO "Limit", " for the binomial S-pairs that are computed in the sagbi computation."},
        {BOLD {"presentation"}, ": An instance of the ", TO "PresRing", " type associated with the subring's generators."},
        {BOLD {"pending, stoppingData=>degree"}, ": Internal data used for restarting the sagbi computation."}
        }@
///

doc ///
   Key
     PresRing
   Headline
     Stores data on the lifted presentation ring of a subring.
   Description
     Text
       The @TO "PresRing"@ type contains about a @TO "Subring"@ instance is related to the @ITALIC "lifted presentation ring"@ of a subring. In the code, the lifted presentation of a subring is referred to as the @TT "tensorRing"@.

       An instance of the  @TO "PresRing"@ type contains the following keys:
       
       @UL {
	    {BOLD {"tensorRing"}, ": The lifted presentation ring of the given subring."},
	    {BOLD {"sagbiInclusion"}, ": A map from ", TT {"tensorRing"}, " to ", TT {"tensorRing"}},
        {BOLD {"projectionAmbient"},  ": A map from ", TT {"tensorRing"}, " to the ", TT {"ambient ring"}, "."},
	    {BOLD {"inclusionAmbient"},  ": A map from the ", TT {"ambient ring"}, " to ", TT {"tensorRing"}},
	    {BOLD {"substitution"}, ": A map from ", TT {"tensorRing"}, " to ", TT {"tensorRing"}},
	    {BOLD {"fullSubstitution"}, ": Composition of ",TT {"substitution"}, " and ", TT {"projectionAmbient."}},
	    {BOLD {"syzygyIdeal"}, ": This is used in the function ", TO "sagbi", " to calculate toric syzygies."},
	    {BOLD {"liftedPres"}, ": This is used in normal form calculations."}
	   }@
     Text 
       To understand the maps stored inside of a @TO "PresRing"@ instance, it is informative to look at the output of @TO "debugPrintAllMaps"@:
     CannedExample
       i1 : gndR = QQ[x, y];

       i2 : subR = subring {y, y*x-x^2, y*x^2};

       i3 : debugPrintAllMaps subR
       - sagbiInclusion:
       maps p_0 to 0
       maps p_1 to 0
       maps p_2 to p_2
       maps p_3 to p_3
       maps p_4 to p_4
       - projectionAmbient:
       maps p_0 to x
       maps p_1 to y
       maps p_2 to 0
       maps p_3 to 0
       maps p_4 to 0
       - inclusionAmbient:
       maps x to p_0
       maps y to p_1
       - substitution:
       maps p_0 to p_0
       maps p_1 to p_1
       maps p_2 to p_1
       maps p_3 to -p_0^2+p_0*p_1
       maps p_4 to p_0^2*p_1
       - fullSubstitution:
       maps p_0 to x
       maps p_1 to y
       maps p_2 to y
       maps p_3 to -x^2+x*y
       maps p_4 to x^2*y
     Text
        This type is typically not used externally to @TO "Subring"@ type.
   SeeAlso
       subring
       PresRing
       (gens, Subring)
       (ambient, Subring)
       sagbi
///

doc ///
   Key
     autoreduce
     (autoreduce, Subring, Matrix)
   Headline
     Perform autoreduction of the generators of an ideal of a subring.
   Inputs
     subR:Subring
      whose generators are a sagbi basis.
     idealGens:Matrix
       a one-row matrix whose entries are the elements of subR are generators of an ideal $I$.
   Usage
     result = autoreduce(subR, idealGens)
   Outputs
     result:Matrix
       the reduced generators of the ideal generated by the entries of M.
   Description
     Text
       Performs autoreduction on the generators of an ideal within a @TO "subring"@.  Iteratively, each generator $g\in M$ is replaced with the normal form of $g$ relative to $M\setminus \{g\}$, computed using
       the function @TO "intrinsicReduce"@.

   SeeAlso
        autosubduce
///
doc ///
   Key
     subduction
     (subduction, Matrix, RingElement)
     (subduction, Matrix, Matrix)
   Headline
     Performs subduction by the generators of a subring.
   Inputs
     f:RingElement
         an element of @TO "ring"@ @TT "M"@.
     M:Matrix
     	 a one-row matrix containing elements @TO "ring"@ @TT "M"@.
     subGens:Matrix
     	 a one-row matrix containing elements @TO "ring"@ @TT "M"@.
   Outputs
     result:RingElement
       of @TO "ring"@ @TT "M"@
     resultMat:Matrix
        of elements of @TO "ring"@ @TT "M"@
   Usage 
     result = subduction(subGens, f)
     resultMat = subduction(subGens, M)
   Description
     Text
       Performs subduction of the second argument by the elements of @TT "subGens"@.
       If the second argument is a one-row matrix, subduction is performed on each entry 
       individually and the resulting one-row matrix is returned. If the second argument is
       a ring element @TT "f"@, subduction is performed on @TT "f"@ and the result is returned.
       The generators of @TT "subR"@ are not required to be a Sagbi basis.
            
     Example
       gndR = QQ[symbol t_1, symbol t_2, symbol t_3];
       G = matrix {{t_1^4*t_2^4*t_3^4, (t_1^8)*t_2*t_3^8}}
       subduction(G, G_(0,0))
       subduction(G, G_(0,0)*G_(0,1) + t_1)
       subduction(G, t_1)
///

doc ///
   Key
     autosubduce
     (autosubduce, Matrix)
   Headline
     Performs autosubduction on the generators of a subring.
   Usage
     result = internalSubduction(pres)
   Inputs
     subR:Subring
    	whose generators need not be a sagbi basis.
   Outputs
     result:Subring
        generated by the autosubduced generators of subR.
   Description
     Text
       Iteratively replaces each generator $g$ of @TT "subR"@ with the result of subducing @TT "g"@ by (@TT "(gens,Subring)"@ @TT "subR"@)$\setminus \{g\}$.
       
   SeeAlso
     autoreduce
     (internalSubduction, PresRing, RingElement)
///

doc ///
   Key
     isSubalg
     (isSubalg, Subring, Subring)
   Headline
     Calculates whether one subring is contained in another subring.
   Usage
     result = intrinsicReduce(A, B)
   Inputs
     A:Subring
     B:Subring
   Outputs
     result:Boolean
    	whether or not the subring A is contained in the subring B.
   Description
     Text
       This function tests that each of the generators of the subring @TT "A"@ have a normal form of zero with respect to @TT "B"@.
     Example
       R = QQ[t_1, t_2]
       A = subring matrix(R, {{t_1^2, t_1*t_2}});
       B = subring matrix(R, {{t_1^2, t_1*t_2, t_2^2}});
       isSubalg(A,B)
///

doc ///
   Key
     makePresRing
     (makePresRing, Ring, Matrix)
     (makePresRing, Ring, List)
     (makePresRing, Subring)
     [makePresRing, VarBaseName]
   Headline
     Contstructs an instance of the PresRing type
   Usage
     result = makePresRing(gndR, gensMat)
     result = makePresRing(gndR, gensList)
   Inputs
     gndR:PolynomialRing
     	 The ambient ring. Contains the entries of @TT "gensMat"@ or @TT "gensList"@.
     gensList:List
     	 A list of elements of @TT "gndR"@.
     gensMat:Matrix
     	 A one-row matrix of elements of @TT "gndR"@.
     VarBaseName => String
        Determines the symbol used for the variables of the @TT "tensorRing"@ of the resulting @TO "Subring"@ instance.
   Outputs
     result:PresRing
   Description
     Text 
       There are very few situations where it is recommended to use this function directly, it is better to use the function @TT "subring"@ instead.
///


doc ///
   Key
     mingensSubring
     (mingensSubring, Subring, Matrix)
   Headline
      Auto reduces matrix elements
   Usage
     result = mingensSubring(subR, M)
   Inputs
     subR:Subring
     M:Matrix
   Outputs
     result:Thing
    	The autoreduced generators of the given module.
   Description
     Text 
       This function converts the matrix M to a subring ideal, performs autoreduction on the generating set of that ideal, 
       and then returns the result in the form of a matrix.
///

doc ///
   Key
     moduleToSubringIdeal
     (moduleToSubringIdeal, Subring, Matrix)
   Headline
     Convert a module as a matrix to a subring ideal.
   Usage
     (moduleSubR,result,gVars) = mingensSubring(subR, M)
   Inputs
     subR:Subring
     	 whose generators are a sagbi basis
     M:Matrix
     	 whose elements are in subR.
   Outputs
     moduleSubR:Subring
     result:Matrix
     	a one-column matrix whose entries are the generators of the subring ideal.
     gVars:Matrix
     	a one-row matrix whose entries are the generators of the module.
   Description
     Text 
       This function is experimental.
   SeeAlso
     "Experimental feature: modules over subrings"
///

doc ///
   Key
     subalgEquals
     (symbol ==, Subring, Subring)
     (subalgEquals, Subring, Subring)
   Headline
     Check if two subrings are equal.
   Usage
     result = subalgEquals(A,B)
     A == B
   Inputs
     A:Subring
     B:Subring
   Outputs
     result:Boolean
   Description
     Text 
       Tests for equality of subrings.  The ambient rings of the subrings @TT "A"@ and @TT "B"@ should be the same.
   SeeAlso
     isSubalg 
///



doc ///
   Key
     PrintLevel
   Headline
     A verbose mode for the Sagbi algorithm.
   Description
     Text 
       There are three different levels supported for this option:
       
       @UL{
	   "0: default, print nothing.",
	   "1: Print information about the progress of the computation, but do not print any polynomials.",
	   "2: Print all information about the progress of the computation, including polynomials."
	   }@
   SeeAlso
     sagbi
     Autosubduce
     Limit
     PrintLevel 
///

doc ///
   Key
     toricSyz
     (toricSyz, Subring, Matrix)
   Headline
     Calculate toric syzygies of monomials in the initial algebra.
   Inputs
     subR:Subring
         generated by a sagbi basis.
     M:Matrix
     	 a @TT "1"@$\times$@TT "r"@ matrix of monomials in the initial algebra of subR.
   Outputs
     result:Matrix
         the syzygies of M in the rank-@TT "r"@ free module over the initial algebra.
   Usage 
     result = toricSyz(subR, M)
   Description
     Text
       This is an experimental implementation of algorithm 11.18 in Sturmfels' "Gröbner bases and Convex Polytopes."
     Example 
       R = QQ[t_1,t_2];
       A = subring sagbi{t_1^2,t_1*t_2,t_2^2};
       M = matrix{{t_1^2, t_1*t_2}};
       toricSyz(A, M)
     Text
       See @TO "Experimental feature: modules over subrings"@ for another example.
///

doc ///
   Key
     intrinsicReduce
     (intrinsicReduce, Subring, Matrix, RingElement)
     (intrinsicReduce, Subring, Matrix, Matrix)
   Headline
     Compute normal forms relative to an ideal within a subring.
   Inputs
     subR:Subring
         that is generated by a Sagbi basis and contains the ideal generated by the 1-row matrix G.
     G:Matrix
     	 A one-row matrix that generates an ideal of subR.
     p:RingElement
     	 An element of the tensor ring of subR.
     M:Matrix
     	 A one-row matrix containing elements of the tensor ring of subR.
   Outputs
     result:RingElement
     resultMat:Matrix
   Usage 
     result = toricSyz(subR, M, p)
     resultMat = toricSyz(subR, G, M)
   Description
     Text
       This is an implementation of algorithm 11.14 of B. Sturmfels, Groebner bases and Convex Polytopes, Univ. Lecture Series 8, Amer Math Soc, Providence, 1996.  This function should be considered experimental.

   SeeAlso
     extrinsicBuchberger
///

doc ///
   Key
     extrinsicBuchberger
     (extrinsicBuchberger, Subring, Matrix)
   Headline
     Computes a Gröbner basis of an ideal within a subring.
   Usage
     extrinsicBuchberger(M, gVars)
   Inputs
     M:Matrix
    	A 1-column matrix that is often the result of a call to moduleToSubringIdeal.
     gVars:Matrix 
        A 1-row matrix containing the variables that correspond to the generators of the module.
   Outputs
     result:Matrix
        
   Description
     Text
       This is an implementation of Algorithm 11.24 of "Gröbner Bases and Convex Polytopes" by Bernd Sturmfels.  This function works similar to the function @TO (groebnerBasis,Matrix)@, except that the "field of scalars" is a subring.
///

doc ///
   Key
     (symbol ^, Subring, ZZ)
   Headline
     Construct a product subring.
   Inputs
     subR:Subring
         the subring used to construct a product.
     n:ZZ
     	 the number of copies of the subring.
   Outputs
     result:Subring
   Usage 
     result = subR^n
   Description
     Text
       The resulting subring has  @TT "n"@ distinguished variables that correspond to module generators.
       
   SeeAlso
    "Experimental feature: modules over subrings"
///




doc ///
   Key
     (ambient, Subring)
   Headline
     Returns the ambient ring (ring containing the generators) of a subring.
   Inputs
     subR:Subring
   Outputs
     amb:PolynomialRing
       the ambient ring.
   Usage 
     amb = ambient subR 
   Description
     Example
       gndR = QQ[x,y,z];
       subR = subring({x^2, y^2, z^2});
       ambient subR
   SeeAlso
     (ring, Subring)
     (gens, Subring)
///

doc ///
   Key
     (gens, Subring)
   Headline
     Returns the generators of a subring as a one-row matrix.
   Inputs
     subR:Subring
   Outputs
     M:Matrix
       a one-row matrix containing the generators of subR.
   Usage 
     M = gens subR
   Description
     Example
       gndR = QQ[x,y,z];
       subR = subring({x^2, y^2, z^2});
       gens subR
   SeeAlso
     (ambient, Subring)
     (ring, Subring)
///
doc ///
   Key
     (numgens, Subring)
     (numgens, SAGBIBasis)
   Headline
     Returns the number of generators of a subring or sagbi generators of a SAGBIBasis.
   Inputs
     S:Subring
     SB:SAGBIBasis
   Outputs
     n:ZZ
       the number of generators of S or SB.
   Usage 
     n = numgens S
     n = numgens SB
   Description
     Example
       R = QQ[x,y,z];
       S = subring({x^2, y^2, z^2});
       numgens S
   SeeAlso
     (gens, Subring)
     (ambient, Subring)
     (ring, Subring)
///

doc ///
   Key
     debugPrintAllMaps
     (debugPrintAllMaps, Subring)
   Headline
     Prints the maps associated with a subring.
   Usage
     debugPrintAllMaps(subR)
   Inputs
     subR:Subring
   Outputs
   Description
     Text
       Prints a summary in human-readable format of the maps contained in the @TO "PresRing"@ of a @TO "Subring"@ instance.
     Example 
       R = QQ[t_1, t_2];
       subR = subring matrix(R, {{t_1^2, t_1*t_2, t_2^2}});
       debugPrintAllMaps(subR)
   SeeAlso
     (debugPrintAllMaps, Subring)
     (debugPrintGens, Subring)
     (debugPrintMap, RingMap)
     (debugPrintMat, Matrix)
///

doc ///
   Key
     debugPrintGens
     StrWidth
     (debugPrintGens, Subring)
     [debugPrintGens, StrWidth]
   Headline
     Print the generators of a subring.
   Usage
     debugPrintGens(subR)
   Inputs
     subR:Subring
     StrWidth=>ZZ
        the maximum width (in characters) to print.

   Outputs
   Description
     Text
       Prints the generators of a subring in a human readable-format.

       Polynomials whose @TO "net"@ representation is wider than @TO "StrWidth"@ characters truncated.
              
     Example 
       R = QQ[t_1, t_2];
       subR = subring matrix(R, {{t_1^2, t_1*t_2, t_2^2}});
       debugPrintGens(subR)
   SeeAlso
     (debugPrintAllMaps, Subring)
     (debugPrintGens, Subring)
     (debugPrintMap, RingMap)
     (debugPrintMat, Matrix)
///

doc ///
   Key
     debugPrintMap
     (debugPrintMap, RingMap)
   Headline
     Prints a RingMap in human-readable format.
   Usage
     debugPrintGens(f)
   Inputs
     f:RingMap
   Outputs
   Description
     Text
       Prints a single @TO "RingMap"@ in a human-readable format.
     Example 
       R = QQ[t_1, t_2];
       subR = subring matrix(R, {{t_1^2, t_1*t_2, t_2^2}});
       debugPrintMap(subR#"presentation"#"substitution")
   SeeAlso
     (debugPrintAllMaps, Subring)
     (debugPrintGens, Subring)
     (debugPrintMap, RingMap)
     (debugPrintMat, Matrix)
///

doc ///
   Key
     debugPrintMat
     (debugPrintMat, Matrix)
     [debugPrintMat, StrWidth]
   Headline
     Prints a one-row matrix
   Usage
     debugPrintMat(M)
   Inputs
     M:Matrix
       a one row-matrix.
     StrWidth=>ZZ
       the maximum width (in characters) to print.
   Outputs
   Description
     Text
       Given a one row matrix of polynomials, prints each entry in human-readable format.
       
       Polynomials whose @TO "net"@ representation is wider than @TO "StrWidth"@ characters truncated.

     Example 
       R = QQ[t_1, t_2];
       debugPrintMat(matrix {{t_1^2, t_1*t_2, t_2^2}})
   SeeAlso
     (debugPrintAllMaps, Subring)
     (debugPrintGens, Subring)
     (debugPrintMap, RingMap)
     (debugPrintMat, Matrix)
///

doc ///
   Key
     extractEntries
     (extractEntries, Matrix, Matrix)
   Headline
     Inverse of moduleToSubringIdeal
   Usage
     result = extractEntries(M, gVars)
   Inputs
     M:Matrix
    	a 1-column matrix of elements of a subring ideal
     gVars:Matrix 
        a 1-row matrix containing the variables that correspond to the generators of the module.
   Outputs
     result:Matrix
        
   Description
     Text
       Converts elements of a subring ideal (represented by a one-column matrix and usually generated by @TO "moduleToSubringIdeal"@) to elements
       of a module (represented by a matrix).

       Internally, the argument gVars is sorted so that the order of the columns of the resulting
       matrix are consistent.
       
     Example 
       R = QQ[a, b, c, x_1, x_2, x_3];
       extractEntries(matrix {{a*x_1 + b*x_2 + c*x_3}}, matrix {{x_1, x_2, x_3}})
       extractEntries(matrix {{a*x_1 + b*x_2 + c*x_3},{a*x_1 + a*x_2 + a*x_3}}, matrix {{x_1, x_2, x_3}} )
   SeeAlso
     (moduleToSubringIdeal, Subring, Matrix)
///

doc ///
   Key
     subring
     (subring, List)
     (subring, Matrix)
     (subring, SAGBIBasis)
     --[subring, VarBaseName]
   Headline
     Constructs a subring of a polynomial ring.
   Usage
     A = subring M
     A = subring L
     A = subring S
   Inputs
     M:Matrix
       a one-row matrix whose entries are the generators for the constructed @TO "Subring"@.
     L:List 
       a list of generators for the constructed @TO "Subring"@.
     S:SAGBIBasis
     --VarBaseName=>String
       --determines the symbol used for the variables of the @TT "tensorRing"@ for the constructed @TO "Subring"@.
   Outputs
     A:Subring
   Description
     Text
       This function serves as the canonical constructor for the @TO "Subring"@ type.

       Generators that are constants are ignored because all subrings are assumed to contain the field of coefficients. An error is 
       thrown if the given set of generators does not contain at least one non-constant generator.  The generators of a subring need not be reduced.
     Example
       gndR = QQ[x];
       A = subring {x^4+x^3, x^2+x}
       subring sagbi A
       (x^3+x^2)%A

   SeeAlso
     Subring
///


doc ///
   Key
     (symbol //, RingElement, Subring)
     (symbol //, Matrix, Subring)
   Headline
     Write a ring element in terms of the generators.
   Usage 
     result = f//subR
   Inputs
     f:RingElement
     subR:Subring
       a subring whose generators form a Sagbi basis.
   Outputs
     result:RingElement
   Description
     Text 
        This function attempts to write @TT "f"@ in terms of the generators of @TT "subR"@.  Internally, this function calculates a Groebner basis.  This function should be considered experimental.
     Example
       gndR = QQ[x];
       A = subring sagbi subring {x^4+x^3, x^2+x}
       gens A
       f = x^3 + x^2
       g = f//A
       (A#"presentation"#"fullSubstitution")(g) == f
///

      
doc ///
   Key
     genVars
     (genVars,Subring)
   Headline
     tensor ring generators
   Usage
     result = genVars(subR)
   Inputs
     subR:Subring
   Outputs
     result:Matrix
   Description
     Text
        Returns the variables corresponding to the subalgebra generators in the tensor ring (which is part of the presentation) of a subring.
///

doc ///
   Key
     internalSubduction
     (internalSubduction,PresRing,Matrix)
     (internalSubduction,PresRing,RingElement)
     (symbol %, Matrix, Subring)
   Headline
     Performs subduction from a presentation ring
   Usage
     result = internalSubduction(presR,relem)
     result = internalSubduction(presR,M)
     resultMat = M % subR
   Inputs
     presR:PresRing
     relem:RingElement
     M:Matrix
        A matrix of ring elements to be subducted
     subR:Subring
   Outputs
     result:Matrix
   Description
     Text
        Performs subduction of the @TO "RingElement"@ or the entries of the @TO "Matrix"@ by the content of the @TO "PresRing"@.  This is typically an internal call for cases where the @TO "PresRing"@ is explicitly specified, and @TO "subduction"@, @TO "autosubduce"@, @TO "autoreduce"@ are more appropriate for the user.  The behavior of @TT "%"@ may change in future releases.
   SeeAlso
     subduction
     autosubduce
     autoreduce
///

doc ///
   Key
     sagbiDone
     (sagbiDone,SAGBIBasis)
   Headline
     Test if sagbi basis computation is complete
   Usage
     result = sagbiDone(S)
   Inputs
     S:SAGBIBasis
   Outputs
     result:Matrix
   Description
     Text
        Returns true if the sagbi basis computation has completed.
///

doc ///
   Key
     (ring,Subring)
   Headline
     Returns tensor ring
   Usage
     result = ring subR
   Inputs
     subR:Subring
   Outputs
     result:Ring
   Description
     Text
        Returns the tensor ring of the subring (which is part of the presentation of the subring).
///
