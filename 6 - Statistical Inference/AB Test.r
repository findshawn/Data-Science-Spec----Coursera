# =============== A/B test comparisons ==========================
# 
# daily traffic: 100,000
# conversion rate: 2.5%
# if conversion rate increases by 5%, how long should the test last?

# =================================================================
# Parameters
# =================================================================

n = 100000
p0 = 2.5/100
p1 = p0 * 1.05
p2 = p0
n1 = n * 0.5
n2 = n - n1
sd = sqrt(p0*(1-p0))

# =================================================================
# t test
# =================================================================

# 1 day
T = 1
N1 = n1 * T
N2 = n2 * T

p=(N1*p1+N2*p2)/(N1+N2)
se = sqrt(p*(1-p)*(1/N1+1/N2))
d = p1-p2
z = d/se
pnorm(z,lower.tail = F) # p-value: 0.106

# 2 day
T = 2
N1 = n1 * T
N2 = n2 * T

p=(N1*p1+N2*p2)/(N1+N2)
se = sqrt(p*(1-p)*(1/N1+1/N2))
d = p1-p2
z = d/se
pnorm(z,lower.tail = F) # p-value: 0.038


# =================================================================
# Power test
# =================================================================

power.t.test(delta=d,sd=sd,sig.level=0.05,power = 0.9,type='one.sample',alternative='one.sided')
power.t.test(delta=d,sd=sd,sig.level=0.1,power = 0.9,type='one.sample',alternative='one.sided')
power.t.test(delta=d,sd=sd,sig.level=0.05,power = 0.95,type='one.sample',alternative='one.sided')

# 3 ~ 4 day

# =================================================================
# poisson test
# =================================================================

# 1 day
T = 1
N1 = n1 * T
N2 = n2 * T

poisson.test(round(N1*p1),T=N1,r=p0,alternative='greater') # p-value: 0.39

# =================================================================
# bayesian test
# =================================================================

#################### prior data: 1 day ##################
prior.alpha = n*p0
prior.beta = n*(1-p0)
n.trials = 100000

# 1 day
T = 1
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 0.77

# 2 day
T = 2
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 0.90

# 3 day
T = 3
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 0.95

# 4 day
T = 4
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 

# 5 day
T = 5
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 


#################### prior data: 10 day ##################
prior.alpha = n*p0*10
prior.beta = n*(1-p0)*10
n.trials = 100000

# 1 day
T = 1
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 0.61

# 2 day
T = 2
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 0.71

# 3 day
T = 3
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 0.78

# 4 day
T = 4
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 0.85

# 5 day
T = 5
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 0.90

# 10 day
T = 10
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 

# 15 day
T = 15
N1 = n1 * T
N2 = n2 * T

a.samples = rbeta(n.trials,N1*p1+prior.alpha,N1*(1-p1)+prior.beta)
b.samples = rbeta(n.trials,N2*p2+prior.alpha,N2*(1-p2)+prior.beta)
sum(a.samples > b.samples)/n.trials # p-value: 


