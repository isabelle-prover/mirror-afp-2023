(*  Title:      PKCS_Model09.thy
    Author:     Andreas Viktor Hess, DTU
    Author:     Sebastian A. Mödersheim, DTU
    Author:     Achim D. Brucker, University of Exeter
    Author:     Anders Schlichtkrull, DTU
    SPDX-License-Identifier: BSD-3-Clause
*)

section\<open>The PKCS Protocol, Scenario 9\<close>
theory PKCS_Model09
  imports "../../PSPSP"

begin

declare [[code_timing,pspsp_timing]]

trac\<open>
Protocol: LOSS_KEY_ATT

Enumerations: 
token   = {token1}

Sets:
extract/1 wrap/1 unwrap/1 decrypt/1 sensitive/1

Functions:
Public  senc/2 h/2 bind/3
Private inv/1

Analysis:
senc(M1,K2) ? K2 -> M1  #This analysis rule corresponds to the decrypt2 rule in the AIF-omega specification.
                        #M1 was type untyped

Transactions:
intruderValueGen()
  new K
  send K.

iik1()
  new K1
  new N1
  insert N1 sensitive(token1)
  insert N1 extract(token1)
  insert K1 sensitive(token1)
  send h(N1,K1).

iik2()
  new K2
  new N2
  insert N2 wrap(token1)
  insert N2 extract(token1)
  send h(N2,K2).

iik3()
  new K3
  new N3
  insert N3 extract(token1)
  insert N3 decrypt(token1)
  insert K3 decrypt(token1)
  send h(N3,K3)
  send K3.

# =====set wrap=====
setwrap(N2:value,K2:value) where N2 != K2
  receive h(N2,K2)
  N2 notin sensitive(token1)
  N2 notin decrypt(token1)
  insert N2 wrap(token1).

# =====set unwrap===
setunwrap(N2:value,K2:value) where N2 != K2
  receive h(N2,K2)
  N2 notin sensitive(token1)
  insert N2 unwrap(token1).

# =====unwrap, generate new handler======
#-----------add the wrap attr copy-------------
unwrapWrap(M2:value,K2:value,N1:value,N2:value) where M2 != K2, M2 != N1, M2 != N2, K2 != N1, K2 != N2, N1 != N2 #M2 was untyped in the AIF-omega specification.
  receive senc(M2,K2)
  receive bind(N1,M2,K2)
  receive h(N2,K2)
  N1 in wrap(token1)
  N2 in unwrap(token1)
  new Nnew
  insert Nnew wrap(token1)
  send h(Nnew,M2).

#-----------add the senstive attr copy-------------
unwrapSens(M2:value,K2:value,N1:value,N2:value) where M2 != K2, M2 != N1, M2 != N2, K2 != N1, K2 != N2, N1 != N2 #M2 was untyped in the AIF-omega specification.
  receive senc(M2,K2)
  receive bind(N1,M2,K2)
  receive h(N2,K2)
  N1 in sensitive(token1)
  N2 in unwrap(token1)
  new Nnew
  insert Nnew sensitive(token1)
  send h(Nnew,M2).

#-----------add the decrypt attr copy-------------
decrypt1Attr(M2:value, K2:value,N1:value,N2:value) where M2 != K2, M2 != N1, M2 != N2, K2 != N1, K2 != N2, N1 != N2 #M2 was untyped in the AIF-omega specification.
  receive senc(M2,K2)
  receive bind(N1,M2,K2)
  receive h(N2,K2)
  N1 in decrypt(token1)
  N2 in unwrap(token1)
  new Nnew 
  insert Nnew decrypt(token1)
  send h(Nnew,M2).

decrypt2Attr(M2:value, K2:value,N1:value,N2:value) where M2 != K2, M2 != N1, M2 != N2, K2 != N1, K2 != N2, N1 != N2 #M2 was untyped in the AIF-omega specification.
  receive senc(M2,K2)
  receive bind(N1,M2,K2)
  receive h(N2,K2)
  N1 notin wrap(token1)
  N1 notin sensitive(token1)
  N1 notin decrypt(token1)
  N2 in unwrap(token1)
  new Nnew 
  send h(Nnew,M2).

