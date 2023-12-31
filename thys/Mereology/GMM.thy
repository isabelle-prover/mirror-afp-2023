section \<open> General Minimal Mereology \<close>

(*<*)
theory GMM
 imports GM MM
begin
(*>*)

text \<open> The theory of \emph{general minimal mereology} adds general mereology to minimal mereology.\footnote{
See \<^cite>\<open>"casati_parts_1999"\<close> p. 46.} \<close>

locale GMM = GM + MM
begin

text \<open> It is natural to assume that just as closed minimal mereology and closed extensional mereology
are the same theory, so are general minimal mereology and general extensional mereology.\footnote{For
this mistake see \<^cite>\<open>"simons_parts:_1987"\<close> p. 37 and \<^cite>\<open>"casati_parts_1999"\<close> p. 46. The mistake
is corrected in \<^cite>\<open>"pontow_note_2004"\<close> and \<^cite>\<open>"hovda_what_2009"\<close>. For discussion of the significance
of this issue see, for example, \<^cite>\<open>"varzi_universalism_2009"\<close> and \<^cite>\<open>"cotnoir_does_2016"\<close>.}
But this is not the case, since the proof of strong supplementation in closed minimal mereology
required the product closure axiom. However, in general minimal mereology, the fusion axiom does not 
entail the product closure axiom. So neither product closure nor strong supplementation are theorems. \<close>

lemma product_closure: 
  "O x y \<Longrightarrow> (\<exists> z. \<forall> v. P v z \<longleftrightarrow> P v x \<and> P v y)" 
  nitpick [expect = genuine] oops

lemma strong_supplementation: "\<not> P x y \<Longrightarrow> (\<exists> z. P z x \<and> \<not> O z y)"
  nitpick [expect = genuine] oops

end

(*<*) end (*>*)