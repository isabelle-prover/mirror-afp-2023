theory Hidden
imports "List-Index.List_Index" 
begin

definition hidden :: "'a list \<Rightarrow> nat \<Rightarrow> bool" where
"hidden xs i  \<equiv>  i < size xs \<and> xs!i \<in> set(drop (i+1) xs)"


lemma hidden_last_index: "x \<in> set xs \<Longrightarrow> hidden (xs @ [x]) (last_index xs x)"
by(auto simp add: hidden_def nth_append rev_nth[symmetric]
        dest: last_index_less[OF _ le_refl])

lemma hidden_inacc: "hidden xs i \<Longrightarrow> last_index xs x \<noteq> i"
by(auto simp add: hidden_def last_index_drop last_index_less_size_conv)


lemma [simp]: "hidden xs i \<Longrightarrow> hidden (xs@[x]) i"
by(auto simp add:hidden_def nth_append)


lemma fun_upds_apply:
 "(m(xs[\<mapsto>]ys)) x =
  (let xs' = take (size ys) xs
   in if x \<in> set xs' then Some(ys ! last_index xs' x) else m x)"
proof(induct xs arbitrary: m ys)
  case Nil then show ?case by(simp add: Let_def)
next
  case Cons show ?case 
  proof(cases ys)
    case Nil
    then show ?thesis by(simp add:Let_def)
  next
    case Cons': Cons
    then show ?thesis using Cons by(simp add: Let_def last_index_Cons)
  qed
qed


lemma map_upds_apply_eq_Some:
  "((m(xs[\<mapsto>]ys)) x = Some y) =
  (let xs' = take (size ys) xs
   in if x \<in> set xs' then ys ! last_index xs' x = y else m x = Some y)"
by(simp add:fun_upds_apply Let_def)


lemma map_upds_upd_conv_last_index:
  "\<lbrakk>x \<in> set xs; size xs \<le> size ys \<rbrakk>
  \<Longrightarrow> m(xs[\<mapsto>]ys, x\<mapsto>y) = m(xs[\<mapsto>]ys[last_index xs x := y])"
by(rule ext) (simp add:fun_upds_apply eq_sym_conv Let_def)

end
