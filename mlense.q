mlense.f:("ml-latest";"ml-latest-small") 1 / pick the smaller dataset
mlense.b:"http://files.grouplens.org/datasets/movielens/" / base url
-1"downloading latest grouplens movie lense dataset";
.util.download[mlense.b;;".zip";system 0N!"unzip -n ",] mlense.f;
-1"loading movie definitions: integer movieIds and enumerated genres";
mlense.movie:("I**";1#",") 0:`$mlense.f,"/movies.csv"
-1"remove movies without genres";
mlense.movie:update 0#'genres from mlense.movie where genres like "(no genres listed)"
-1"extract the movie's year from title";
mlense.movie:update rtrim title from mlense.movie
mlense.movie:update year:"I"$-1_/:-5#/:title,-7_/:title from mlense.movie where title like "*(????)"
-1"enumerate genres, fixed width titles";
mlense.movie:1!update `u#movieId,25$'title,`genre?/:`$("|"vs'genres) from mlense.movie
-1"add the decade as a genre";
mlense.movie:update genres:(genres,'`$string 10 xbar year) from mlense.movie
-1"loading movie ratings: partitioned by userId and movieId linked to movie table";
mlense.rating:update `p#userId,`mlense.movie$movieId from ("IIF";1#",") 0:`$mlense.f,"/ratings.csv"

