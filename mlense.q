mlense.f:("ml-latest";"ml-latest-small") 1 / pick the smaller dataset
mlense.b:"http://files.grouplens.org/datasets/movielens/" / base url
-1"[down]loading latest movielens data set";
.util.download[mlense.b;;".zip";.util.unzip] mlense.f;
-1"loading movie definitions: integer movieIds and enumerated genres";
mlense.movie:1!("I**";1#",") 0: `$mlense.f,"/movies.csv"
-1"removing movies without genres";
update 0#'genres from `mlense.movie where genres like "(no genres listed)";
-1"converting unicode in titles to ascii";
update .util.cleanstr each rtrim title from `mlense.movie;
-1"extracting the movie's year from the title";
update year:"I"$-1_/:-5#/:title from `mlense.movie;
update -7_/:title from `mlense.movie where not null year;
-1"adding `u on movieId and splitting genres";
update `u#movieId,`$"|"vs'genres from `mlense.movie
-1"adding the decade as a genre";
update genres:(genres,'`$string 10 xbar year) from `mlense.movie
-1"enumerating genres";
mlense.movie:update `genre?/:genres from mlense.movie
-1"loading movie ratings";
mlense.rating:("IIFP";1#",") 0:`$mlense.f,"/ratings.csv"
-1"adding `p on userId and linking movieId to movie table";
update `p#userId,`mlense.movie$movieId from `mlense.rating;
