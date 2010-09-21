header {* Cancelation of words of generators and their inverses *}

theory Cancelation
imports
   "~~/src/HOL/Proofs/Lambda/Commutation"
begin

text {*
This theory defines cancelation via relations. The one-step relation @{term
"cancels_to_1 a b"} describes that @{term b} is obtained from @{term a} by removing
exactly one pair of generators, while @{term cancels_to} is the reflexive
transitive hull of that relation. Due to confluence, this relation has a normal
form, allowing for the definition of @{term normalize}.
*}

subsection {* Auxillary results *}

text {* Some lemmas that would be useful in a more general setting are
collected beforehand. *}

subsubsection {* Auxillary results about relations *}

text {*
These were helpfully provided by Andreas Lochbihler.
*}

theorem lconfluent_confluent:
  "\<lbrakk> wfP (R^--1); \<And>a b c. R a b \<Longrightarrow> R a c \<Longrightarrow> \<exists>d. R^** b d \<and> R^** c d  \<rbrakk> \<Longrightarrow> confluent R"
by(auto simp add: diamond_def commute_def square_def intro: newman)

lemma confluentD:
  "\<lbrakk> confluent R; R^** a b; R^** a c  \<rbrakk> \<Longrightarrow> \<exists>d. R^** b d \<and> R^** c d"
by(auto simp add: commute_def diamond_def square_def)

lemma tranclp_DomainP: "R^++ a b \<Longrightarrow> DomainP R a"
by(auto elim: converse_tranclpE)

lemma confluent_unique_normal_form:
  "\<lbrakk> confluent R; R^** a b; R^** a c; \<not> DomainP R b; \<not> DomainP R c  \<rbrakk> \<Longrightarrow> b = c"
by(fastsimp dest!: confluentD[of R a b c] dest: tranclp_DomainP rtranclpD[where a=b] rtranclpD[where a=c])

subsection {* Definition of the @{term "canceling"} relation *}

types 'a "g_i" = "(bool \<times> 'a)" (* A generator or its inverse *)
types 'a "word_g_i" = "'a g_i list" (* A word in the generators or their inverses *)

text {*
These type aliases encode the notion of a ``generator or its inverse''
(@{typ "'a g_i"}) and the notion of a ``word in generators and their inverses''
(@{typ "'a word_g_i"}), which form the building blocks of Free Groups.
*}

definition canceling :: "'a g_i \<Rightarrow> 'a g_i \<Rightarrow> bool"
 where "canceling a b = ((snd a = snd b) \<and> (fst a \<noteq> fst b))"

subsubsection {* Simple results about canceling *}

text {*
A generators cancels with its inverse, either way. The relation is symmetic.
*}

lemma cancel_cancel: "\<lbrakk> canceling a b; canceling b c \<rbrakk> \<Longrightarrow> a = c"
by (auto intro: prod_eqI simp add:canceling_def)

lemma cancel_sym: "canceling a b \<Longrightarrow> canceling b a"
by (simp add:canceling_def)

lemma cancel_sym_neg: "\<not>canceling a b \<Longrightarrow> \<not>canceling b a"
by (rule classical, simp add:canceling_def)

subsection {* Definition of the @{term "cancels_to"} relation *}

text {*
First, we define the function that removes the @{term i}th and @{text "(i+1)"}st
element from a word of generators, together with basic properties.
*}

definition cancel_at :: "nat \<Rightarrow> 'a word_g_i \<Rightarrow> 'a word_g_i"
where "cancel_at i l = take i l @ drop (2+i) l"

lemma cancel_at_length[simp]:
  "1+i < length l \<Longrightarrow> length (cancel_at i l) = length l - 2"
by(auto simp add: cancel_at_def)

lemma cancel_at_nth1[simp]:
  "\<lbrakk> n < i; 1+i < length l  \<rbrakk> \<Longrightarrow> (cancel_at i l) ! n = l ! n"
by(auto simp add: cancel_at_def nth_append)

lemma cancel_at_nth2[simp]:
  assumes "n \<ge> i" and "n < length l - 2"
  shows "(cancel_at i l) ! n = l ! (n + 2)"
proof-
  from `n \<ge> i` and `n < length l - 2`
  have "i = min (length l) i"
    by auto
  with `n \<ge> i` and `n < length l - 2`
  show "(cancel_at i l) ! n = l ! (n + 2)" 
    by(auto simp add: cancel_at_def nth_append nth_via_drop)
