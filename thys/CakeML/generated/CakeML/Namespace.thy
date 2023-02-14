chapter \<open>Generated by Lem from \<open>semantics/namespace.lem\<close>.\<close>

theory "Namespace" 

imports
  Main
  "HOL-Library.Datatype_Records"
  "LEM.Lem_pervasives"
  "LEM.Lem_set_extra"

begin 

\<comment> \<open>\<open>open import Pervasives\<close>\<close>
\<comment> \<open>\<open>open import Set_extra\<close>\<close>

type_synonym( 'k, 'v) alist0 =" ('k * 'v) list "

\<comment> \<open>\<open> Identifiers \<close>\<close>
datatype( 'm, 'n) id0 =
    Short " 'n "
  | Long " 'm " " ('m, 'n) id0 "

\<comment> \<open>\<open>val mk_id : forall 'n 'm. list 'm -> 'n -> id 'm 'n\<close>\<close>
fun  mk_id  :: " 'm list \<Rightarrow> 'n \<Rightarrow>('m,'n)id0 "  where 
     " mk_id [] n = ( Short n )"
    |" mk_id (mn # mns) n = ( Long mn (mk_id mns n))"


\<comment> \<open>\<open>val id_to_n : forall 'n 'm. id 'm 'n -> 'n\<close>\<close>
fun  id_to_n  :: "('m,'n)id0 \<Rightarrow> 'n "  where 
     " id_to_n (Short n) = ( n )"
    |" id_to_n (Long _ id1) = ( id_to_n id1 )"


\<comment> \<open>\<open>val id_to_mods : forall 'n 'm. id 'm 'n -> list 'm\<close>\<close>
fun  id_to_mods  :: "('m,'n)id0 \<Rightarrow> 'm list "  where 
     " id_to_mods (Short _) = ( [])"
    |" id_to_mods (Long mn id1) = ( mn # id_to_mods id1 )"


datatype( 'm, 'n, 'v) namespace =
  Bind " ('n, 'v) alist0 " " ('m, ( ('m, 'n, 'v)namespace)) alist0 "

\<comment> \<open>\<open>val nsLookup : forall 'v 'm 'n. Eq 'n, Eq 'm => namespace 'm 'n 'v -> id 'm 'n -> maybe 'v\<close>\<close>
fun  nsLookup  :: "('m,'n,'v)namespace \<Rightarrow>('m,'n)id0 \<Rightarrow> 'v option "  where 
     " nsLookup (Bind v2 m) (Short n) = ( List.map_of v2 n )"
    |" nsLookup (Bind v2 m) (Long mn id1) = (
      (case  List.map_of m mn of
        None => None
      | Some env => nsLookup env id1
      ))"


\<comment> \<open>\<open>val nsLookupMod : forall 'm 'n 'v. Eq 'n, Eq 'm => namespace 'm 'n 'v -> list 'm -> maybe (namespace 'm 'n 'v)\<close>\<close>
fun  nsLookupMod  :: "('m,'n,'v)namespace \<Rightarrow> 'm list \<Rightarrow>(('m,'n,'v)namespace)option "  where 
     " nsLookupMod e [] = ( Some e )"
    |" nsLookupMod (Bind v2 m) (mn # path) = (
      (case  List.map_of m mn of
        None => None
      | Some env => nsLookupMod env path
      ))"


\<comment> \<open>\<open>val nsEmpty : forall 'v 'm 'n. namespace 'm 'n 'v\<close>\<close>
definition nsEmpty  :: "('m,'n,'v)namespace "  where 
     " nsEmpty = ( Bind [] [])"


\<comment> \<open>\<open>val nsAppend : forall 'v 'm 'n. namespace 'm 'n 'v -> namespace 'm 'n 'v -> namespace 'm 'n 'v\<close>\<close>
fun nsAppend  :: "('m,'n,'v)namespace \<Rightarrow>('m,'n,'v)namespace \<Rightarrow>('m,'n,'v)namespace "  where 
     " nsAppend (Bind v1 m1) (Bind v2 m2) = ( Bind (v1 @ v2) (m1 @ m2))"


\<comment> \<open>\<open>val nsLift : forall 'v 'm 'n. 'm -> namespace 'm 'n 'v -> namespace 'm 'n 'v\<close>\<close>
definition nsLift  :: " 'm \<Rightarrow>('m,'n,'v)namespace \<Rightarrow>('m,'n,'v)namespace "  where 
     " nsLift mn env = ( Bind [] [(mn, env)])"


\<comment> \<open>\<open>val alist_to_ns : forall 'v 'm 'n. alist 'n 'v -> namespace 'm 'n 'v\<close>\<close>
definition alist_to_ns  :: "('n*'v)list \<Rightarrow>('m,'n,'v)namespace "  where 
     " alist_to_ns a = ( Bind a [])"


\<comment> \<open>\<open>val nsBind : forall 'v 'm 'n. 'n -> 'v -> namespace 'm 'n 'v -> namespace 'm 'n 'v\<close>\<close>
fun nsBind  :: " 'n \<Rightarrow> 'v \<Rightarrow>('m,'n,'v)namespace \<Rightarrow>('m,'n,'v)namespace "  where 
     " nsBind k x (Bind v2 m) = ( Bind ((k,x)# v2) m )"


\<comment> \<open>\<open>val nsBindList : forall 'v 'm 'n. list ('n * 'v) -> namespace 'm 'n 'v -> namespace 'm 'n 'v\<close>\<close>
definition nsBindList  :: "('n*'v)list \<Rightarrow>('m,'n,'v)namespace \<Rightarrow>('m,'n,'v)namespace "  where 
     " nsBindList l e = ( List.foldr ( \<lambda>x .  
  (case  x of (x,v2) => \<lambda> e .  nsBind x v2 e )) l e )"


