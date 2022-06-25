section "Derivatives of Extended Regular Expressions"

(* Author: Christian Urban *)

theory Derivatives3
imports Regular_Exps3
begin

text\<open>This theory is based on work by Brozowski \cite{Brzozowski64}.\<close>

subsection \<open>Brzozowski's derivatives of regular expressions\<close>

fun
  deriv :: "'a \<Rightarrow> 'a rexp \<Rightarrow> 'a rexp"
where
  "deriv c (Zero) = Zero"
| "deriv c (One) = Zero"
| "deriv c (Atom c') = (if c = c' then One else Zero)"
| "deriv c (Plus r1 r2) = Plus (deriv c r1) (deriv c r2)"
| "deriv c (Times r1 r2) = 
    (if nullable r1 then Plus (Times (deriv c r1) r2) (deriv c r2) else Times (deriv c r1) r2)"
| "deriv c (Star r) = Times (deriv c r) (Star r)"
| "deriv c (NTimes r n) = (if n = 0 then Zero else Times (deriv c r) (NTimes r (n-1)))"

fun 
  derivs :: "'a list \<Rightarrow> 'a rexp \<Rightarrow> 'a rexp"
where
  "derivs [] r = r"
| "derivs (c # s) r = derivs s (deriv c r)"


lemma atoms_deriv_subset: "atoms (deriv x r) \<subseteq> atoms r"
by (induction r) (auto)

lemma atoms_derivs_subset: "atoms (derivs w r) \<subseteq> atoms r"
by (induction w arbitrary: r) (auto dest: atoms_deriv_subset[THEN subsetD])



lemma deriv_pow [simp]:
  shows "Deriv c (A ^^ n) = (if n = 0 then {} else (Deriv c A) @@ (A ^^ (n - 1)))"
  apply(induct n arbitrary: A)
  apply(auto)
  by (metis Suc_pred concI_if_Nil2 conc_assoc conc_pow_comm lang_pow.simps(2))

lemma lang_deriv: "lang (deriv c r) = Deriv c (lang r)"
  by (induct r) (simp_all add: nullable_iff)
  

lemma lang_derivs: "lang (derivs s r) = Derivs s (lang r)"
by (induct s arbitrary: r) (simp_all add: lang_deriv)

text \<open>A regular expression matcher:\<close>

definition matcher :: "'a rexp \<Rightarrow> 'a list \<Rightarrow> bool" where
"matcher r s = nullable (derivs s r)"

lemma matcher_correctness: "matcher r s \<longleftrightarrow> s \<in> lang r"
by (induct s arbitrary: r)
   (simp_all add: nullable_iff lang_deriv matcher_def Deriv_def)

end
