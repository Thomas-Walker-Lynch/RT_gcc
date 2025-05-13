/*================================================================================
from directive.cc

*/

  D(macro         ,T_MACRO         ,EXTENSION   ,IN_I)                     \

/*--------------------------------------------------------------------------------
  directive `#macro`

    cmd        ::= "#macro" name params body ;

    name       ::= identifier ;

    params     ::= "(" param_list? ")" ;
    param_list ::= identifier ("," identifier)* ;

    body       ::= clause ;

    clause     ::= "(" literal? ")" | "[" expr? "]" ;

    literal    ::= ; sequence parsed into tokens
    expr       ::= ; sequence parsed into tokens with recursive expansion of each token

    ; white space, including new lines, is ignored.


*/
extern bool _cpp_create_macro (cpp_reader *pfile, cpp_hashnode *node);

static void
do_macro (cpp_reader *pfile)
{
  cpp_hashnode *node = lex_macro_node(pfile, true);

  if(node)
    {
      /* If we have been requested to expand comments into macros,
	 then re-enable saving of comments.  */
      pfile->state.save_comments =
	! CPP_OPTION (pfile, discard_comments_in_macro_exp);

      if(pfile->cb.before_define)
	pfile->cb.before_define (pfile);

      if( _cpp_create_macro(pfile, node) )
	if (pfile->cb.define)
	  pfile->cb.define (pfile, pfile->directive_line, node);

      node->flags &= ~NODE_USED;
    }
}






/*================================================================================
from macro.cc

*/





/*--------------------------------------------------------------------------------
  Given a pfile, returns a macro definition.

  #macro name (parameter [,parameter] ...) (body_expr)
  #macro name () (body_expr)

  Upon entry, the name was already been parsed in directives.cc::do_macro, so the next token will be the opening paren of the parameter list.

  Thi code is similar to `_cpp_create_definition` though uses paren blancing around the body, instead of requiring the macro body be on a single line.

  The cpp_macro struct is defined in cpplib.h:  `struct GTY(()) cpp_macro {` it has a flexible array field in a union as a last member: cpp_token tokens[1];

  This code was derived from create_iso_definition(). The break out portions shared
  with create_macro_definition code should be shared with the main code, so that there
  is only one place for edits.

*/
static cpp_macro *create_iso_RT_macro (cpp_reader *pfile){

  const char *paste_op_error_msg =
    N_("'##' cannot appear at either end of a macro expansion");
  unsigned int num_extra_tokens = 0;
  unsigned nparms = 0;
  cpp_hashnode **params = NULL;
  bool varadic = false;
  bool ok = false;
  cpp_macro *macro = NULL;

  /*
    After these six lines of code, the next token, hopefully being '(', will be in the variable 'token'.

    _cpp_lex_direct() is going to clobber  pfile->cur_token with the token pointer, so
    it is saved then restored.
  */
    cpp_token first;
    cpp_token *saved_cur_token = pfile->cur_token;
    pfile->cur_token = &first;
    cpp_token *token = _cpp_lex_direct (pfile);
    pfile->cur_token = saved_cur_token;

  // parameter list parsing
  //   
    if(token->type != CPP_OPEN_PAREN){
      cpp_error_with_line(
        pfile
        ,CPP_DL_ERROR
        ,token->src_loc
        ,0
        ,"expected '(' to open arguments list, but found: %s"
        ,cpp_token_as_text(token)
      );
      goto out;
    }

    /*
      - returns parameter list for a function macro, or NULL
      - returns via &arg count of parameters
      - returns via &arg the varadic flag

      after parse_parms runs, the next token returned by pfile will be subsequent to the parameter list, e.g.:
         7 |   #macro Q(f ,...) printf(f ,__VA_ARGS__)
           |                    ^~~~~~

    */
    if( !parse_params(pfile, &nparms, &varadic) ) goto out;

    // finalizes the reserved room, otherwise it will be reused on the next reserve room call.
    params = (cpp_hashnode **)_cpp_commit_buff( pfile, sizeof (cpp_hashnode *) * nparms );
    token = NULL;

  // instantiate a temporary macro struct, and initialize it
  //   A macro struct instance is variable size, due to a trailing token list, so the memory
  //   reservations size will be adjusted when this is committed.
  //
    macro = _cpp_new_macro(
      pfile
      ,cmk_macro
      ,_cpp_reserve_room( pfile, 0, sizeof(cpp_macro) ) 
    );
    macro->variadic = varadic;
    macro->paramc = nparms;
    macro->parm.params = params;
    macro->fun_like = true;

  // parse macro body 
  //   A `#macro` body is delineated by parentheses
  //
    if(
      !collect_body_tokens(
        pfile 
        ,macro 
        ,&num_extra_tokens 
        ,paste_op_error_msg 
        ,true // parenthesis delineated
      )
    ) goto out;

  // ok time to commit the macro
  //
    ok = true;
    macro = (cpp_macro *)_cpp_commit_buff(
      pfile
     ,sizeof (cpp_macro) - sizeof (cpp_token) + sizeof (cpp_token) * macro->count
    );

  // some end cases we must clean up
  //
    /*
      It might be that the first token of the macro body was preceded by white space,so
      the white space flag is set. However, upon expansion, there might not be a white
      space before said token, so the following code clears the flag.
    */
    if (macro->count)
      macro->exp.tokens[0].flags &= ~PREV_WHITE;

    /*
      Identifies consecutive ## tokens (a.k.a. CPP_PASTE) that were invalid or ambiguous,

      Removes them from the main macro body,

      Stashes them at the end of the tokens[] array in the same memory,

      Sets macro->extra_tokens = 1 to signal their presence.
    */
    if (num_extra_tokens)
      {
        /* Place second and subsequent ## or %:%: tokens in sequences of
           consecutive such tokens at the end of the list to preserve
           information about where they appear, how they are spelt and
           whether they are preceded by whitespace without otherwise
           interfering with macro expansion.   Remember, this is
           extremely rare, so efficiency is not a priority.  */
        cpp_token *temp = (cpp_token *)_cpp_reserve_room
          (pfile, 0, num_extra_tokens * sizeof (cpp_token));
        unsigned extra_ix = 0, norm_ix = 0;
        cpp_token *exp = macro->exp.tokens;
        for (unsigned ix = 0; ix != macro->count; ix++)
          if (exp[ix].type == CPP_PASTE)
            temp[extra_ix++] = exp[ix];
          else
            exp[norm_ix++] = exp[ix];
        memcpy (&exp[norm_ix], temp, num_extra_tokens * sizeof (cpp_token));

        /* Record there are extra tokens.  */
        macro->extra_tokens = 1;
      }

 out:

  /*
    - This resets a flag in the parser’s state machine, pfile.
    - The field `va_args_ok` tracks whether the current macro body is allowed to reference `__VA_ARGS__` (or more precisely, `__VA_OPT__`).
    - It's set **while parsing a macro body** that might use variadic logic — particularly in `vaopt_state` tracking.

    Resetting it here ensures that future macros aren't accidentally parsed under the assumption that variadic substitution is valid.
  */
  pfile->state.va_args_ok = 0;

  /*
    Earlier we did:
      if (!parse_params(pfile, &nparms, &variadic)) goto out;
    This cleans up temporary memory used by parse_params.
  */
  _cpp_unsave_parameters (pfile, nparms);

  return ok ? macro : NULL;
}

