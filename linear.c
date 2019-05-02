#include <stddef.h>
#include <stdlib.h>

#include <string.h>
#include <linear.h>

#include "stdio.h"
#include "k.h"

#define D(x) {if(!(x))goto done;}

ZS print_string_function = "2";

ZV
print_string_q(const char *s)
{
    K r;

    if ((r = k(0,print_string_function,kp((S)s),(K)0))) {
        if (r->t == -128)
            O("%s",r->s), O("\n");
        r0(r);
    }
}

ZV
destroy_prob(struct problem* prob) {
    DO(prob->l, free(prob->x[i]));
    free(prob->x);
    free(prob->y);
}

ZK
find(K dict, S key) {
    K k,v;
    I i;

    P(dict->t != XD, krr("type"));

    k = kK(dict)[0];
    v = kK(dict)[1];

    P(k->t != KS || v->t != 0, krr("type"));
    for (i = 0; i < k->n; ++i)
        if (!strcmp(kS(k)[i],key))
            R kK(v)[i];
    R krr(key);
}

ZK
findt(K dict, S key, I type) {
    K x;
    U(x = find(dict, key));
    P(xt != type, krr("type"));
    R x;
}


ZK
vec_to_k_s(const char **s, size_t n) {
    K x = ktn(KS,n);
    DO(n,xS[i]=ss((S)s[i]));
    R x;
}

ZK
nodes_to_k(struct feature_node ** const node, I l, F bias) {
    I j,k;
    K idx, val, x = ktn(0,l);
    for (j = 0; j < l; ++j) {
        for (k = 0; node[j][k].index != -1; ++k); /* find sentinel */
        if (bias >= 0) k-=1;                      /* exclude bias term */
        idx = ktn(KI,k); DO(k,kI(idx)[i] = node[j][i].index);
        val = ktn(KF,k); DO(k,kF(val)[i] = node[j][i].value);
        xK[j] = xD(idx,val);
    }
    R x;
}

ZI
k_to_node_dict(const K x, struct feature_node ** node, I n, F bias) {
    K idx, val;
    I m;

    P(xt != XD, (krr("type"),0));
    idx = xK[0];
    val = xK[1];
    P(idx->t != KI || val->t != KF, (krr("type"),0));
    m = idx->n;
    if (bias >= 0) m += 1;
    (*node) = (struct feature_node*)malloc((1+m)*sizeof(struct feature_node));
    DO(idx->n,((*node)[i].index = kI(idx)[i], (*node)[i].value = kF(val)[i]));
    if (bias >= 0) (*node)[idx->n].index = n, (*node)[idx->n].value = bias;
    (*node)[m].index = -1; /* sentinel */
    R m;
}

ZI
k_to_node_mat(const K x, struct feature_node *** node, I l, I n, F bias) {

    P(xt != 0, (krr("type"),0));

    if (*node) DO(l,free((*node)[i]));
    (*node) = (struct feature_node**)realloc((*node),xn*sizeof(struct feature_node*));
    memset(*node, 0, xn*sizeof(struct feature_node*)); /* 0 init  */
    DO(xn, U(k_to_node_dict(xK[i], &(*node)[i], n, bias)));
    R xn;
}

ZK
vec_to_k_f(F* v, I n) {
    K r;
    if (v)
        memcpy(kF(r=ktn(KF,n)),v,n*sizeof(F));
    else
        r=ktj(101,0);           /* (::) */
    R r;
}

ZK
vec_to_k_i(I* v, I n) {
    K r;
    if (v)
        memcpy(kI(r=ktn(KI,n)),v,n*sizeof(I));
    else
        r=ktj(101,0);           /* (::) */
    R r;
}

ZV
k_to_vec_i(I** v, const K x) {
    if (xt == KI)
        (*v) = (I*)memcpy(realloc(*v,xn*sizeof(I)),xI,xn*sizeof(I));
    else if (*v)
        free(*v), (*v) = 0;
}

ZV
k_to_vec_f(F** v, const K x) {
    if (xt == KF)
        (*v) = (F*)memcpy(realloc(*v,xn*sizeof(F)),xF,xn*sizeof(F));
    else if (*v)
        free(*v), (*v) = 0;
}

ZK
problem_to_k(const struct problem *p) {
    static const char* h[] = {"bias", "x", "y"};
    static const size_t n = sizeof(h)/sizeof(h[0]);
    K x = knk(n,kf(p->bias),nodes_to_k(p->x,p->l,p->bias),vec_to_k_f(p->y,p->l));
    R xD(vec_to_k_s(h,n),x);
}

