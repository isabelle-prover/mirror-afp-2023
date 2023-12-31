section \<open> Minimal Mereology \<close>

(*<*)
theory MM
  imports M
begin
(*>*)

text \<open> Minimal mereology adds to ground mereology the axiom of weak supplementation.\footnote{
See \<^cite>\<open>"varzi_parts_1996"\<close> and \<^cite>\<open>"casati_parts_1999"\<close> p. 39. The name \emph{minimal mereology}
reflects the, controversial, idea that weak supplementation is analytic. See, for example, \<^cite>\<open>"simons_parts:_1987"\<close>
p. 116, \<^cite>\<open>"varzi_extensionality_2008"\<close> p. 110-1, and \<^cite>\<open>"cotnoir_is_2018"\<close>. For general
discussion of weak supplementation see, for example \<^cite>\<open>"smith_mereology_2009"\<close> pp. 507 and 
\<^cite>\<open>"donnelly_using_2011"\<close>.} \<close>

locale MM = M +
  assumes weak_supplementation: "PP y x \<Longrightarrow> (\<exists> z. P z x \<and> \<not> O z y)"

text \<open> The rest of this section considers three alternative axiomatizations of minimal mereology. The
first alternative axiomatization replaces improper with proper parthood in the consequent of weak
supplementation.\footnote{See \<^cite>\<open>"simons_parts:_1987"\<close> p. 28.} \<close>

locale MM1 = M +
  assumes proper_weak_supplementation: 
    "PP y x \<Longrightarrow> (\<exists> z. PP z x \<and> \<not> O z y)"

sublocale MM \<subseteq> MM1
proof
  fix x y
  show "PP y x \<Longrightarrow> (\<exists> z. PP z x \<and> \<not> O z y)"
  proof -
    assume "PP y x"
    hence "\<exists> z. P z x \<and> \<not> O z y" by (rule weak_supplementation)
    then obtain z where z: "P z x \<and> \<not> O z y"..
    hence "\<not> O z y"..
    from z have "P z x"..                                       
    hence "P z x \<and> z \<noteq> x"
    proof
      show "z \<noteq> x"
      proof
        assume "z = x"
        hence "PP y z"
          using \<open>PP y x\<close> by (rule ssubst)
        hence "O y z" by (rule proper_implies_overlap)
        hence "O z y" by (rule overlap_symmetry)
        with \<open>\<not> O z y\<close> show "False"..
      qed
    qed
    with nip_eq have "PP z x"..
    hence "PP z x \<and> \<not> O z y"
      using \<open>\<not> O z y\<close>..
    thus "\<exists> z. PP z x \<and> \<not> O z y"..
  qed
qed

sublocale MM1 \<subseteq> MM
proof
  fix x y
  show weak_supplementation: "PP y x \<Longrightarrow> (\<exists> z. P z x \<and> \<not> O z y)"
  proof -
    assume "PP y x"
    hence "\<exists> z. PP z x \<and> \<not> O z y" by (rule proper_weak_supplementation)
    then obtain z where z: "PP z x \<and> \<not> O z y"..
    hence "PP z x"..
    hence "P z x" by (rule proper_implies_part)
    moreover from z have "\<not> O z y"..
    ultimately have "P z x \<and> \<not> O z y"..
    thus "\<exists> z. P z x \<and> \<not> O z y"..
  qed
qed

text \<open> The following two corollaries are sometimes found in the literature.\footnote{See \<^cite>\<open>"simons_parts:_1987"\<close> p. 27. For the names \emph{weak company} 
and \emph{strong company} see \<^cite>\<open>"cotnoir_non-wellfounded_2012"\<close> p. 192-3 and \<^cite>\<open>"varzi_mereology_2016"\<close>.} \<close>

context MM
begin

corollary weak_company: "PP y x \<Longrightarrow> (\<exists> z. PP z x \<and> z \<noteq> y)"
proof -
  assume "PP y x"
  hence "\<exists> z. PP z x \<and> \<not> O z y" by (rule proper_weak_supplementation)
  then obtain z where z: "PP z x \<and> \<not> O z y"..
  hence "PP z x"..
  from z have "\<not> O z y"..
  hence "z \<noteq> y" by (rule disjoint_implies_distinct)
  with \<open>PP z x\<close> have "PP z x \<and> z \<noteq> y"..
  thus "\<exists> z. PP z x \<and> z \<noteq> y"..
qed

corollary strong_company: "PP y x \<Longrightarrow> (\<exists> z. PP z x \<and> \<not> P z y)"
proof -
  assume "PP y x"
  hence "\<exists>z. PP z x \<and> \<not> O z y" by (rule proper_weak_supplementation)
  then obtain z where z: "PP z x \<and> \<not> O z y"..
  hence "PP z x"..
  from z have "\<not> O z y"..
  hence "\<not> P z y" by (rule disjoint_implies_not_part)
  with \<open>PP z x\<close> have  "PP z x \<and> \<not> P z y"..
  thus "\<exists> z. PP z x \<and> \<not> P z y"..
qed

end

