(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Abstract syntax tree produced by parsing *)

open Asttypes

(* Extension points *)

type attribute = string * expression

and extension = string * expression

(* Type expressions for the core language *)

and core_type =
  { ptyp_desc: core_type_desc;
    ptyp_loc: Location.t;
    ptyp_attributes: attribute list;
   }

and core_type_desc =
    Ptyp_any
  | Ptyp_var of string
  | Ptyp_arrow of label * core_type * core_type
  | Ptyp_tuple of core_type list
  | Ptyp_constr of Longident.t loc * core_type list
  | Ptyp_object of (string * core_type) list * closed_flag
  | Ptyp_class of Longident.t loc * core_type list * label list
  | Ptyp_alias of core_type * string
  | Ptyp_variant of row_field list * bool * label list option
  | Ptyp_poly of string list * core_type
  | Ptyp_package of package_type
  | Ptyp_extension of extension


and package_type = Longident.t loc * (Longident.t loc * core_type) list

and row_field =
    Rtag of label * bool * core_type list
  | Rinherit of core_type

(* Type expressions for the class language *)

and 'a class_infos =
  { pci_virt: virtual_flag;
    pci_params: (string loc * variance) list * Location.t;
    pci_name: string loc;
    pci_expr: 'a;
    pci_loc: Location.t;
    pci_attributes: attribute list;
   }

(* Value expressions for the core language *)

and pattern =
  { ppat_desc: pattern_desc;
    ppat_loc: Location.t;
    ppat_attributes: attribute list;
   }

and pattern_desc =
    Ppat_any
  | Ppat_var of string loc
  | Ppat_alias of pattern * string loc
  | Ppat_constant of constant
  | Ppat_tuple of pattern list
  | Ppat_construct of Longident.t loc * pattern option * bool
  | Ppat_variant of label * pattern option
  | Ppat_record of (Longident.t loc * pattern) list * closed_flag
  | Ppat_array of pattern list
  | Ppat_or of pattern * pattern
  | Ppat_constraint of pattern * core_type
  | Ppat_type of Longident.t loc
  | Ppat_lazy of pattern
  | Ppat_unpack of string loc
  | Ppat_extension of extension

and expression =
  { pexp_desc: expression_desc;
    pexp_loc: Location.t;
    pexp_attributes: attribute list;
   }

and expression_desc =
    Pexp_ident of Longident.t loc
  | Pexp_constant of constant
  | Pexp_let of rec_flag * (pattern * expression) list * expression
  | Pexp_function of label * expression option * (pattern * expression) list
  | Pexp_apply of expression * (label * expression) list
  | Pexp_match of expression * (pattern * expression) list
  | Pexp_try of expression * (pattern * expression) list
  | Pexp_tuple of expression list
  | Pexp_construct of Longident.t loc * expression option * bool
  | Pexp_variant of label * expression option
  | Pexp_record of (Longident.t loc * expression) list * expression option
  | Pexp_field of expression * Longident.t loc
  | Pexp_setfield of expression * Longident.t loc * expression
  | Pexp_array of expression list
  | Pexp_ifthenelse of expression * expression * expression option
  | Pexp_sequence of expression * expression
  | Pexp_while of expression * expression
  | Pexp_for of
      string loc *  expression * expression * direction_flag * expression
  | Pexp_constraint of expression * core_type option * core_type option
  | Pexp_when of expression * expression
  | Pexp_send of expression * string
  | Pexp_new of Longident.t loc
  | Pexp_setinstvar of string loc * expression
  | Pexp_override of (string loc * expression) list
  | Pexp_letmodule of string loc * module_expr * expression
  | Pexp_assert of expression
  | Pexp_assertfalse
  | Pexp_lazy of expression
  | Pexp_poly of expression * core_type option
  | Pexp_object of class_structure
  | Pexp_newtype of string * expression
  | Pexp_pack of module_expr
  | Pexp_open of Longident.t loc * expression
  | Pexp_extension of extension

(* Value descriptions *)

and value_description =
  { pval_name: string loc;
    pval_type: core_type;
    pval_prim: string list;
    pval_attributes: attribute list;
    pval_loc: Location.t
    }

(* Type declarations *)

and type_declaration =
  { ptype_name: string loc;
    ptype_params: (string loc option * variance) list;
    ptype_cstrs: (core_type * core_type * Location.t) list;
    ptype_kind: type_kind;
    ptype_private: private_flag;
    ptype_manifest: core_type option;
    ptype_attributes: attribute list;
    ptype_loc: Location.t }

and type_kind =
    Ptype_abstract
  | Ptype_variant of constructor_declaration list
  | Ptype_record of label_declaration list

and label_declaration =
    {
     pld_name: string loc;
     pld_mutable: mutable_flag;
     pld_type: core_type;
     pld_loc: Location.t;
     pld_attributes: attribute list;
    }

and constructor_declaration =
    {
     pcd_name: string loc;
     pcd_args: core_type list;
     pcd_res: core_type option;
     pcd_loc: Location.t;
     pcd_attributes: attribute list;
    }

(* Type expressions for the class language *)

and class_type =
    {
     pcty_desc: class_type_desc;
     pcty_loc: Location.t;
     pcty_attributes: attribute list;
    }

and class_type_desc =
    Pcty_constr of Longident.t loc * core_type list
  | Pcty_signature of class_signature
  | Pcty_fun of label * core_type * class_type
  | Pcty_extension of extension

