workshop_sesh <- new.env(parent = emptyenv())
# Will default to using the default cache when first referenced
env_bind_lazy(workshop_sesh, cache = get_cache("workshop_cache.yaml"))

set_default_cache <- function(cache) {
  workshop_sesh$cache <- cache
}

default_cache <- function() {
  workshop_sesh$cache
}

#' @importFrom rlang env_bind_lazy
#' @importFrom fs file_create file_exists
#' @importFrom yaml read_yaml write_yaml
#' @export
get_cache <- function(path) {
  cat("Loading cache:", path, "\n")
  dir_create(path_dir(path))
  if (!file_exists(path)) {
    write_yaml(list(cache_version = "0.01", targets = list()), path)
  }
  return(structure(list(path = path), class="workshop_cache"))
}

#' @export
as.character.workshop_cache <- function(x, ...) {
  return(str_c("<workshop cache with path: ", x$path, ">\n", ...))
}

# TODO: error if cache permissions issue?
read_target_cache <- function(target, cache = default_cache()) {
  read_yaml(cache$path)$targets[[target]]
}

# TODO: remove spec_partial extension before reading?
read_matching_targets_cache <- function(spec_partial, cache = default_cache()) {
  targets <- read_yaml(cache$path)$targets
  targets[spec_match(names(targets), spec_partial)]
}

upsert_target_cache <- function(target, val, cache = default_cache()) {
  data <- read_yaml(cache$path)
  data$targets[[target]] <- val
  write_yaml(data, cache$path)
}
