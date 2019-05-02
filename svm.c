#include <stddef.h>
#include <stdlib.h>

#include <string.h>
#include <svm.h>

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
destroy_prob(struct svm_problem* prob) {
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
nodes_to_k(struct svm_node ** const node, I l) {
    I j,k;
    K idx, val, x = ktn(0,l);
    for (j = 0; j < l; ++j) {
        for (k = 0; node[j][k].index != -1; ++k); /* find sentinel */
        idx = ktn(KI,k); DO(k,kI(idx)[i] = node[j][i].index);
        val = ktn(KF,k); DO(k,kF(val)[i] = node[j][i].value);
        xK[j] = xD(idx,val);
    }
    R x;
}

ZI
k_to_node_dict(const K x, struct svm_node ** node) {
    K idx, val;

    P(xt != XD, (krr("type"),0));
    idx = xK[0];
    val = xK[1];
    P(idx->t != KI || val->t != KF, (krr("type"),0));
    (*node) = (struct svm_node*)malloc((1+idx->n)*sizeof(struct svm_node));
    DO(idx->n,((*node)[i].index = kI(idx)[i], (*node)[i].value = kF(val)[i]));
    (*node)[idx->n].index = -1;    /* sentinel */
    R idx->n;
}

ZI
k_to_node_mat(const K x, struct svm_node *** node, I l) {

    P(xt != 0, (krr("type"),0));

    if (*node) DO(l,free((*node)[i]));
    (*node) = (struct svm_node**)realloc((*node),xn*sizeof(struct svm_node*));
    memset(*node, 0, xn*sizeof(struct svm_node*)); /* 0 init  */
    DO(xn, U(k_to_node_dict(xK[i], &(*node)[i])));
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
problem_to_k(const struct svm_problem *p) {
    static const char* h[] = {"x", "y"};
    static const size_t n = sizeof(h)/sizeof(h[0]);
    K x = knk(2,nodes_to_k(p->x,p->l),vec_to_k_f(p->y,p->l));
    R xD(vec_to_k_s(h,n),x);
}

ZI
k_to_problem(const K d, struct svm_problem *p) {
    K x;

    U(x = findt(d, "x", 0));  U(k_to_node_mat(x, &p->x, p->l)); /* old l */
    U(x = findt(d, "y", KF)); k_to_vec_f(&p->y,x), p->l = x->n; /* new l */
    R 1;
}

ZK
parameter_to_k(const struct svm_parameter *p) {
    static const char* h[] = {"svm_type", "kernel_type", "degree", "gamma", "coef0",
                              "cache_size", "eps", "C", "weight_label", "weight",
                              "nu", "p", "shrinking", "probability"};
    static const size_t n = sizeof(h)/sizeof(h[0]);
    K x = ktn(0,n);
    xK[0] = ki(p->svm_type);
    xK[1] = ki(p->kernel_type);
    xK[2] = ki(p->degree);
    xK[3] = kf(p->gamma);
    xK[4] = kf(p->coef0);
    xK[5] = kf(p->cache_size);
    xK[6] = kf(p->eps);
    xK[7] = kf(p->C);
    xK[8] = vec_to_k_i(p->weight_label,p->nr_weight);
    xK[9] = vec_to_k_f(p->weight,p->nr_weight);
    xK[10] = kf(p->nu);
    xK[11] = kf(p->p);
    xK[12] = ki(p->shrinking);
    xK[13] = ki(p->probability);
    R xD(vec_to_k_s(h,n),x);
}

ZI
k_to_parameter(const K d, struct svm_parameter *p) {
    K x;
    U(x = findt(d, "svm_type", -KI));    p->svm_type = xi;
    U(x = findt(d, "kernel_type", -KI)); p->kernel_type = xi;
    U(x = findt(d, "degree", -KI));      p->degree = xi;
    U(x = findt(d, "gamma", -KF));       p->gamma = xf;
    U(x = findt(d, "coef0", -KF));       p->coef0 = xf;
    U(x = findt(d, "cache_size", -KF));  p->cache_size = xf;
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
    U(x = findt(d, "nu", -KF));          p->nu = xf;
    U(x = findt(d, "p", -KF));           p->p = xf;
    U(x = findt(d, "shrinking", -KI));   p->shrinking = xi;
    U(x = findt(d, "probability", -KI)); p->probability = xi;
    R 1;
}

ZK
model_to_k(const struct svm_model *m) {
    static const char* h[] = {"param", "nr_class", "total_sv", "SV",
                              "sv_coef", "rho", "probA", "probB",
                              "sv_indices", "label", "nSV"};
    static const size_t n = sizeof(h)/sizeof(h[0]);
    I k, l;
    K x = ktn(0,n);
    xK[0] = parameter_to_k(&m->param);
    xK[1] = ki(k = m->nr_class);
    xK[2] = ki(l = m->l);
    xK[3] = nodes_to_k(m->SV,l);
    xK[4] = ktn(0,k-1);
    DO(xK[4]->n,(kK(xK[4])[i]=vec_to_k_f(m->sv_coef[i],l)));
    xK[5] = vec_to_k_f(m->rho,k*(k-1)/2);
    xK[6] = vec_to_k_f(m->probA,k*(k-1)/2);
    xK[7] = vec_to_k_f(m->probB,k*(k-1)/2);
    xK[8] = vec_to_k_i(m->sv_indices,l-1);
    xK[9] = vec_to_k_i(m->label,k);
    xK[10] = vec_to_k_i(m->nSV,k);
    xK[11] = ki(m->free_sv);
    R xD(vec_to_k_s(h,n),x);
}

ZI
k_to_model(const K d, struct svm_model *m) {
    K x;
    U(x = findt(d,"sv_coef",0));
    DO(xn,P(xK[i]->t != KF,(krr("type"),0)));
    DO(m->nr_class,free(m->sv_coef[i])); /* old nr_class */
    free(m->sv_coef), m->sv_coef = (F**)calloc(xn,sizeof(F*));
    DO(xn,k_to_vec_f(&m->sv_coef[i],xK[i]));
    U(x = findt(d,"nr_class",-KI)); m->nr_class = xi; /* new nr_class */
    U(x = findt(d,"SV",0));         U(k_to_node_mat(x, &m->SV, m->l)); /* old l */
    U(x = findt(d,"total_sv",-KI)); m->l = xi; /* new l */
    U(x = findt(d,"param",XD));     U(k_to_parameter(x,&m->param));
    U(x = findt(d,"rho",KF));       k_to_vec_f(&m->rho,x);
    U(x = find(d,"probA"));         k_to_vec_f(&m->probA,x);
    U(x = find(d,"probB"));         k_to_vec_f(&m->probB,x);
    U(x = find(d,"sv_indices"));    k_to_vec_i(&m->sv_indices,x);
    U(x = findt(d,"label",KI));     k_to_vec_i(&m->label,x);
    U(x = findt(d,"nSV",KI));       k_to_vec_i(&m->nSV,x);
    R 1;
}

K
check_parameter(K kprob, K kparam) {
    struct svm_problem prob;
    struct svm_parameter param;
    K r = 0;

    memset(&prob, 0, sizeof(struct svm_problem));
    memset(&param, 0, sizeof(struct svm_parameter));

    D(k_to_problem(kprob, &prob));
    D(k_to_parameter(kparam, &param));
    r = krr((S)svm_check_parameter(&prob,&param));
 done:
    destroy_prob(&prob);
    svm_destroy_param(&param);
    R r;
}

K
train(K kprob, K kparam) {
    struct svm_problem prob;
    struct svm_parameter param;
    struct svm_model *model = 0;
    K kmodel = 0;

    memset(&prob, 0, sizeof(struct svm_problem));
    memset(&param, 0, sizeof(struct svm_parameter));

    D(k_to_problem(kprob, &prob));
    D(k_to_parameter(kparam, &param));
    model = svm_train(&prob,&param);
    kmodel = model_to_k(model);
 done:
    svm_free_and_destroy_model(&model);
    destroy_prob(&prob);
    svm_destroy_param(&param);
    R kmodel;
}

K
cross_validation(K kprob, K kparam, K nr_fold) {
    struct svm_problem prob;
    struct svm_parameter param;
    K target = 0;

    P(nr_fold->t != -KI, krr("type"));

    memset(&prob, 0, sizeof(struct svm_problem));
    memset(&param, 0, sizeof(struct svm_parameter));

    D(k_to_problem(kprob, &prob));
    D(k_to_parameter(kparam, &param));
    target = ktn(KF,prob.l);
    svm_cross_validation(&prob, &param, nr_fold->i, kF(target));
 done:
    destroy_prob(&prob);
    svm_destroy_param(&param);
    R target;
}

K
load_model(K file) {
    struct svm_model *model;
    K r;

    P(file->t != -KS, krr("type"));
    P(!(model = svm_load_model((':' == *file->s) + file->s)),krr("file"));
    r = model_to_k(model);
    svm_free_and_destroy_model(&model);
    R r;
}

K
save_model(K file, K kmodel) {
    struct svm_model model;
    K r = 0;

    P(file->t != -KS, krr("type"));

    memset(&model, 0, sizeof(struct svm_model)), model.free_sv = 1;
    D(k_to_model(kmodel, &model));
    r = ki(svm_save_model((':' == *file->s) + file->s, &model));
 done:
    svm_free_model_content(&model);
    R r;
}

K
check_probability_model(K kmodel) {
    struct svm_model model;
    K r = 0;

    memset(&model, 0, sizeof(struct svm_model)), model.free_sv = 1;
    D(k_to_model(kmodel,&model));
    r = ki(svm_check_probability_model(&model));
 done:
    svm_free_model_content(&model);
    R r;
}

K
predict(K kmodel, K knodes) {
    struct svm_model model;
    struct svm_node *nodes = 0;
    K r = 0;
    I i;

    memset(&model, 0, sizeof(struct svm_model)), model.free_sv = 1;
    D(k_to_model(kmodel,&model));
    if (knodes->t) {
        D(k_to_node_dict(knodes, &nodes));
        r = kf(svm_predict(&model,nodes));
    } else {
        r = ktn(KF,knodes->n);
        for (i = 0;i < knodes->n;++i) {
            D(k_to_node_dict(kK(knodes)[i], &nodes));
            kF(r)[i] = svm_predict(&model,nodes);
        }
    }
 done:
    svm_free_model_content(&model);
    free(nodes);
    R r;
}

K
predict_values(K kmodel, K knodes) {
    struct svm_model model;
    struct svm_node *nodes = 0;
    K r = 0, dec_values = 0;
    I i;

    memset(&model, 0, sizeof(struct svm_model)), model.free_sv = 1;
    D(k_to_model(kmodel,&model));
    if (knodes->t) {
        D(k_to_node_dict(knodes, &nodes));
        dec_values = ktn(KF,model.nr_class*(model.nr_class-1)/2);
        r = knk(2,kf(svm_predict_values(&model,nodes,kF(dec_values))),dec_values);
    } else {
        r = knk(2,ktn(KF,knodes->n),ktn(0,knodes->n));
        for (i = 0;i < knodes->n;++i) {
            D(k_to_node_dict(kK(knodes)[i], &nodes));
            dec_values = ktn(KF,model.nr_class*(model.nr_class-1)/2);
            kF(kK(r)[0])[i] = svm_predict_values(&model,nodes,kF(dec_values));
            kK(kK(r)[1])[i] = dec_values;
        }

    }
 done:
    svm_free_model_content(&model);
    free(nodes);
    R r;
}

K
predict_probability(K kmodel, K knodes) {
    struct svm_model model;
    struct svm_node *nodes = 0;
    K r = 0, prob = 0;
    I i;

    memset(&model, 0, sizeof(struct svm_model)), model.free_sv = 1;
    D(k_to_model(kmodel,&model));
    if (knodes->t) {
        D(k_to_node_dict(knodes, &nodes));
        prob = ktn(KF,model.nr_class);
        memset(kF(prob), 0, prob->n*sizeof(F));
        r = knk(2,kf(svm_predict_probability(&model,nodes,kF(prob))),prob);
    } else {
        r = knk(2,ktn(KF,knodes->n),ktn(0,knodes->n));
        for (i = 0;i < knodes->n; ++i) {
            D(k_to_node_dict(kK(knodes)[i], &nodes));
            prob = ktn(KF,model.nr_class);
            memset(kF(prob), 0, prob->n*sizeof(F));
            kF(kK(r)[0])[i] = svm_predict_probability(&model,nodes,kF(prob));
            kK(kK(r)[1])[i] = prob;
        }
    }
 done:
    svm_free_model_content(&model);
    free(nodes);
    R r;
}

K
prob_inout(K kprob) {
    struct svm_problem prob;

    memset(&prob, 0, sizeof(struct svm_problem));
    U(k_to_problem(kprob,&prob));
    kprob = problem_to_k(&prob);
    destroy_prob(&prob);
    R kprob;
}

K
param_inout(K kparam) {
    struct svm_parameter param;

    memset(&param, 0, sizeof(struct svm_parameter));
    U(k_to_parameter(kparam,&param));
    kparam = parameter_to_k(&param);
    svm_destroy_param(&param);
    R kparam;
}

K
model_inout(K kmodel) {
    struct svm_model model;

    memset(&model, 0, sizeof(struct svm_model)), model.free_sv = 1;
    U(k_to_model(kmodel,&model));
    kmodel = model_to_k(&model);
    svm_free_model_content(&model);
    R kmodel;
}

K
set_print_string_function(K x) {
    P(xt != -KS, krr("type"));

    print_string_function = xs;
    R 0;
}

K
lib(K x) {
    K y;

    svm_set_print_string_function(print_string_q);

    x=ktn(KS,0);
    y=ktn(0,0);

    js(&x,ss("version")),                 jk(&y,ki(libsvm_version));
    js(&x,ss("check_parameter")),         jk(&y,dl(check_parameter,2));
    js(&x,ss("train")),                   jk(&y,dl(train,2));
    js(&x,ss("cross_validation")),        jk(&y,dl(cross_validation,3));
    js(&x,ss("load_model")),              jk(&y,dl(load_model,1));
    js(&x,ss("save_model")),              jk(&y,dl(save_model,2));
    js(&x,ss("check_probability_model")), jk(&y,dl(check_probability_model,1));
    js(&x,ss("predict")),                 jk(&y,dl(predict,2));
    js(&x,ss("predict_values")),          jk(&y,dl(predict_values,2));
    js(&x,ss("predict_probability")),     jk(&y,dl(predict_probability,2));
    js(&x,ss("prob_inout")),              jk(&y,dl(prob_inout,1));
    js(&x,ss("param_inout")),             jk(&y,dl(param_inout,1));
    js(&x,ss("model_inout")),             jk(&y,dl(model_inout,1));
    js(&x,ss("set_print_string_function")), jk(&y,dl(set_print_string_function,1));
    R xD(x,y);
}