ZI
max_key(const K x) {
  K k,d;
  I n,m = 0;

  P(xt != 0, (krr("type"),0));
  for (I i=0; i < xn; ++i) {
    d = xK[i];
    P( d->t != XD, (krr("type"),0));
    k = kK(d)[0];
    P( k->t != KI, (krr("type"),0));
    n = kI(k)[k->n - 1];
    if (m < n)
      m = n;
  }
  R n;
}

ZI
k_to_problem(const K d, struct problem *p) {
    K x;

    U(x = findt(d,"bias",-KF)); p->bias = xf;
    U(x = findt(d, "x", 0));    U(p->n = max_key(x));
    U(k_to_node_mat(x, &p->x, p->l, p->n, p->bias)); /* old l */
    if (p->bias >= 0) p->n += 1;
    U(x = findt(d, "y", KF));   k_to_vec_f(&p->y,x), p->l = x->n; /* new l */
    R 1;
}

ZK
parameter_to_k(const struct parameter *p) {
    static const char* h[] = {"solver_type", "eps", "C", "weight_label", "weight",
                              "p","init_sol"};
    static const size_t n = sizeof(h)/sizeof(h[0]);
    K x = ktn(0,n);
    xK[0] = ki(p->solver_type);
    xK[1] = kf(p->eps);
    xK[2] = kf(p->C);
    xK[3] = vec_to_k_i(p->weight_label,p->nr_weight);
    xK[4] = vec_to_k_f(p->weight,p->nr_weight);
    xK[5] = kf(p->p);
    xK[6] = vec_to_k_f(p->init_sol,p->nr_weight);
    R xD(vec_to_k_s(h,n),x);
}

ZI
k_to_parameter(const K d, struct parameter *p) {
    K x;
    U(x = findt(d, "solver_type", -KI)); p->solver_type = xi;
    U(x = findt(d, "eps", -KF));         p->eps = xf;
    U(x = findt(d, "C", -KF));           p->C = xf;

    U(x = find(d, "weight_label"));
    if (xt == KI) {
        p->nr_weight = xn;
        k_to_vec_i(&p->weight_label,x);
        U(x = findt(d, "weight", KF));
        P(xn != p->nr_weight, (krr("length"),0));
        k_to_vec_f(&p->weight,x);
    } else {
        p->nr_weight = 0;
        p->weight_label = NULL;
        p->weight = NULL;
    }
    U(x = findt(d, "p", -KF));           p->p = xf;
    U(x = find(d, "init_sol"));
    if (xt == KF)
      P(xn != p->nr_weight, (krr("length"),0));
    k_to_vec_f(&p->init_sol,x);
    R 1;
}

ZK
model_to_k(const struct model *m) {
  static const char* h[] = {"param", "nr_class", "nr_feature", "w",
                            "label", "bias"};
    static const size_t n = sizeof(h)/sizeof(h[0]);
    I k, l, nw;
    K x = ktn(0,n);
    xK[0] = parameter_to_k(&m->param);
    xK[1] = ki(k = m->nr_class);
    xK[2] = ki(l = m->nr_feature);
    nw = (m->nr_class == 2 && m->param.solver_type != MCSVM_CS) ? 1 : m->nr_class;
    xK[3] = vec_to_k_f(m->w,nw*l);
    xK[4] = vec_to_k_i(m->label,k);
    xK[5] = kf(m->bias);
    R xD(vec_to_k_s(h,n),x);
}

ZI
k_to_model(const K d, struct model *m) {
    K x;
    I nw;
    U(x = findt(d,"nr_class",-KI)); m->nr_class = xi;
    U(x = findt(d,"nr_feature",-KI)); m->nr_feature = xi;
    U(x = findt(d,"param",XD));     U(k_to_parameter(x,&m->param));
    U(x = findt(d,"w",KF));         k_to_vec_f(&m->w,x);
    nw = (m->nr_class == 2 && m->param.solver_type != MCSVM_CS) ? 1 : m->nr_class;
    P(xn != nw*m->nr_feature,(krr("length"),0));
    U(x = find(d,"label"));         k_to_vec_i(&m->label,x);
    P(xn != m->nr_class,(krr("length"),0));
    U(x = findt(d,"bias",-KF));     m->bias = xf;
    R 1;
}