/*
  called from directives.cc:: do_macro
*/
bool
_cpp_create_macro(cpp_reader *pfile, cpp_hashnode *node){
  cpp_macro *macro;

  macro = create_iso_RT_macro (pfile);

  if (!macro)
    return false;

  if (cpp_macro_p (node))
    {
      if (CPP_OPTION (pfile, warn_unused_macros))
	_cpp_warn_if_unused_macro (pfile, node, NULL);

      if (warn_of_redefinition (pfile, node, macro))
	{
          const enum cpp_warning_reason reason
	    = (cpp_builtin_macro_p (node) && !(node->flags & NODE_WARN))
	    ? CPP_W_BUILTIN_MACRO_REDEFINED : CPP_W_NONE;

	  bool warned = 
	    cpp_pedwarning_with_line (pfile, reason,
				      pfile->directive_line, 0,
				      "\"%s\" redefined", NODE_NAME (node));

	  if (warned && cpp_user_macro_p (node))
	    cpp_error_with_line (pfile, CPP_DL_NOTE,
				 node->value.macro->line, 0,
			 "this is the location of the previous definition");
	}
      _cpp_free_definition (node);
    }

  /* Enter definition in hash table.  */
  node->type = NT_USER_MACRO;
  node->value.macro = macro;
  if (! ustrncmp (NODE_NAME (node), DSC ("__STDC_"))
      && ustrcmp (NODE_NAME (node), (const uchar *) "__STDC_FORMAT_MACROS")
      /* __STDC_LIMIT_MACROS and __STDC_CONSTANT_MACROS are mentioned
	 in the C standard, as something that one must use in C++.
	 However DR#593 and C++11 indicate that they play no role in C++.
	 We special-case them anyway.  */
      && ustrcmp (NODE_NAME (node), (const uchar *) "__STDC_LIMIT_MACROS")
      && ustrcmp (NODE_NAME (node), (const uchar *) "__STDC_CONSTANT_MACROS"))
    node->flags |= NODE_WARN;

  /* If user defines one of the conditional macros, remove the
     conditional flag */
  node->flags &= ~NODE_CONDITIONAL;

  return true;
}