and class_signature = {
    pcsig_self: core_type;
    pcsig_fields: class_type_field list;
    pcsig_loc: Location.t;
  }

and class_type_field = {
    pctf_desc: class_type_field_desc;
    pctf_loc: Location.t;
    pctf_attributes: attribute list;
  }

and class_type_field_desc =
    Pctf_inherit of class_type
  | Pctf_val of (string * mutable_flag * virtual_flag * core_type)
  | Pctf_method  of (string * private_flag * virtual_flag * core_type)
  | Pctf_constraint  of (core_type * core_type)

and class_description = class_type class_infos

and class_type_declaration = class_type class_infos

(* Value expressions for the class language *)

and class_expr =
  {
   pcl_desc: class_expr_desc;
   pcl_loc: Location.t;
   pcl_attributes: attribute list;
  }

and class_expr_desc =
    Pcl_constr of Longident.t loc * core_type list
  | Pcl_structure of class_structure
  | Pcl_fun of label * expression option * pattern * class_expr
  | Pcl_apply of class_expr * (label * expression) list
  | Pcl_let of rec_flag * (pattern * expression) list * class_expr
  | Pcl_constraint of class_expr * class_type
  | Pcl_extension of extension

and class_structure = {
    pcstr_self: pattern;
    pcstr_fields: class_field list;
  }

and class_field = {
    pcf_desc: class_field_desc;
    pcf_loc: Location.t;
    pcf_attributes: attribute list;
  }

and class_field_desc =
    Pcf_inherit of override_flag * class_expr * string option
  | Pcf_val of (string loc * mutable_flag * class_field_kind)
  | Pcf_method of (string loc * private_flag * class_field_kind)
  | Pcf_constraint of (core_type * core_type)
  | Pcf_initializer of expression

and class_field_kind =
  | Cfk_virtual of core_type
  | Cfk_concrete of override_flag * expression

and class_declaration = class_expr class_infos

(* Type expressions for the module language *)

and module_type =
  { pmty_desc: module_type_desc;
    pmty_loc: Location.t;
    pmty_attributes: attribute list;
   }

and module_type_desc =
    Pmty_ident of Longident.t loc
  | Pmty_signature of signature
  | Pmty_functor of string loc * module_type * module_type
  | Pmty_with of module_type * (Longident.t loc * with_constraint) list
  | Pmty_typeof of module_expr
  | Pmty_extension of extension

and signature = signature_item list

and signature_item =
  { psig_desc: signature_item_desc;
    psig_loc: Location.t }

and signature_item_desc =
    Psig_value of value_description
  | Psig_type of type_declaration list
  | Psig_exception of constructor_declaration
  | Psig_module of module_declaration
  | Psig_recmodule of module_declaration list
  | Psig_modtype of module_type_declaration
  | Psig_open of Longident.t loc * attribute list
  | Psig_include of module_type * attribute list
  | Psig_class of class_description list
  | Psig_class_type of class_type_declaration list
  | Psig_attribute of attribute
  | Psig_extension of extension * attribute list

and module_declaration =
    {
     pmd_name: string loc;
     pmd_type: module_type;
     pmd_attributes: attribute list;
    }

and module_type_declaration =
    {
     pmtd_name: string loc;
     pmtd_type: module_type option;
     pmtd_attributes: attribute list;
    }

and with_constraint =
    Pwith_type of type_declaration
  | Pwith_module of Longident.t loc
  | Pwith_typesubst of type_declaration
  | Pwith_modsubst of Longident.t loc

(* Value expressions for the module language *)

and module_expr =
  { pmod_desc: module_expr_desc;
    pmod_loc: Location.t;
    pmod_attributes: attribute list;
 }

and module_expr_desc =
    Pmod_ident of Longident.t loc
  | Pmod_structure of structure
  | Pmod_functor of string loc * module_type * module_expr
  | Pmod_apply of module_expr * module_expr
  | Pmod_constraint of module_expr * module_type
  | Pmod_unpack of expression
  | Pmod_extension of extension

and structure = structure_item list

and structure_item =
  { pstr_desc: structure_item_desc;
    pstr_loc: Location.t }

and structure_item_desc =
    Pstr_eval of expression
  | Pstr_value of rec_flag * (pattern * expression) list
  | Pstr_primitive of value_description
  | Pstr_type of type_declaration list
  | Pstr_exception of constructor_declaration
  | Pstr_exn_rebind of string loc * Longident.t loc * attribute list
  | Pstr_module of module_binding
  | Pstr_recmodule of module_binding list
  | Pstr_modtype of module_type_binding
  | Pstr_open of Longident.t loc * attribute list
  | Pstr_class of class_declaration list
  | Pstr_class_type of class_type_declaration list
  | Pstr_include of module_expr * attribute list
  | Pstr_attribute of attribute
  | Pstr_extension of extension * attribute list

and module_binding =
    {
     pmb_name: string loc;
     pmb_expr: module_expr;
     pmb_attributes: attribute list;
    }

and module_type_binding =
    {
     pmtb_name: string loc;
     pmtb_type: module_type;
     pmtb_attributes: attribute list;
    }

(* Toplevel phrases *)

type toplevel_phrase =
    Ptop_def of structure
  | Ptop_dir of string * directive_argument

and directive_argument =
    Pdir_none
  | Pdir_string of string
  | Pdir_int of int
  | Pdir_ident of Longident.t
  | Pdir_bool of bool
