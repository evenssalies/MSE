# Pondération du contrôle synthétique (Abadie, Diamond & Hainmueller, 2010, section 2.3)
#
# Pour une matrice V donnée, W (J x 1) minimise (X1 - X0 W)' V (X1 - X0 W)
# sous les contraintes 0 <= w_j <= 1 et sum_j w_j = 1.
# X1 : caractéristiques de la Californie (state_id 3)
# X0 : mêmes caractéristiques pour les J autres états (donor pool)
#
# Caractéristiques (moyennes sur les années indiquées, valeurs manquantes ignorées) :
#   cigsale en 1975, 1980 et 1988 ; moyenne 1980-1988 de beer, lnincome, retprice, age15to24
#   => k = 3 + 4 = 7 lignes
#
# Choix de V (trois cas calculés et affichés) :
#   Choix 1 : V diagonale à éléments positifs, en deux cas :
#     1a) V = diag(V1), V1 = (1, ..., 1) (éléments diagonaux en entrée), sans optimisation
#     1b) V = diag(v), v optimisé par Nelder-Mead à partir de V1 pour minimiser le MSPE
#         de cigsale sur la période pré-intervention 1970-1988
#   Choix 2 : V = covariance échantillonnale des X_i de tous les J = 39 états (Californie incluse) :
#      sum_i (X_i - Xbar)(X_i - Xbar)' / (J - 1), Xbar moyenne sur les 39 états

import numpy as np
import pandas as pd
from scipy.optimize import minimize

URL = "https://raw.githubusercontent.com/evenssalies/MSE/main/datasets/sc_smoking.csv"
TREATED_ID = 3  # Californie
PRE_PERIOD = list(range(1970, 1989))  # T0 = 1970-1988 (1989 = année de l'intervention)

df = pd.read_csv(URL, dtype={"state": "string"})

tables = {var: df.pivot(index="year", columns="state_id", values=var) for var in df.columns[3:]}

rows = {f"cigsale {year}": tables["cigsale"].loc[year] for year in [1975, 1980, 1988]}
for var in ["beer", "lnincome", "retprice", "age15to24"]:
    rows[f"{var} 1980-1988"] = tables[var].loc[1980:1988].mean()

X = pd.DataFrame(rows).T  # k x (nombre d'états)
k = X.shape[0]

X1 = X[TREATED_ID].to_numpy()
X0 = X.drop(columns=TREATED_ID).to_numpy()
donor_ids = X.drop(columns=TREATED_ID).columns.to_list()
J = X0.shape[1]
names = df.drop_duplicates("state_id").set_index("state_id")["state"].astype(str)

# cigsale sur la période pré-intervention
Z = tables["cigsale"].loc[PRE_PERIOD]
Z1 = Z[TREATED_ID].to_numpy()
Z0 = Z.drop(columns=TREATED_ID).to_numpy()

# Entrée : éléments diagonaux de V1
V1 = np.ones(k)

print(f"X1 : {X1.shape}, X0 : {X0.shape}, J = {J}, T0 = {len(PRE_PERIOD)} ans")


def solve_w(V):
    """W minimisant (X1 - X0 W)' V (X1 - X0 W) sous les contraintes de simplexe."""
    V = V / np.trace(V)  # une échelle commune ne change pas W ; SLSQP converge alors correctement

    def loss(w):
        r = X1 - X0 @ w
        return r @ V @ r

    def gradient(w):
        return -2 * X0.T @ V @ (X1 - X0 @ w)

    res = minimize(
        loss,
        x0=np.full(J, 1 / J),
        jac=gradient,
        method="SLSQP",
        bounds=[(0, 1)] * J,
        constraints=[{"type": "eq", "fun": lambda w: w.sum() - 1, "jac": lambda w: np.ones(J)}],
        options={"maxiter": 1000, "ftol": 1e-14},
    )
    if not res.success:
        raise RuntimeError(f"SLSQP : {res.message}")
    return res.x


def mspe(w):
    """Erreur quadratique moyenne de prévision de cigsale sur 1970-1988."""
    gap = Z1 - Z0 @ w
    return np.mean(gap**2)


def report(label, w):
    print(f"\n{label}")
    print(f"  RMSPE cigsale 1970-1988 : {np.sqrt(mspe(w)):.4f}")
    print(f"  sum(W) = {w.sum():.6f}")
    print(pd.Series(w, index=names[donor_ids].to_numpy()).loc[lambda s: s > 0.001].round(4).to_string())


# Choix 1a : V = diag(V1), sans optimisation (point de départ de Nelder-Mead)
report("Choix 1, V1 (entrée)", solve_w(np.diag(V1)))


def mspe_of_diagonal(v):
    return mspe(solve_w(np.diag(v)))


# Choix 1b : V diagonale optimisée par Nelder-Mead à partir de V1
nm = minimize(
    mspe_of_diagonal,
    x0=V1,
    method="Nelder-Mead",
    bounds=[(1e-6, None)] * k,
    options={"maxiter": 1000, "maxfev": 5000, "xatol": 1e-6, "fatol": 1e-9},
)
V_diag = np.diag(nm.x)
print(f"\nNelder-Mead : success = {nm.success} ({nm.message}), nit = {nm.nit}")
print("Diagonale de V optimisée :", np.round(nm.x, 6))
report("Choix 1, V diagonale optimisée (Nelder-Mead)", solve_w(V_diag))

# Choix 2 : V = sum_i (X_i - Xbar)(X_i - Xbar)' / (J - 1), sur les 39 états
Xall = X.to_numpy()  # k x 39, Californie incluse
J_all = Xall.shape[1]
dev = Xall - Xall.mean(axis=1, keepdims=True)
V_cov = dev @ dev.T / (J_all - 1)
report("Choix 2, V = covariance échantillonnale", solve_w(V_cov))