qed

text {*
Then we can define the relation @{term "cancels_to_1_at i a b"} which specifies
that @{term b} can be obtained by @{term a} by canceling the @{term i}th and
@{text "(i+1)"}st position.

Based on that, we existentially quantify over the position @{text i} to obtain
the relation @{text "cancels_to_1"}, of which @{text "cancels_to"} is the
reflexive and transitive closure.

A word is @{text "canceled"} if it can not be canceled any futher.
*}

definition cancels_to_1_at ::  "nat \<Rightarrow> 'a word_g_i \<Rightarrow> 'a word_g_i \<Rightarrow> bool"
where  "cancels_to_1_at i l1 l2 = (0\<le>i \<and> (1+i) < length l1
                              \<and> canceling (l1 ! i) (l1 ! (1+i))
                              \<and> (l2 = cancel_at i l1))"

definition cancels_to_1 :: "'a word_g_i \<Rightarrow> 'a word_g_i \<Rightarrow> bool"
where "cancels_to_1 l1 l2 = (\<exists>i. cancels_to_1_at i l1 l2)"

definition cancels_to  :: "'a word_g_i \<Rightarrow> 'a word_g_i \<Rightarrow> bool"
where "cancels_to = cancels_to_1^**"

lemma cancels_to_trans [trans]:
  "\<lbrakk> cancels_to a b; cancels_to b c \<rbrakk> \<Longrightarrow> cancels_to a c"
by (auto simp add:cancels_to_def)

definition canceled :: "'a word_g_i \<Rightarrow> bool"
 where "canceled l = (\<not> DomainP cancels_to_1 l)"

(* Alternative view on cancelation, sometimes easier to work with *)
lemma cancels_to_1_unfold:
  assumes "cancels_to_1 x y"
  obtains xs1 x1 x2 xs2
  where "x = xs1 @ x1 # x2 # xs2"
    and "y = xs1 @ xs2"
    and "canceling x1 x2"
proof-
  assume a: "(\<And>xs1 x1 x2 xs2. \<lbrakk>x = xs1 @ x1 # x2 # xs2; y = xs1 @ xs2; canceling x1 x2\<rbrakk> \<Longrightarrow> thesis)"
  from `cancels_to_1 x y`
  obtain i where "cancels_to_1_at i x y"
    unfolding cancels_to_1_def by auto
  hence "canceling (x ! i) (x ! Suc i)"
    and "y = (take i x) @ (drop (Suc (Suc i)) x)"
    and "x = (take i x) @ x ! i # x ! Suc i # (drop (Suc (Suc i)) x)"
    unfolding cancel_at_def and cancels_to_1_at_def by (auto simp add: drop_Suc_conv_tl)
  with a show thesis by blast
qed

(* And the reverse direction *)
lemma cancels_to_1_fold:
  "canceling x1 x2 \<Longrightarrow> cancels_to_1 (xs1 @ x1 # x2 # xs2) (xs1 @ xs2)"
unfolding cancels_to_1_def and cancels_to_1_at_def and cancel_at_def
by (rule_tac x="length xs1" in exI, auto simp add:nth_append)

subsubsection {* Existence of the normal form *}

text {*
One of two steps to show that we have a normal form is the following lemma,
guaranteeing that by canceling, we always end up at a fully canceled word.
*}

lemma canceling_terminates: "wfP (cancels_to_1^--1)"
proof-
  have "wf (measure length)" by auto
  moreover
  have "{(x, y). cancels_to_1 y x} \<subseteq> measure length"
    by (auto simp add: cancels_to_1_def cancel_at_def cancels_to_1_at_def)
  ultimately
  have "wf {(x, y). cancels_to_1 y x}"
    by(rule wf_subset)
  thus ?thesis by (simp add:wfP_def)
qed

text {*
The next two lemmas prepare for the proof of confluence. It does not matter in
which order we cancel, we can obtain the same result.
*}

lemma canceling_neighbor:
  assumes "cancels_to_1_at i l a" and "cancels_to_1_at (Suc i) l b"
  shows "a = b"
