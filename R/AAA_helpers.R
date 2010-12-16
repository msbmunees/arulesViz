.get_parameters <- function(p, parameter) {
    if(!is.null(parameter) && length(parameter) != 0) {
	o <- pmatch(names(parameter), names(p))

	if(any(is.na(o)))
	    stop(sprintf(ngettext(length(is.na(o)),
				"Unknown option: %s",
				"Unknown options: %s"),
			paste(names(parameter)[is.na(o)],
				collapse = " ")))

	p[o] <- parameter
    }

    p
}


rulesAsDataFrame <- function(rules, measure = "support") {
    antes <- labels(lhs(rules))$elements
    conseqs <- labels(rhs(rules))$elements

    data.frame(
	    antecedent = ordered(antes, levels = unique(antes)),
	    consequent = ordered(conseqs, level = unique(conseqs)),
	    measure = quality(rules)[[measure]]
	    )
}

rulesAsMatrix <- function(rules, measure = "support") {
    df <- rulesAsDataFrame(rules, measure)

    antes <- as.integer(df$antecedent)
    conseqs <- as.integer(df$consequent)
    m <- matrix(NA,
	    ncol = length(unique(antes)), nrow = length(unique(conseqs)))
    dimnames(m) <- list(levels(df$consequent), levels(df$antecedent))

    enc <- m

    for (i in 1:nrow(df)) {
	m[conseqs[i], antes[i]] <- df$measure[i]
	enc[conseqs[i], antes[i]] <- i
    }

    attr(m, "encoding") <- enc
    m
}


rulesAStable <- function(rules, data) {
    tables <- list()
    for (i in 1:length(rules)) {
	tables[[i]] <- getTable(rules[i], data)
    }
    tables
}


getTable <- function(rule, data) {
    antecedent <- unlist(LIST(lhs(rule), decode = FALSE))
    consequent <- unlist(LIST(rhs(rule), decode = FALSE))
    transactions <- data[, c(antecedent, consequent)]
    ruleAsDataFrame <- as.data.frame(as(transactions, "matrix"))
    for (i in 1:ncol(ruleAsDataFrame)) {
	ruleAsDataFrame[[i]] <- factor(ruleAsDataFrame[[i]],
		levels = c(0, 1), labels = c("no", "yes"))
    }
    table(ruleAsDataFrame)
}



