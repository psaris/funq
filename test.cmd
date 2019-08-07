set SSL_VERIFY_SERVER=NO

set files=testporter.q plot.q knn.q kmeans.q em.q pagerank.q sparse.q
set files=%files%;decisiontree.q randomforest.q markov.q hac.q cossim.q
set files=%files%;adaboost.q linreg.q logreg.q recommend.q nn.q onevsall.q 
set files=%files%;nb.q tfidf.q silhouette.q

FOR %%A IN (%files%) DO q %%A -s 4 > nul < nul
