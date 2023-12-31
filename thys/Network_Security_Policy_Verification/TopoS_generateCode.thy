theory TopoS_generateCode
imports
  TopoS_Library
  Example_BLP
begin

setup \<open>fn thy =>
  let
    val package = "package tum.in.net.psn.log_topo.SecurityInvariants.GENERATED";   
    val date = Date.toString (Date.fromTimeLocal (Time.now ()));
    val export_file = Context.theory_base_name thy ^ ".thy";
    val header = package ^ "\n" ^ "// Generated by " ^ Isabelle_System.identification () ^ " on " ^ date ^ "\n" ^ "// src: " ^ export_file ^ "\n";
  in
    Code_Target.set_printings (Code_Symbol.Module ("", [("Scala", SOME (header, []))])) thy
  end
\<close>


export_code 
  \<comment> \<open>generic network security invariants\<close>
      SINVAR_LIB_BLPbasic
      SINVAR_LIB_Dependability
      SINVAR_LIB_DomainHierarchyNG
      SINVAR_LIB_Subnets
      SINVAR_LIB_BLPtrusted 
      SINVAR_LIB_PolEnforcePointExtended
      SINVAR_LIB_Sink
      SINVAR_LIB_NonInterference
      SINVAR_LIB_SubnetsInGW
      SINVAR_LIB_CommunicationPartners
  \<comment> \<open>accessors to the packed invariants\<close>
      nm_eval
      nm_node_props
      nm_offending_flows
      nm_sinvar
      nm_default
      nm_receiver_violation nm_name
  \<comment> \<open>TopoS Params\<close>
      node_properties
  \<comment> \<open>Finite Graph functions\<close>
      FiniteListGraph.wf_list_graph
      FiniteListGraph.add_node 
      FiniteListGraph.delete_node
      FiniteListGraph.add_edge
      FiniteListGraph.delete_edge
      FiniteListGraph.delete_edges
  \<comment> \<open>Examples\<close>
  BLPexample1 BLPexample3 
  in Scala
  (*file "code/isabelle_generated.scala"*)

end
