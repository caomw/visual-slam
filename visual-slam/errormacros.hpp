/*
 * STRINGIZE macro converts an expression into a string-literal.
 * ERROR_INFO macro permits file-name and line-number data to be added to an error message.
 *
 * Tim Bailey 2005.
 * Modified 2015.
 */

#ifndef ERROR_MACROS_HPP_
#define ERROR_MACROS_HPP_

#if defined(STRINGIZE_HELPER) || defined(STRINGIZE) || defined(ERROR_INFO)
#   error Error macros have already been defined elsewhere 
#endif

#define STRINGIZE_HELPER(exp) #exp
#define STRINGIZE(exp) STRINGIZE_HELPER(exp)

#define ERROR_INFO(message) "ERROR: " message \
	"\nFILE: " __FILE__ "\nLINE: " STRINGIZE(__LINE__)

#define ASSERTION_MAX_COST 1
#define ASSERTION(expr, cost) if (cost <= ASSERTION_MAX_COST) assert(expr)


#endif
