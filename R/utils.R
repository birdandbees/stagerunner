## A handy little trick from Hadley: this will return the second argument
## if the first is `NULL`.
`%||%` <- function(x, y) if (is.null(x)) y else x

contains_true <- function(x) {
  if (is.list(x)) any(vapply(x, contains_true, logical(1)))
  else any(x)
}

all_logical <- function(x) {
  is.logical(x) || all(vapply(x,
    function(y) if (is.atomic(y)) is.logical(y) else all_logical(y),
  logical(1)))
}

## A helper function for printing stagerunner execution progress.
as.ordinal <- function(number) {
  ordinals <- list('first', 'second', 'third', 'fourth', 'fifth',
    'sixth', 'seventh', 'eighth', 'ninth', 'tenth', 'eleventh',
    'twelfth', 'thirteenth', 'fourteenth', 'fifteenth',
    'sixteenth', 'seventeenth', 'eighteenth', 'nineteenth',
    'twentieth')
  ext <- c("th", "st", "nd", "rd", rep("th", 6))
  ordinals[number][[1]] %||%
  paste0(number, ext[[(number %% 10) + 1]])
}

## Print some nice messages that tell you what type the stagerunner
## constructor expects.
enforce_type <- function(value, expected, klass, name = deparse(substitute(value))) {
  if (missing(value)) {
    stop(sprintf(
      "Please provide %s%s.",
      articleize(sQuote(crayon::red(name))),
      if (missing(klass)) "" else paste( " to a", klass)
    ))
  }

  check <- utils::getFromNamespace(paste0("is.", expected), "base")
  if (!check(value)) {
    stop(sprintf(
      "Please pass %s as the %s%s; instead I got a %s.",
      articleize(sQuote(crayon::yellow(expected))), dQuote(name),
      if (missing(klass)) "" else paste(" for a", klass),
      crayon::red(sclass(value))
    ))
  }
}

sclass <- function(obj) { class(obj)[1L] }

articleize <- function(word) {
  sprintf("a%s %s", if (is_vowel(first_letter(word))) "n" else "", word)
}

is_vowel <- function(char) {
  is.element(char, c("a", "e", "i", "o", "u", "A", "E", "I", "O", "U"))
}

first_letter <- function(word) {
  substring(gsub("[^a-zA-Z]|\\[3[0-9]m", "", word), 1, 1)
}

# Whether obj is of any of the given types.
is_any <- function(obj, klasses) {
  any(vapply(klasses, inherits, logical(1), x = obj))
}

package_function <- function(pkg, fn) { # for when using :: breaks R CMD check
  get(fn, envir = getNamespace(pkg))
}

## Used in conjunction with `treeSkeleton` so that it works for S3, S4, RC,
## and R6 classes.
#' Call a method on an object regardless of its OOP type.
#'
#' @name OOP_type_independent_method 
#' @param object any. An R object of variable OOP type (S3, S4, RC, R6).
#' @param method character. The method to call on the \code{object}. If the
#'    latter is a reference class, it use the \code{$} operator to access the method.
#'    (For example, \code{object$some_method}). If it has an attribute with the name
#'    \code{method}, it will use that attribute as the method to call. Otherwise,
#'    it will try to fetch a generic with the name \code{method} using \code{get}.
OOP_type_independent_method <- function(object, method) {
  if (method %in% names(attributes(object))) {
    attr(object, method)
  } else if (is.environment(object) && method %in% ls(object)) {
    object[[method]]()
  } else {
    get(method)(object)
  }
}

## [Convert an environment to a list recursively.](http://stackoverflow.com/questions/22675046/transforming-a-nested-environment-into-a-nested-list/22675108#22675108)
as.list.environment <- function(env) {
  out <- base::as.list.environment(env)
  lapply(out, function(x) if (is.environment(x)) as.list(x) else x)
}