proof-
  from `cancels_to_1_at i l a`
    have "canceling (l ! i) (l ! Suc i)" and "i < length l"
    by (auto simp add: cancels_to_1_at_def)
  
  from `cancels_to_1_at (Suc i) l b`
    have "canceling (l ! Suc i) (l ! Suc (Suc i))" and "Suc (Suc i) < length l"
    by (auto simp add: cancels_to_1_at_def)

  from `canceling (l ! i) (l ! Suc i)` and `canceling (l ! Suc i) (l ! Suc (Suc i))`
    have "l ! i = l ! Suc (Suc i)" by (rule cancel_cancel)

  from `cancels_to_1_at (Suc i) l b`
    have "b = take (Suc i) l @ drop (Suc (Suc (Suc i))) l"
    by (simp add: cancels_to_1_at_def cancel_at_def)
  also from `i < length l`
  have "\<dots> = take i l @ [l ! i] @ drop (Suc (Suc (Suc i))) l"
    by(auto simp add: take_Suc_conv_app_nth)
  also from `l ! i = l ! Suc (Suc i)`
  have "\<dots> = take i l @ [l ! Suc (Suc i)] @ drop (Suc (Suc (Suc i))) l"
    by simp
  also from `Suc (Suc i) < length l`
  have "\<dots> = take i l @ drop (Suc (Suc i)) l"
    by (simp add: drop_Suc_conv_tl)
  also from `cancels_to_1_at i l a` have "\<dots> = a"
    by (simp add: cancels_to_1_at_def cancel_at_def)
  finally show "a = b" by(rule sym)
qed

lemma canceling_indep:
  assumes "cancels_to_1_at i l a" and "cancels_to_1_at j l b" and "j > Suc i"
  obtains c where "cancels_to_1_at (j - 2) a c" and "cancels_to_1_at i b c"
proof(atomize_elim)
  from `cancels_to_1_at i l a`
    have "Suc i < length l"
     and "canceling (l ! i) (l ! Suc i)"
     and "a = cancel_at i l"
     and "length a = length l - 2"
     and "min (length l) i = i"
    by (auto simp add:cancels_to_1_at_def)
  from `cancels_to_1_at j l b`
    have "Suc j < length l"
     and "canceling (l ! j) (l ! Suc j)"
     and "b = cancel_at j l"
     and "length b = length l - 2"
    by (auto simp add:cancels_to_1_at_def)

  let ?c = "cancel_at (j - 2) a"
  from `j > Suc i`
  have "Suc (Suc (j - 2)) = j"
    and "Suc (Suc (Suc j - 2)) = Suc j"
    by auto
  with `min (length l) i = i` and `j > Suc i` and `Suc j < length l`
  have "(l ! j) = (cancel_at i l ! (j - 2))"
    and "(l ! (Suc j)) = (cancel_at i l ! Suc (j - 2))"
    by(auto simp add:cancel_at_def simp add:nth_append)
  
  with `cancels_to_1_at i l a`
    and `cancels_to_1_at j l b`
  have "canceling (a ! (j - 2)) (a ! Suc (j - 2))"
    by(auto simp add:cancels_to_1_at_def)
  
  with `j > Suc i` and `Suc j < length l` and `length a = length l - 2`
  have "cancels_to_1_at (j - 2) a ?c" by (auto simp add: cancels_to_1_at_def)

  from `length b = length l - 2` and `j > Suc i` and `Suc j < length l`
  have "Suc i < length b" by auto
  
  moreover from `b = cancel_at j l` and `j > Suc i` and `Suc i < length l`
  have "(b ! i) = (l ! i)" and "(b ! Suc i) = (l ! Suc i)"
    by (auto simp add:cancel_at_def nth_append)
  with `canceling (l ! i) (l ! Suc i)`
  have "canceling (b ! i) (b ! Suc i)" by simp
  
  moreover from `j > Suc i` and `Suc j < length l`
  have "min i j = i"
    and "min (j - 2) i = i"
    and "min (length l) j = j"
    and "min (length l) i = i"
    and "Suc (Suc (j - 2)) = j"
    by auto
  with `a = cancel_at i l` and `b = cancel_at j l` and `Suc (Suc (j - 2)) = j`
  have "cancel_at (j - 2) a = cancel_at i b"
    by (auto simp add:cancel_at_def take_drop)
  
  ultimately have "cancels_to_1_at i b (cancel_at (j - 2) a)"
    by (auto simp add:cancels_to_1_at_def)

  with `cancels_to_1_at (j - 2) a ?c`
  show "\<exists>c. cancels_to_1_at (j - 2) a c \<and> cancels_to_1_at i b c" by blast