text \<open> If weak supplementation is formulated in terms of nonidentical parthood, then the antisymmetry 
of parthood is redundant, and we have the second alternative axiomatization of minimal mereology.\footnote{
See \<^cite>\<open>"cotnoir_antisymmetry_2010"\<close> p. 399, \<^cite>\<open>"donnelly_using_2011"\<close> p. 232,
\<^cite>\<open>"cotnoir_non-wellfounded_2012"\<close> p. 193 and \<^cite>\<open>"obojska_remarks_2013"\<close> pp. 235-6.} \<close>

locale MM2 = PM +
  assumes nip_eq: "PP x y \<longleftrightarrow> P x y \<and> x \<noteq> y"
  assumes weak_supplementation: "PP y x \<Longrightarrow> (\<exists> z. P z x \<and> \<not> O z y)"

sublocale MM2 \<subseteq> MM
proof
  fix x y
  show "PP x y \<longleftrightarrow> P x y \<and> x \<noteq> y" using nip_eq.
  show part_antisymmetry: "P x y \<Longrightarrow> P y x \<Longrightarrow> x = y"
  proof - 
    assume "P x y"
    assume "P y x"
    show "x = y"
    proof (rule ccontr)
      assume "x \<noteq> y"
      with \<open>P x y\<close> have "P x y \<and> x \<noteq> y"..
      with nip_eq have "PP x y"..
      hence "\<exists> z. P z y \<and> \<not> O z x" by (rule weak_supplementation)
      then obtain z where z: "P z y \<and> \<not> O z x"..
      hence "\<not> O z x"..
      hence "\<not> P z x" by (rule disjoint_implies_not_part)
      from z have "P z y"..
      hence "P z x" using \<open>P y x\<close> by (rule part_transitivity)
      with \<open>\<not> P z x\<close> show "False"..
    qed
  qed
  show "PP y x \<Longrightarrow> \<exists>z. P z x \<and> \<not> O z y" using weak_supplementation.
qed

sublocale MM \<subseteq> MM2
proof
  fix x y
  show "PP x y \<longleftrightarrow> (P x y \<and> x \<noteq> y)" using nip_eq.
  show "PP y x \<Longrightarrow> \<exists>z. P z x \<and> \<not> O z y" using weak_supplementation.
qed

text \<open> Likewise, if proper parthood is adopted as primitive, then the asymmetry of proper parthood
is redundant in the context of weak supplementation, leading to the third alternative
axiomatization.\footnote{See \<^cite>\<open>"donnelly_using_2011"\<close> p. 232 and \<^cite>\<open>"cotnoir_is_2018"\<close>.} \<close>

locale MM3 =
  assumes part_eq: "P x y \<longleftrightarrow> PP x y \<or> x = y"
  assumes overlap_eq: "O x y \<longleftrightarrow> (\<exists> z. P z x \<and> P z y)"
  assumes proper_part_transitivity: "PP x y \<Longrightarrow> PP y z \<Longrightarrow> PP x z"
  assumes weak_supplementation: "PP y x \<Longrightarrow> (\<exists> z. P z x \<and> \<not> O z y)"
begin

lemma part_reflexivity: "P x x"
proof -
  have "x = x"..
  hence "PP x x \<or> x = x"..
  with part_eq show "P x x"..
qed

lemma proper_part_irreflexivity: "\<not> PP x x"
proof
  assume "PP x x"
  hence "\<exists> z. P z x \<and> \<not> O z x" by (rule weak_supplementation)
  then obtain z where z: "P z x \<and> \<not> O z x"..
  hence "\<not> O z x"..
  from z have "P z x"..
  with part_reflexivity have "P z z \<and> P z x"..
  hence "\<exists> v. P v z \<and> P v x"..
  with overlap_eq have "O z x"..
  with \<open>\<not> O z x\<close> show "False"..
qed

end

sublocale MM3 \<subseteq> M4
proof
  fix x y z
  show "P x y \<longleftrightarrow> PP x y \<or> x = y" using part_eq.
  show "O x y \<longleftrightarrow> (\<exists> z. P z x \<and> P z y)" using overlap_eq.
  show proper_part_irreflexivity: "PP x y \<Longrightarrow> \<not> PP y x"
  proof -
    assume "PP x y"
    show "\<not> PP y x"
    proof
      assume "PP y x"
      hence "PP y y" using \<open>PP x y\<close> by (rule proper_part_transitivity)
      with proper_part_irreflexivity show "False"..
    qed
  qed
  show "PP x y \<Longrightarrow> PP y z \<Longrightarrow> PP x z" using proper_part_transitivity.
qed

sublocale MM3 \<subseteq> MM
proof
  fix x y
  show "PP y x \<Longrightarrow> (\<exists> z. P z x \<and> \<not> O z y)" using weak_supplementation.
qed

sublocale MM \<subseteq> MM3
proof
  fix x y z
  show "P x y \<longleftrightarrow> (PP x y \<or> x = y)" using part_eq.
  show "O x y \<longleftrightarrow> (\<exists>z. P z x \<and> P z y)" using overlap_eq.
  show "PP x y \<Longrightarrow> PP y z \<Longrightarrow> PP x z" using proper_part_transitivity.
  show "PP y x \<Longrightarrow> \<exists>z. P z x \<and> \<not> O z y" using weak_supplementation.
qed

(*<*) end (*>*)