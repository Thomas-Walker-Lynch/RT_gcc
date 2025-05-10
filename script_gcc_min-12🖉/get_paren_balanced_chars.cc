bool
cpp_get_paren_balanced_chars(cpp_reader *pfile)
{
  const unsigned char *cur = pfile->buffer->cur;
  const unsigned char *rlimit = pfile->buffer->rlimit;
  cpp_buffer *buffer = pfile->buffer;

  // Skip leading whitespace
  while (cur < rlimit && ISSPACE(*cur))
    cur++;

  if (cur == rlimit || *cur != '(')
    {
      cpp_error(pfile, CPP_DL_ERROR, "expected opening parenthesis for macro body");
      return false;
    }

  int depth = 0;
  const unsigned char *scan = cur;
  while (scan < rlimit)
    {
      if (*scan == '(')
        depth++;
      else if (*scan == ')')
        {
          depth--;
          if (depth == 0)
            {
              // Copy from opening ( to matching ) inclusive
              size_t len = scan - cur + 1;
              unsigned char *copy = (unsigned char *)_cpp_unaligned_alloc(pfile, len + 1);
              memcpy(copy, cur, len);
              copy[len] = '\0';

              // Point lexer buffer to just this region
              buffer->cur = copy;
              buffer->rlimit = copy + len;
              buffer->next_line = NULL; // Signals EOF to lexer
              return true;
            }
        }
      scan++;
    }

  // If we got here, closing paren was never found
  cpp_error(pfile, CPP_DL_ERROR, "unclosed parenthesis in macro body");
  return false;
}