K
linear_check_parameter(K kprob, K kparam) {
    struct problem prob;
    struct parameter param;
    K r = 0;

    memset(&prob, 0, sizeof(struct problem));
    memset(&param, 0, sizeof(struct parameter));

    D(k_to_problem(kprob, &prob));
    D(k_to_parameter(kparam, &param));
    r = krr((S)check_parameter(&prob,&param));
 done:
    destroy_prob(&prob);
    destroy_param(&param);
    R r;
}

K
linear_train(K kprob, K kparam) {
    struct problem prob;
    struct parameter param;
    struct model *model = 0;
    K kmodel = 0;

    memset(&prob, 0, sizeof(struct problem));
    memset(&param, 0, sizeof(struct parameter));

    D(k_to_problem(kprob, &prob));
    D(k_to_parameter(kparam, &param));
    model = train(&prob,&param);
    kmodel = model_to_k(model);
 done:
    free_and_destroy_model(&model);
    destroy_prob(&prob);
    destroy_param(&param);
    R kmodel;
}

K
linear_cross_validation(K kprob, K kparam, K nr_fold) {
    struct problem prob;
    struct parameter param;
    K target = 0;

    P(nr_fold->t != -KI, krr("type"));

    memset(&prob, 0, sizeof(struct problem));
    memset(&param, 0, sizeof(struct parameter));

    D(k_to_problem(kprob, &prob));
    D(k_to_parameter(kparam, &param));
    target = ktn(KF,prob.l);
    cross_validation(&prob, &param, nr_fold->i, kF(target));
 done:
    destroy_prob(&prob);
    destroy_param(&param);
    R target;
}

K
linear_find_parameters(K kprob, K kparam, K nr_fold, K start_C, K start_p) {
    struct problem prob;
    struct parameter param;
    K r = 0;

    P(nr_fold->t != -KI || start_C->t != -KF || start_p->t != -KF, krr("type"));

    memset(&prob, 0, sizeof(struct problem));
    memset(&param, 0, sizeof(struct parameter));

    D(k_to_problem(kprob, &prob));
    D(k_to_parameter(kparam, &param));
    r = ktn(KF,3); memset(kF(r),0,3*sizeof(double));
    find_parameters(&prob, &param, nr_fold->i, start_C->f, start_p->f,
                    &kF(r)[0], &kF(r)[1], &kF(r)[2]);
 done:
    destroy_prob(&prob);
    destroy_param(&param);
    R r;
}

K
linear_load_model(K file) {
    struct model *model;
    K r;

    P(file->t != -KS, krr("type"));
    P(!(model = load_model((':' == *file->s) + file->s)),krr("file"));
    r = model_to_k(model);
    free_and_destroy_model(&model);
    R r;
}

K
linear_save_model(K file, K kmodel) {
    struct model model;
    K r = 0;
    P(file->t != -KS, krr("type"));

    memset(&model, 0, sizeof(struct model));
    D(k_to_model(kmodel, &model));
    r = ki(save_model((':' == *file->s) + file->s, &model));
 done:
    free_model_content(&model);
    R r;
}

K
linear_check_probability_model(K kmodel) {
    struct model model;
    K r = 0;

    memset(&model, 0, sizeof(struct model));
    D(k_to_model(kmodel,&model));
    r = ki(check_probability_model(&model));
 done:
    free_model_content(&model);
    R r;
}

K
linear_predict(K kmodel, K knodes) {
    struct model model;
    struct feature_node *nodes = 0;
    K r = 0;
    I i;

    memset(&model, 0, sizeof(struct model));
    D(k_to_model(kmodel,&model));
    if (knodes->t) {
        D(k_to_node_dict(knodes, &nodes, model.nr_feature, model.bias));
        r = kf(predict(&model,nodes));
    } else {
        r = ktn(KF,knodes->n);
        for (i = 0;i < knodes->n;++i) {
            D(k_to_node_dict(kK(knodes)[i], &nodes, model.nr_feature, model.bias));
            kF(r)[i] = predict(&model,nodes);
        }
    }
 done:
    free_model_content(&model);
    free(nodes);
    R r;
}