qed

text {* This is the confluence lemma *}
lemma confluent_cancels_to_1: "confluent cancels_to_1"
proof(rule lconfluent_confluent)
  show "wfP cancels_to_1\<inverse>\<inverse>" by (rule canceling_terminates)
next
  fix a b c
  assume "cancels_to_1 a b"
  then obtain i where "cancels_to_1_at i a b"
    by(simp add: cancels_to_1_def)(erule exE)
  assume "cancels_to_1 a c"
  then obtain j where "cancels_to_1_at j a c"
    by(simp add: cancels_to_1_def)(erule exE)

  show "\<exists>d. cancels_to_1\<^sup>*\<^sup>* b d \<and> cancels_to_1\<^sup>*\<^sup>* c d"
  proof (cases "i=j")
    assume "i=j"
    from `cancels_to_1_at i a b`
      have "b = cancel_at i a" by (simp add:cancels_to_1_at_def)
    moreover from `i=j`
      have "\<dots> = cancel_at j a" by (clarify)
    moreover from `cancels_to_1_at j a c`
      have "\<dots> = c" by (simp add:cancels_to_1_at_def)
    ultimately have "b = c" by (simp)
    hence "cancels_to_1\<^sup>*\<^sup>* b b"
      and "cancels_to_1\<^sup>*\<^sup>* c b" by auto
    thus "\<exists>d. cancels_to_1\<^sup>*\<^sup>* b d \<and> cancels_to_1\<^sup>*\<^sup>* c d" by blast
  next 
    assume "i \<noteq> j"
    show ?thesis
    proof (cases "j = Suc i")
      assume "j = Suc i"
        with `cancels_to_1_at i a b` and `cancels_to_1_at j a c`
        have "b = c" by (auto elim: canceling_neighbor)
      hence "cancels_to_1\<^sup>*\<^sup>* b b"
        and "cancels_to_1\<^sup>*\<^sup>* c b" by auto
      thus "\<exists>d. cancels_to_1\<^sup>*\<^sup>* b d \<and> cancels_to_1\<^sup>*\<^sup>* c d" by blast
    next
      assume "j \<noteq> Suc i"
      show ?thesis
      proof (cases "i = Suc j")
        assume "i = Suc j"
          with `cancels_to_1_at i a b` and `cancels_to_1_at j a c`
          have "c = b" by (auto elim: canceling_neighbor)
        hence "cancels_to_1\<^sup>*\<^sup>* b b"
          and "cancels_to_1\<^sup>*\<^sup>* c b" by auto
        thus "\<exists>d. cancels_to_1\<^sup>*\<^sup>* b d \<and> cancels_to_1\<^sup>*\<^sup>* c d" by blast
      next
        assume "i \<noteq> Suc j"
        show ?thesis
        proof (cases "i < j")
          assume "i < j"
            with `j \<noteq> Suc i` have "Suc i < j" by auto
          with `cancels_to_1_at i a b` and `cancels_to_1_at j a c`
          obtain d where "cancels_to_1_at (j - 2) b d" and "cancels_to_1_at i c d"
            by(erule canceling_indep)
          hence "cancels_to_1 b d" and "cancels_to_1 c d" 
            by (auto simp add:cancels_to_1_def)
          thus "\<exists>d. cancels_to_1\<^sup>*\<^sup>* b d \<and> cancels_to_1\<^sup>*\<^sup>* c d" by (auto)
        next
          assume "\<not> i < j"
          with `j \<noteq> Suc i` and `i \<noteq> j` and `i \<noteq> Suc j` have "Suc j < i" by auto
          with `cancels_to_1_at i a b` and `cancels_to_1_at j a c`
          obtain d where "cancels_to_1_at (i - 2) c d" and "cancels_to_1_at j b d"
            by -(erule canceling_indep)
          hence "cancels_to_1 b d" and "cancels_to_1 c d" 
            by (auto simp add:cancels_to_1_def)
          thus "\<exists>d. cancels_to_1\<^sup>*\<^sup>* b d \<and> cancels_to_1\<^sup>*\<^sup>* c d" by (auto)
        qed
      qed
    qed
  qed
qed

text {*
And finally, we show that there exists a unique normal form for each word.
*}

