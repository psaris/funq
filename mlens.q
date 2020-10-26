mlens.f:("ml-latest";"ml-latest-small") 1 / pick the smaller dataset
mlens.b:"http://files.grouplens.org/datasets/movielens/" / base url
-1"[down]loading latest movielens data set";
.ut.download[mlens.b;;".zip";.ut.unzip] mlens.f;
-1"loading movie definitions: integer movieIds and enumerated genres";
mlens.movie:1!("I**";1#",") 0: `$mlens.f,"/movies.csv"
-1"removing movies without genres";
update 0#'genres from `mlens.movie where genres like "(no genres listed)";
-1"converting unicode in titles to ascii";
update .ut.sr[.ut.ua] peach rtrim title from `mlens.movie;
-1"extracting the movie's year from the title";
update year:"I"$-1_/:-5#/:title from `mlens.movie;
update -7_/:title from `mlens.movie where not null year;
-1"adding `u on movieId and splitting genres";
update `u#movieId,`$"|"vs'genres from `mlens.movie;
-1"adding the decade as a genre";
update genres:(genres,'`$string 10 xbar year) from `mlens.movie;
-1"enumerating genres";
mlens.movie:update `genre?/:genres from mlens.movie
-1"loading movie ratings";
mlens.rating:("IIFP";1#",") 0:`$mlens.f,"/ratings.csv"
-1"adding `p on userId and linking movieId to movie table";
update `p#userId,`mlens.movie$movieId from `mlens.rating;
