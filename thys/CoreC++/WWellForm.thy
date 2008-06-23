(*  Title:       CoreC++
    ID:          $Id: WWellForm.thy,v 1.7 2008-06-23 21:24:36 makarius Exp $
    Author:      Tobias Nipkow
    Maintainer:  Daniel Wasserrab <wasserra at fmi.uni-passau.de>
*)


header {* \isaheader{Weak well-formedness of CoreC++ programs} *}

theory WWellForm imports WellForm Expr begin


constdefs
  wwf_mdecl :: "prog \<Rightarrow> cname \<Rightarrow> mdecl \<Rightarrow> bool"
  "wwf_mdecl P C  \<equiv>  \<lambda>(M,Ts,T,(pns,body)).
  length Ts = length pns \<and> distinct pns \<and> this \<notin> set pns \<and> fv body \<subseteq> {this} \<union> set pns"

lemma wwf_mdecl[simp]:
  "wwf_mdecl P C (M,Ts,T,pns,body) =
  (length Ts = length pns \<and> distinct pns \<and> this \<notin> set pns \<and> fv body \<subseteq> {this} \<union> set pns)"
by(simp add:wwf_mdecl_def)


abbreviation
  wwf_prog :: "prog \<Rightarrow> bool" where
  "wwf_prog == wf_prog wwf_mdecl"

end
