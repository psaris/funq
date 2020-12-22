# Fun Q

This project contains the source files for "Fun Q: A Functional
Introduction to Machine Learning in Q".[^fn1]

## The Book

**Fun Q** can be purchased on
[Amazon](https://www.amazon.com/dp/1734467509) and [Amazon
UK](https://www.amazon.co.uk/gp/product/1734467509). A [Kindle
version](https://www.amazon.com/dp/B08R5W95WF) is also available.
Books may be purchased in quantity and/or special sales by contacting
the publisher, [Vector Sigma](mailto:sales@vector-sigma.com).  Read a
[review](https://vector.org.uk/book-review-fun-q-a-functional-introduction-to-machine-learning-in-q/)
by [Daniel Krizian](https://www.linkedin.com/in/danielkrizian/)
published by [Vector](https://vector.org.uk/), the Journal of British
APL Association.


## The Source

Install `q` from Kx System's kdb+ download
[page](http://kx.com/software-download.php) and grab a copy of the
**Fun Q** source.

```sh
$ git clone https://github.com/psaris/funq
```

## The Fun Q Environment

The following command starts the q interpreter with all Fun Q
libraries loaded and 4 secondary threads for parallel computing.

```sh
$ q funq.q -s 4
```

## The Errors

Any typos or errors are listed [here](errata.adoc) and are
incorporated into recent printings of the book.

## The Swag

Swag can be found on the [Vector Sigma Teespring
site](https://teespring.com/stores/vectorsigma).

## More Fun

Start q with any of the following or read the comments and run the
examples one by one.

### Plotting

```sh
$ q plot.q -s 4
```

### K-Nearest Neighbors (KNN)

```sh
$ q knn.q -s 4
```

### K-Means/Medians/Medoids Clustering

```sh
$ q kmeans.q -s 4
```

### Hierarchical Agglomerative Clustering (HAC)

```sh
$ q hac.q -s 4
```

### Expectation Maximization (EM)

```sh
$ q em.q -s 4
```

### Naive Bayes

```sh
$ q nb.q -s 4
```

### Vector Space Model (tf-idf)

```sh
$ q tfidf.q -s 4
```

### Decision Tree (ID3,C4.5,CART)

```sh
$ q decisiontree.q -s 4
```

### Discrete Adaptive Boosting (AdaBoost)

```sh
$ q adaboost.q -s 4
```

### Random Forest (and Boosted Aggregating BAG)

```sh
$ q randomforest.q -s 4
```

### Linear Regression

```sh
$ q linreg.q -s 4
```

### Logistic Regression

```sh
$ q logreg.q -s 4
```

### One vs. All

```sh
$ q onevsall.q -s 4
```

### Neural Network Classification/Regression

```sh
$ q nn.q -s 4
```

### Content-Based/Collaborative Filtering (Recommender Systems)

```sh
$ q recommend.q -s 4
```

### Google PageRank

```sh
$ q pagerank.q -s 4
```

<!----- Footnotes ----->

[^fn1]: More presentations, competitions and books by Nick Psaris can be found at <https://nick.psaris.com>