(*
lemma inv_rtrcl: "R^**^--1 = R^--1^**" (* Did I overlook this in the standard libs? *)
by (auto simp add:fun_eq_iff intro: dest:rtranclp_converseD intro:rtranclp_converseI)
*)
lemma norm_form_uniq:
  assumes "cancels_to a b"
      and "cancels_to a c"
      and "canceled b"
      and "canceled c"
  shows "b = c"
proof-
  have "confluent cancels_to_1" by (rule confluent_cancels_to_1)
  moreover 
  from `cancels_to a b` have "cancels_to_1^** a b" by (simp add: cancels_to_def)
  moreover
  from `cancels_to a c` have "cancels_to_1^** a c" by (simp add: cancels_to_def)
  moreover
  from `canceled b` have "\<not> DomainP cancels_to_1 b" by (simp add: canceled_def)
  moreover
  from `canceled c` have "\<not> DomainP cancels_to_1 c" by (simp add: canceled_def)
  ultimately
  show "b = c"
    by (rule confluent_unique_normal_form)
qed

subsubsection {* Some properties of cancelation *}

text {*
Distributivity rules of cancelation and @{text append}.
*}

lemma cancel_to_1_append:
  assumes "cancels_to_1 a b"
  shows "cancels_to_1 (l@a@l') (l@b@l')"
proof-
  from `cancels_to_1 a b` obtain i where "cancels_to_1_at i a b"
    by(simp add: cancels_to_1_def)(erule exE)
  hence "cancels_to_1_at (length l + i) (l@a@l') (l@b@l')"
    by (auto simp add:cancels_to_1_at_def nth_append cancel_at_def)
  thus "cancels_to_1 (l@a@l') (l@b@l')"
    by (auto simp add: cancels_to_1_def)
qed

lemma cancel_to_append:
  assumes "cancels_to a b"
  shows "cancels_to (l@a@l') (l@b@l')"
using assms
unfolding cancels_to_def
proof(induct)
  case base show ?case by (simp add:cancels_to_def)
next
  case (step b c)
  from `cancels_to_1 b c`
  have "cancels_to_1 (l @ b @ l') (l @ c @ l')" by (rule cancel_to_1_append)
  with `cancels_to_1^** (l @ a @ l') (l @ b @ l')` show ?case
    by (auto simp add:cancels_to_def)
qed

lemma cancels_to_append2:
  assumes "cancels_to a a'"
      and "cancels_to b b'"
  shows "cancels_to (a@b) (a'@b')"
using `cancels_to a a'`
unfolding cancels_to_def
proof(induct)
  case base
  from `cancels_to b b'` have "cancels_to (a@b@[]) (a@b'@[])"
    by (rule cancel_to_append)
  thus ?case unfolding cancels_to_def by simp
next
  case (step ba c)
  from `cancels_to_1 ba c` have "cancels_to_1 ([]@ba@b') ([]@c@b')"
    by(rule cancel_to_1_append)
  with `cancels_to_1^** (a @ b) (ba @ b')`
  show ?case unfolding cancels_to_def by simp
qed

text {*
The empty list is canceled, a one letter word is canceled and a word is
trivially cancled from itself.
*}

lemma empty_canceled[simp]: "canceled []"
by(auto simp:add canceled_def cancels_to_1_def cancels_to_1_at_def)

lemma singleton_canceled[simp]: "canceled [a]"
by(auto simp:add canceled_def cancels_to_1_def cancels_to_1_at_def)

lemma cons_canceled:
  assumes "canceled (a#x)"
  shows   "canceled x"
proof(rule ccontr)
  assume "\<not> canceled x"
  hence "DomainP cancels_to_1 x" by (simp add:canceled_def)
  then obtain x' where "cancels_to_1 x x'" by auto
  then obtain xs1 x1 x2 xs2
    where x: "x = xs1 @ x1 # x2 # xs2"
    and   "canceling x1 x2" by (rule cancels_to_1_unfold)
  hence "cancels_to_1 ((a#xs1) @ x1 # x2 # xs2) ( (a#xs1) @ xs2)"
    by (auto intro:cancels_to_1_fold simp del:append_Cons)
  with x
  have "cancels_to_1 (a#x) (a#xs1 @ xs2)"
    by simp
  hence "\<not> canceled (a#x)" by (auto simp add:canceled_def)
  thus False using `canceled (a#x)` by contradiction
qed

lemma cancels_to_self[simp]: "cancels_to l l"
by (simp add:cancels_to_def)

subsection {* Definition of normalization *}