\<comment> \<open>\<open>val nsOptBind : forall 'v 'm 'n. maybe 'n -> 'v -> namespace 'm 'n 'v -> namespace 'm 'n 'v\<close>\<close>
fun nsOptBind  :: " 'n option \<Rightarrow> 'v \<Rightarrow>('m,'n,'v)namespace \<Rightarrow>('m,'n,'v)namespace "  where 
     " nsOptBind None x env = ( env )"
|" nsOptBind (Some n') x env = ( nsBind n' x env )"


\<comment> \<open>\<open>val nsSing : forall 'v 'm 'n. 'n -> 'v -> namespace 'm 'n 'v\<close>\<close>
definition nsSing  :: " 'n \<Rightarrow> 'v \<Rightarrow>('m,'n,'v)namespace "  where 
     " nsSing n x = ( Bind ([(n,x)]) [])"


\<comment> \<open>\<open>val nsSub : forall 'v1 'v2 'm 'n. Eq 'm, Eq 'n, Eq 'v1, Eq 'v2 =>
  (id 'm 'n -> 'v1 -> 'v2 -> bool) -> namespace 'm 'n 'v1 -> namespace 'm 'n 'v2 -> bool\<close>\<close>
definition nsSub  :: "(('m,'n)id0 \<Rightarrow> 'v1 \<Rightarrow> 'v2 \<Rightarrow> bool)\<Rightarrow>('m,'n,'v1)namespace \<Rightarrow>('m,'n,'v2)namespace \<Rightarrow> bool "  where 
     " nsSub r env1 env2 = (
  ((\<forall> id0. \<forall> v1. 
    (nsLookup env1 id0 = Some v1)
    \<longrightarrow>
    ((\<exists> v2.  (nsLookup env2 id0 = Some v2) \<and> r id0 v1 v2))))
  \<and>
  ((\<forall> path. 
    (nsLookupMod env2 path = None) \<longrightarrow> (nsLookupMod env1 path = None))))"


\<comment> \<open>\<open>val nsAll : forall 'v 'm 'n. Eq 'm, Eq 'n, Eq 'v => (id 'm 'n -> 'v -> bool) -> namespace 'm 'n 'v -> bool\<close>\<close>
fun  nsAll  :: "(('m,'n)id0 \<Rightarrow> 'v \<Rightarrow> bool)\<Rightarrow>('m,'n,'v)namespace \<Rightarrow> bool "  where 
     " nsAll f env = (
  ((\<forall> id0. \<forall> v1. 
     (nsLookup env id0 = Some v1)
     \<longrightarrow>
     f id0 v1)))"


\<comment> \<open>\<open>val eAll2 : forall 'v1 'v2 'm 'n. Eq 'm, Eq 'n, Eq 'v1, Eq 'v2 =>
   (id 'm 'n -> 'v1 -> 'v2 -> bool) -> namespace 'm 'n 'v1 -> namespace 'm 'n 'v2 -> bool\<close>\<close>
definition nsAll2  :: "(('d,'c)id0 \<Rightarrow> 'b \<Rightarrow> 'a \<Rightarrow> bool)\<Rightarrow>('d,'c,'b)namespace \<Rightarrow>('d,'c,'a)namespace \<Rightarrow> bool "  where 
     " nsAll2 r env1 env2 = (
  nsSub r env1 env2 \<and>
  nsSub (\<lambda> x y z .  r x z y) env2 env1 )"


\<comment> \<open>\<open>val nsDom : forall 'v 'm 'n. Eq 'm, Eq 'n, Eq 'v, SetType 'v => namespace 'm 'n 'v -> set (id 'm 'n)\<close>\<close>
definition nsDom  :: "('m,'n,'v)namespace \<Rightarrow>(('m,'n)id0)set "  where 
     " nsDom env = ( (let x2 = 
  ({}) in  Finite_Set.fold
   (\<lambda>v2 x2 .  Finite_Set.fold
                        (\<lambda>n x2 . 
                         if nsLookup env n = Some v2 then Set.insert n x2
                         else x2) x2 UNIV) x2 UNIV))"


\<comment> \<open>\<open>val nsDomMod : forall 'v 'm 'n. SetType 'm, Eq 'm, Eq 'n, Eq 'v => namespace 'm 'n 'v -> set (list 'm)\<close>\<close>
definition nsDomMod  :: "('m,'n,'v)namespace \<Rightarrow>('m list)set "  where 
     " nsDomMod env = ( (let x2 = 
  ({}) in  Finite_Set.fold
   (\<lambda>v2 x2 .  Finite_Set.fold
                        (\<lambda>n x2 . 
                         if nsLookupMod env n = Some v2 then Set.insert n x2
                         else x2) x2 UNIV) x2 UNIV))"


\<comment> \<open>\<open>val nsMap : forall 'v 'w 'm 'n. ('v -> 'w) -> namespace 'm 'n 'v -> namespace 'm 'n 'w\<close>\<close>
function (sequential,domintros)  nsMap  :: "('v \<Rightarrow> 'w)\<Rightarrow>('m,'n,'v)namespace \<Rightarrow>('m,'n,'w)namespace "  where 
     " nsMap f (Bind v2 m) = (
  Bind (List.map ( \<lambda>x .  
  (case  x of (n,x) => (n, f x) )) v2)
       (List.map ( \<lambda>x .  
  (case  x of (mn,e) => (mn, nsMap f e) )) m))" 
by pat_completeness auto

end