# ======================wrap================
wrap(N1:value,K1:value, N2:value, K2:value) where N1 != N2, N1 != K2, N1 != K1, N2 != K2, N2 != K1, K2 != K1
  receive h(N1,K1)
  receive h(N2,K2)
  N1 in extract(token1)
  N2 in wrap(token1)
  send senc(K1,K2)
  send bind(N1,K1,K2).

# ======================bind generation================
bind1(K3:value,N2:value,K2:value, K1:value) where K3 != N2, K3 != K2, K3 != K1, N2 != K2, N2 != K1, K2 != K1
  receive K3
  receive h(N2,K2)
  send bind(N2,K3,K3).

bind2(K3:value,N2:value,K2:value, K1:value) where K3 != N2, K3 != K2, K3 != K1, N2 != K2, N2 != K1, K2 != K1
  receive K3
  receive K1
  receive h(N2,K2)
  send bind(N2,K1,K3)
  send bind(N2,K3,K1).

# =====set decrypt===
setdecrypt(Nnew:value,K2:value) where Nnew != K2
  receive h(Nnew,K2) 
  Nnew notin wrap(token1)
  insert Nnew decrypt(token1).

# ======================decrypt================
decrypt1(Nnew:value,K2:value,M1:value) where Nnew != K2, Nnew != M1, K2 != M1 #M1 was untyped in the AIF-omega specification.
  receive h(Nnew,K2)
  receive senc(M1,K2)
  Nnew in decrypt(token1)
  send M1.

# ======================attacks================
attack1(K1:value)
  receive K1
  K1 in sensitive(token1)
  attack.
\<close>


subsection \<open>Protocol model setup\<close>
protocol_model_setup spm: LOSS_KEY_ATT


subsection \<open>Fixpoint computation\<close>
compute_fixpoint LOSS_KEY_ATT_protocol LOSS_KEY_ATT_fixpoint attack_trace

text \<open>The fixpoint contains an attack signal\<close>
lemma "attack\<langle>ln 0\<rangle> \<in> set (fst LOSS_KEY_ATT_fixpoint)"
by code_simp

text \<open>The attack trace can be inspected as follows\<close>
print_attack_trace LOSS_KEY_ATT LOSS_KEY_ATT_protocol attack_trace


subsection \<open>The generated theorems and definitions\<close>
thm LOSS_KEY_ATT_enum_consts.nchotomy
thm LOSS_KEY_ATT_sets.nchotomy
thm LOSS_KEY_ATT_fun.nchotomy
thm LOSS_KEY_ATT_atom.nchotomy
thm LOSS_KEY_ATT_arity.simps
thm LOSS_KEY_ATT_public.simps
thm LOSS_KEY_ATT_\<Gamma>.simps
thm LOSS_KEY_ATT_Ana.simps

thm LOSS_KEY_ATT_transaction_iik1_def
thm LOSS_KEY_ATT_transaction_iik2_def
thm LOSS_KEY_ATT_transaction_iik3_def
thm LOSS_KEY_ATT_transaction_setwrap_def
thm LOSS_KEY_ATT_transaction_setunwrap_def
thm LOSS_KEY_ATT_transaction_unwrapWrap_def
thm LOSS_KEY_ATT_transaction_unwrapSens_def
thm LOSS_KEY_ATT_transaction_decrypt1Attr_def
thm LOSS_KEY_ATT_transaction_decrypt2Attr_def
thm LOSS_KEY_ATT_transaction_wrap_def
thm LOSS_KEY_ATT_transaction_bind1_def
thm LOSS_KEY_ATT_transaction_bind2_def
thm LOSS_KEY_ATT_transaction_setdecrypt_def
thm LOSS_KEY_ATT_transaction_decrypt1_def
thm LOSS_KEY_ATT_transaction_attack1_def

thm LOSS_KEY_ATT_protocol_def
thm LOSS_KEY_ATT_fixpoint_def

end