text {*
Using the THE construct, we can define the normalization function
@{text normalize} as the unique fully cancled word that the argument cancels
to.
*}

definition normalize :: "'a word_g_i \<Rightarrow> 'a word_g_i"
where "normalize l = (THE l'. cancels_to l l' \<and> canceled l')"

text {*
Some obvious properties of the normalize function, and other useful lemmas.
*}

lemma
  shows normalized_canceled[simp]: "canceled (normalize l)"
  and   normalized_cancels_to[simp]: "cancels_to l (normalize l)"
proof-
  let ?Q = "{l'. cancels_to_1^** l l'}"
  have "l \<in> ?Q" by (auto) hence "\<exists>x. x \<in> ?Q" by (rule exI)

  have "wfP cancels_to_1^--1"
    by (rule canceling_terminates)
  hence "\<forall>Q. (\<exists>x. x \<in> Q) \<longrightarrow> (\<exists>z\<in>Q. \<forall>y. cancels_to_1 z y \<longrightarrow> y \<notin> Q)"
    by (simp add:wfP_eq_minimal)
  hence "(\<exists>x. x \<in> ?Q) \<longrightarrow> (\<exists>z\<in>?Q. \<forall>y. cancels_to_1 z y \<longrightarrow> y \<notin> ?Q)"
    by (erule_tac x="?Q" in allE)
  then obtain l' where "l' \<in> ?Q" and minimal: "\<And>y. cancels_to_1 l' y \<Longrightarrow> y \<notin> ?Q"
    by auto
  
  from `l' \<in> ?Q` have "cancels_to l l'" by (auto simp add: cancels_to_def)

  have "canceled l'"
  proof(rule ccontr)
    assume "\<not> canceled l'" hence "DomainP cancels_to_1 l'" by (simp add: canceled_def)
    then obtain y where "cancels_to_1 l' y" by auto
    with `cancels_to l l'` have "cancels_to l y" by (auto simp add: cancels_to_def)
    from `cancels_to_1 l' y` have "y \<notin> ?Q" by(rule minimal)
    hence "\<not> cancels_to_1^** l y" by auto
    hence "\<not> cancels_to l y" by (simp add: cancels_to_def)
    with `cancels_to l y` show False by contradiction
  qed

  from `cancels_to l l'` and `canceled l'`
  have "cancels_to l l' \<and> canceled l'" by simp 
  hence "cancels_to l (normalize l) \<and> canceled (normalize l)"
    unfolding normalize_def
  proof (rule theI)
    fix l'a
    assume "cancels_to l l'a \<and> canceled l'a"
    thus "l'a = l'" using `cancels_to l l' \<and> canceled l'` by (auto elim:norm_form_uniq)
  qed
  thus "canceled (normalize l)" and "cancels_to l (normalize l)" by auto
qed

lemma normalize_discover:
  assumes "canceled l'"
      and "cancels_to l l'"
  shows "normalize l = l'"
proof-
  from `canceled l'` and `cancels_to l l'`
  have "cancels_to l l' \<and> canceled l'" by auto
  thus ?thesis unfolding normalize_def by (auto elim:norm_form_uniq)
qed

text {* Words, related by cancelation, have the same normal form. *}

lemma normalize_canceled[simp]:
  assumes "cancels_to l l'"
  shows   "normalize l = normalize l'"
proof(rule normalize_discover)
  show "canceled (normalize l')" by (rule normalized_canceled)
next
  have "cancels_to l' (normalize l')" by (rule normalized_cancels_to)
  with `cancels_to l l'`
  show "cancels_to l (normalize l')" by (rule cancels_to_trans)
qed

text {* Normalization is idempotent. *}

lemma normalize_idemp[simp]:
  assumes "canceled l"
  shows "normalize l = l"
using assms
by(rule normalize_discover)(rule cancels_to_self)

text {*
This lemma lifts the distributivity results from above to the normalize
function.
*}

lemma normalize_append_cancel_to:
  assumes "cancels_to l1 l1'"
  and     "cancels_to l2 l2'"
  shows "normalize (l1 @ l2) = normalize (l1' @ l2')"
proof(rule normalize_discover)
  show "canceled (normalize (l1' @ l2'))" by (rule normalized_canceled)
