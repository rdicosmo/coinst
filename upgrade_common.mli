(* Co-installability tools
 * http://coinst.irill.org/
 * Copyright (C) 2011 Jérôme Vouillon
 * Laboratoire PPS - CNRS Université Paris Diderot
 *
 * These programs are free software; you can redistribute them and/or
 * modify them under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)

module Repository : Repository.S with type pool = Deb_lib.pool
open Repository
module PSetSet : Set.S with type elt = PSet.t

type state =
  { dist : Deb_lib.deb_pool;
    deps : Formula.t PTbl.t;
    confl : Conflict.t;
    deps' : Formula.t PTbl.t;
    confl' : Conflict.t;
    st : Deb_lib.Solver.state }

val prepare_analyze : pool -> state

type pkg_ref = string * bool * bool
type reason =
    R_depends of pkg_ref * string Deb_lib.dep * pkg_ref list
  | R_conflict of pkg_ref * string Deb_lib.dep * pkg_ref
type clause = { pos : Util.StringSet.t; neg : Util.StringSet.t }
type problem =
  { p_clause : clause; p_issue : Util.StringSet.t; p_explain : reason list;
    p_support1 : Util.StringSet.t; p_support2 : Util.StringSet.t }
type issue =
  { i_issue : PSet.t; i_problem : problem }
type ignored_sets

val analyze :
  ?check_new_packages:bool -> ignored_sets ->
  ?reference:state ->
  state -> pool ->
  Deb_lib.Solver.var PTbl.t * PSet.t * Conflict.t * PSet.t PTbl.t *
  issue list *
  (Package.t * clause * reason list * Util.StringSet.t * Util.StringSet.t) list

val find_problematic_packages :
  ?check_new_packages:bool -> ignored_sets ->
  state -> state -> (Deb_lib.package_name -> bool) -> problem list

val find_non_inst_packages :
  bool -> ignored_sets -> state -> state -> (Deb_lib.package_name -> bool) ->
  problem list

val find_clusters :
  state -> state -> (Deb_lib.package_name -> bool) ->
  (string list * 'a) list -> ('a -> 'a -> unit) -> unit

val output_conflict_graph : Format.formatter -> problem -> unit

val ignored_set_domain : ignored_sets -> Deb_lib.PkgSet.t
val is_ignored_set : ignored_sets -> Util.StringSet.t -> bool

val conj_dependencies : pool -> Formula.t PTbl.t -> PSet.t option PTbl.t
val reversed_conj_dependencies : pool -> Formula.t PTbl.t -> PSet.t PTbl.t

val empty_break_set : unit -> ignored_sets
val allow_broken_sets : ignored_sets -> string -> unit
val copy_ignored_sets : ignored_sets -> ignored_sets