K
linear_predict_values(K kmodel, K knodes) {
    struct model model;
    struct feature_node *nodes = 0;
    K r = 0, dec_values = 0;
    I i;

    memset(&model, 0, sizeof(struct model));
    D(k_to_model(kmodel,&model));
    if (knodes->t) {
        D(k_to_node_dict(knodes, &nodes, model.nr_feature, model.bias));
        dec_values = ktn(KF,model.nr_class*(model.nr_class-1)/2);
        r = knk(2,kf(predict_values(&model,nodes,kF(dec_values))),dec_values);
    } else {
        r = knk(2,ktn(KF,knodes->n),ktn(0,knodes->n));
        for (i = 0;i < knodes->n;++i) {
            D(k_to_node_dict(kK(knodes)[i], &nodes, model.nr_feature, model.bias));
            dec_values = ktn(KF,model.nr_class*(model.nr_class-1)/2);
            kF(kK(r)[0])[i] = predict_values(&model,nodes,kF(dec_values));
            kK(kK(r)[1])[i] = dec_values;
        }
    }
 done:
    free_model_content(&model);
    free(nodes);
    R r;
}

K
linear_predict_probability(K kmodel, K knodes) {
    struct model model;
    struct feature_node *nodes = 0;
    K r = 0, prob = 0;
    I i;

    memset(&model, 0, sizeof(struct model));
    D(k_to_model(kmodel,&model));
    if (knodes->t) {
        D(k_to_node_dict(knodes, &nodes, model.nr_feature, model.bias));
        prob = ktn(KF,model.nr_class);
        memset(kF(prob), 0, prob->n*sizeof(F));
        r = knk(2,kf(predict_probability(&model,nodes,kF(prob))),prob);
    } else {
        r = knk(2,ktn(KF,knodes->n),ktn(0,knodes->n));
        for (i = 0;i < knodes->n; ++i) {
            D(k_to_node_dict(kK(knodes)[i], &nodes, model.nr_feature, model.bias));
            prob = ktn(KF,model.nr_class);
            memset(kF(prob), 0, prob->n*sizeof(F));
            kF(kK(r)[0])[i] = predict_probability(&model,nodes,kF(prob));
            kK(kK(r)[1])[i] = prob;
        }
    }
 done:
    free_model_content(&model);
    free(nodes);
    R r;
}

K
linear_prob_inout(K kprob) {
    struct problem prob;

    memset(&prob, 0, sizeof(struct problem));
    U(k_to_problem(kprob,&prob));
    kprob = problem_to_k(&prob);
    destroy_prob(&prob);
    R kprob;
}

K
linear_param_inout(K kparam) {
    struct parameter param;

    memset(&param, 0, sizeof(struct parameter));
    U(k_to_parameter(kparam,&param));
    kparam = parameter_to_k(&param);
    destroy_param(&param);
    R kparam;
}

K
linear_model_inout(K kmodel) {
    struct model model;

    memset(&model, 0, sizeof(struct model));
    U(k_to_model(kmodel,&model));
    kmodel = model_to_k(&model);
    free_model_content(&model);
    R kmodel;
}

K
linear_set_print_string_function(K x) {
    P(xt != -KS, krr("type"));

    print_string_function = xs;
    R 0;
}

K
lib(K x) {
    K y;

    set_print_string_function(print_string_q);

    x=ktn(KS,0);
    y=ktn(0,0);

    js(&x,ss("version")),                 jk(&y,ki(liblinear_version));
    js(&x,ss("check_parameter")),         jk(&y,dl(linear_check_parameter,2));
    js(&x,ss("train")),                   jk(&y,dl(linear_train,2));
    js(&x,ss("cross_validation")),        jk(&y,dl(linear_cross_validation,3));
    js(&x,ss("find_parameters")),         jk(&y,dl(linear_find_parameters,5));
    js(&x,ss("load_model")),              jk(&y,dl(linear_load_model,1));
    js(&x,ss("save_model")),              jk(&y,dl(linear_save_model,2));
    js(&x,ss("check_probability_model")), jk(&y,dl(linear_check_probability_model,1));
    js(&x,ss("predict")),                 jk(&y,dl(linear_predict,2));
    js(&x,ss("predict_values")),          jk(&y,dl(linear_predict_values,2));
    js(&x,ss("predict_probability")),     jk(&y,dl(linear_predict_probability,2));
    js(&x,ss("prob_inout")),              jk(&y,dl(linear_prob_inout,1));
    js(&x,ss("param_inout")),             jk(&y,dl(linear_param_inout,1));
    js(&x,ss("model_inout")),             jk(&y,dl(linear_model_inout,1));
    js(&x,ss("set_print_string_function")), jk(&y,dl(linear_set_print_string_function,1));
    R xD(x,y);
}