next
  from `cancels_to l1 l1'` and `cancels_to l2 l2'`
  have "cancels_to (l1 @ l2) (l1' @ l2')" by (rule cancels_to_append2)
  also
  have "cancels_to (l1' @ l2') (normalize (l1' @ l2'))" by (rule normalized_cancels_to)
  finally
  show "cancels_to (l1 @ l2) (normalize (l1' @ l2'))".
qed

subsection {* Normalization preserves generators *}

text {*
Somewhat obvious, but still required to formalize Free Groups, is the fact that
canceling a word of generators of a specific set (and their inverses) results
in a word in generators from that set.
*}

lemma cancels_to_1_preserves_generators:
  assumes "cancels_to_1 l l'"
      and "l \<in> lists (UNIV \<times> gens)"
  shows "l' \<in> lists (UNIV \<times> gens)"
proof-
  from assms obtain i where "l' = cancel_at i l" 
    unfolding cancels_to_1_def and cancels_to_1_at_def by auto
  hence "l' = take i l @ drop (2 + i) l" unfolding cancel_at_def .
  hence "set l' = set (take i l @ drop (2 + i) l)" by simp
  moreover
  have "\<dots> = set (take i l @ drop (2 + i) l)" by auto
  moreover
  have "\<dots> \<subseteq> set (take i l) \<union> set (drop (2 + i) l)" by auto
  moreover
  have "\<dots> \<subseteq> set l" by (auto dest: in_set_takeD in_set_dropD)
  ultimately
  have "set l' \<subseteq> set l" by simp
  thus ?thesis using assms(2) by auto
qed

lemma cancels_to_preserves_generators:
  assumes "cancels_to l l'"
      and "l \<in> lists (UNIV \<times> gens)"
  shows "l' \<in> lists (UNIV \<times> gens)"
using assms unfolding cancels_to_def by (induct, auto dest:cancels_to_1_preserves_generators)

lemma normalize_preserves_generators:
  assumes "l \<in> lists (UNIV \<times> gens)"
    shows "normalize l \<in> lists (UNIV \<times> gens)"
proof-
  have "cancels_to l (normalize l)" by simp
  thus ?thesis using assms by(rule cancels_to_preserves_generators)
qed

text {*
Two simplification lemmas about lists.
*}

lemma empty_in_lists[simp]:
  "[] \<in> lists A" by auto

lemma lists_empty[simp]: "lists {} = {[]}"
  by auto

subsection {* Normalization and renaming generators *}

text {*
Renaming the generators, i.e. mapping them through an injective function, commutes
with normalization. Similarly, replacing generators by their inverses and
vica-versa commutes with normalization. Both operations are similar enough to be
handled at once here.
*}

lemma rename_gens_cancel_at: "cancel_at i (map f l) = map f (cancel_at i l)"
unfolding "cancel_at_def" by (auto simp add:take_map drop_map)

lemma rename_gens_cancels_to_1:
  assumes "inj f"
      and "cancels_to_1 l l'"
    shows "cancels_to_1 (map (prod_fun f g) l) (map (prod_fun f g) l')"
proof-
  from `cancels_to_1 l l'`
  obtain ls1 l1 l2 ls2
    where "l = ls1 @ l1 # l2 # ls2"
      and "l' = ls1 @ ls2"
      and "canceling l1 l2"
  by (rule cancels_to_1_unfold)

  from `canceling l1 l2`
  have "fst l1 \<noteq> fst l2" and "snd l1 = snd l2"
    unfolding canceling_def by auto
  from `fst l1 \<noteq> fst l2` and `inj f`
  have "f (fst l1) \<noteq> f (fst l2)" by(auto dest!:inj_on_contraD)
  hence "fst (prod_fun f g l1) \<noteq> fst (prod_fun f g l2)" by auto
  moreover
  from `snd l1 = snd l2`
  have "snd (prod_fun f g l1) = snd (prod_fun f g l2)" by auto
  ultimately
  have "canceling (prod_fun f g (l1)) (prod_fun f g (l2))"
    unfolding canceling_def by auto
  hence "cancels_to_1 (map (prod_fun f g) ls1 @ prod_fun f g l1 # prod_fun f g l2 # map (prod_fun f g) ls2) (map (prod_fun f g) ls1 @ map (prod_fun f g) ls2)"
   by(rule cancels_to_1_fold)
  with `l = ls1 @ l1 # l2 # ls2` and `l' = ls1 @ ls2`
  show "cancels_to_1 (map (prod_fun f g) l) (map (prod_fun f g) l')"
   by simp
