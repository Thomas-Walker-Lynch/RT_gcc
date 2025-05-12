/* 
  Given the cpp_reader and an assignment argument in the form of a macro.
  Returns ... through the `result` argument.
  Returns ...

  Assign name_expr and body_expr arguments are each placed into a
  macro instance, then are sent here to be expanded.

  Push the context of a macro onto the context stack.  If we can
  successfully expand the macro, we push a context containing its
  yet-to-be-rescanned replacement list and return one.  LOCATION is
  the location of the expansion point of the macro.

  derived from enter_macro_context()
*/
static int
enter_macro_context_RT_assign(
  cpp_reader *pfile
  ,cpp_macro *macro
  ,const cpp_token *result
  ,location_t location
){
  /* The presence of a macro invalidates a file's controlling macro.  */
  pfile->mi_valid = false;
  pfile->state.angled_headers = false;
  pfile->about_to_expand_macro_p = true;

      // not expanding a pragma

      // Disable the macro within its expansion. 
      // assign has no node at this point
      // node->flags |= NODE_DISABLED;

      // not lazy, doing it now
      // no need to notify of macro use
      // macro->paramc is indeed zero when we get here (assign has no parameters)

      unsigned tokens_count = macro_real_token_count (macro);

      // no need to check for the track_macro_expansion option

      //_cpp_push_token_context (pfile, node, macro->exp.tokens, tokens_count);
      // _cpp_push_token_context allows for a NULL node
      _cpp_push_token_context (pfile, NULL, macro->exp.tokens, tokens_count);
                                 
      num_macro_tokens_counter += tokens_count;

      // not inside of a pragma (inside of a #assign)

      pfile->about_to_expand_macro_p = false;
      return 1;

  pfile->about_to_expand_macro_p = false;
  /* Handle built-in macros and the _Pragma operator.  */
  {
    location_t expand_loc;

    // not function like

      /* Otherwise, the location of the end of the macro invocation is
	 the location of the expansion point of that top-level macro
	 invocation.  */
      expand_loc = pfile->invocation_location;

    return builtin_macro (pfile, node, location, expand_loc);
  }
}