qed

lemma rename_gens_cancels_to:
  assumes "inj f"
      and "cancels_to l l'"
    shows "cancels_to (map (prod_fun f g) l) (map (prod_fun f g) l')"
using `cancels_to l l'`
unfolding cancels_to_def
proof(induct rule:rtranclp_induct)
  case (step x z)
    from `cancels_to_1 x z` and `inj f`
    have "cancels_to_1 (map (prod_fun f g) x) (map (prod_fun f g) z)"
      by -(rule rename_gens_cancels_to_1)
    with `cancels_to_1^** (map (prod_fun f g) l) (map (prod_fun f g) x)`
    show "cancels_to_1^** (map (prod_fun f g) l) (map (prod_fun f g) z)" by auto
qed(auto)

   
lemma rename_gens_canceled:
  assumes "inj_on g (snd`set l)"
      and "canceled l"
  shows "canceled (map (prod_fun f g) l)"
unfolding canceled_def
proof
  (* This statement is needed explicitly later in this proof *)
  have different_images: "\<And> f a b. f a \<noteq> f b \<Longrightarrow> a \<noteq> b" by auto

  assume "DomainP cancels_to_1 (map (prod_fun f g) l)"
  then obtain l' where "cancels_to_1 (map (prod_fun f g) l) l'" by auto
  then obtain i where "Suc i < length l"
    and "canceling (map (prod_fun f g) l ! i) (map (prod_fun f g) l ! Suc i)"
    by(auto simp add:cancels_to_1_def cancels_to_1_at_def)
  hence "f (fst (l ! i)) \<noteq> f (fst (l ! Suc i))"
    and "g (snd (l ! i)) = g (snd (l ! Suc i))"
    by(auto simp add:canceling_def)
  from `f (fst (l ! i)) \<noteq> f (fst (l ! Suc i))`
  have "fst (l ! i) \<noteq> fst (l ! Suc i)" by -(erule different_images)
  moreover
  from `Suc i < length l`
  have "snd (l ! i) \<in> snd ` set l" and "snd (l ! Suc i) \<in> snd ` set l" by auto
  with `g (snd (l ! i)) = g (snd (l ! Suc i))`
  have "snd (l ! i) = snd (l ! Suc i)" 
    using `inj_on g (image snd (set l))`
    by (auto dest: inj_onD)
  ultimately
  have "canceling (l ! i) (l ! Suc i)" unfolding canceling_def by simp
  with `Suc i < length l`
  have "cancels_to_1_at i l (cancel_at i l)" 
    unfolding cancels_to_1_at_def by auto
  hence "cancels_to_1 l (cancel_at i l)"
    unfolding cancels_to_1_def by auto
  hence "\<not>canceled l"
    unfolding canceled_def by auto
  with `canceled l` show False by contradiction
qed

lemma rename_gens_normalize:
  assumes "inj f"
  and "inj_on g (snd ` set l)"
  shows "normalize (map (prod_fun f g) l) = map (prod_fun f g) (normalize l)"
proof(rule normalize_discover)
  from `inj_on g (image snd (set l))`
  have "inj_on g (image snd (set (normalize l)))"
  proof (rule subset_inj_on)
    
    have UNIV_snd: "\<And>A. A \<subseteq> UNIV \<times> snd ` A"
      proof fix A and x::"'c\<times>'d" assume "x\<in>A"
        hence "(fst x,snd x)\<in> (UNIV \<times> snd ` A)"
          by -(rule, auto)
        thus "x\<in> (UNIV \<times> snd ` A)" by simp
      qed

    have "l \<in> lists (set l)" by auto
    hence "l \<in> lists (UNIV \<times> snd ` set l)"
      by (rule subsetD[OF lists_mono[OF UNIV_snd], of l "set l"])
    hence "normalize l \<in> lists (UNIV \<times> snd ` set l)"
      by (rule normalize_preserves_generators[of _ "snd ` set l"])
    thus "snd ` set (normalize l) \<subseteq> snd ` set l"
      by (auto simp add: lists_eq_set)
   qed
  thus "canceled (map (prod_fun f g) (normalize l))" by(rule rename_gens_canceled,simp)
next
  from `inj f`
  show "cancels_to (map (prod_fun f g) l) (map (prod_fun f g) (normalize l))"
    by (rule rename_gens_cancels_to, simp)
qed

end
